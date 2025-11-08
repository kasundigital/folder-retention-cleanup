#!/usr/bin/env bash
set -euo pipefail

ROOT="/mnt/test"
RET_FILE="/root/retention.txt"
DEFAULT_DAYS=30

# Ensure file exists
[[ -f "$RET_FILE" ]] || touch "$RET_FILE"

TMP_FOLDERS="$(mktemp)"
TMP_NEW="$(mktemp)"
RET_BAK="${RET_FILE}.bak.$(date +%Y%m%d_%H%M%S)"

# 1) List current immediate subfolders (names only), sorted
find "$ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort > "$TMP_FOLDERS"

# 2) Build new retention file using AWK (no bash arrays)
#    - Load existing "name = N" map from RET_FILE
#    - For every current folder: keep old N if exists, else DEFAULT_DAYS
awk -v DEF="$DEFAULT_DAYS" -v RET="$RET_FILE" '
  BEGIN{
    FS="=";
    # Load existing retention map
    while ((getline line < RET) > 0) {
      gsub(/\r/,"", line);
      sub(/#.*/, "", line);
      gsub(/^[ \t]+|[ \t]+$/, "", line);
      if (line == "") continue;

      split(line, a, "=");
      name = a[1]; days = a[2];
      gsub(/^[ \t]+|[ \t]+$/, "", name);
      gsub(/^[ \t]+|[ \t]+$/, "", days);

      if (name != "" && days ~ /^[0-9]+$/) {
        map[name] = days;
        old_total++;
      }
    }
  }
  {
    name = $0;
    gsub(/^[ \t]+|[ \t]+$/, "", name);
    if (name == "" || name == ".trash") next;

    if (name in map) {
      print name " = " map[name];
      kept++;
    } else {
      print name " = " DEF;
      added++;
    }
  }
  END{
    # Send counters to stderr so we can show them after mv
    printf("kept=%d added=%d old_total=%d\n", kept+0, added+0, old_total+0) > "/dev/stderr";
  }
' "$TMP_FOLDERS" > "$TMP_NEW" 2> /tmp/ret_sync_counts.$$


# 3) Backup old file, replace atomically
cp -f "$RET_FILE" "$RET_BAK" || true
mv "$TMP_NEW" "$RET_FILE"
chmod 600 "$RET_FILE"

# 4) Show summary (and which entries were removed, if any)
. /tmp/ret_sync_counts.$$
removed=$(( old_total - kept ))
echo "✅ updated $RET_FILE (root=$ROOT)"
echo "   kept: $kept  | added: $added  | removed: $removed"
if (( removed > 0 )); then
  echo "   removed entries:"
  # Old names not in current folder list
  # (Print only names, suppress noise if none)
  comm -23 \
    <(awk -F= '{gsub(/^[ \t]+|[ \t]+$/,"",$1); if($1!="") print $1}' "$RET_BAK" | LC_ALL=C sort) \
    <(cat "$TMP_FOLDERS") || true
fi

# 5) Cleanup
rm -f "$TMP_FOLDERS" /tmp/ret_sync_counts.$$ || true
#!/usr/bin/env bash
set -euo pipefail

ROOT="/mnt/test"
RET_FILE="/root/retention.txt"
DEFAULT_DAYS=30

# Ensure file exists
[[ -f "$RET_FILE" ]] || touch "$RET_FILE"

TMP_FOLDERS="$(mktemp)"
TMP_NEW="$(mktemp)"
RET_BAK="${RET_FILE}.bak.$(date +%Y%m%d_%H%M%S)"

# 1) List current immediate subfolders (names only), sorted
find "$ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort > "$TMP_FOLDERS"

# 2) Build new retention file using AWK (no bash arrays)
#    - Load existing "name = N" map from RET_FILE
#    - For every current folder: keep old N if exists, else DEFAULT_DAYS
awk -v DEF="$DEFAULT_DAYS" -v RET="$RET_FILE" '
  BEGIN{
    FS="=";
    # Load existing retention map
    while ((getline line < RET) > 0) {
      gsub(/\r/,"", line);
      sub(/#.*/, "", line);
      gsub(/^[ \t]+|[ \t]+$/, "", line);
      if (line == "") continue;

      split(line, a, "=");
      name = a[1]; days = a[2];
      gsub(/^[ \t]+|[ \t]+$/, "", name);
      gsub(/^[ \t]+|[ \t]+$/, "", days);

      if (name != "" && days ~ /^[0-9]+$/) {
        map[name] = days;
        old_total++;
      }
    }
  }
  {
    name = $0;
    gsub(/^[ \t]+|[ \t]+$/, "", name);
    if (name == "" || name == ".trash") next;

    if (name in map) {
      print name " = " map[name];
      kept++;
    } else {
      print name " = " DEF;
      added++;
    }
  }
  END{
    # Send counters to stderr so we can show them after mv
    printf("kept=%d added=%d old_total=%d\n", kept+0, added+0, old_total+0) > "/dev/stderr";
  }
' "$TMP_FOLDERS" > "$TMP_NEW" 2> /tmp/ret_sync_counts.$$


# 3) Backup old file, replace atomically
cp -f "$RET_FILE" "$RET_BAK" || true
mv "$TMP_NEW" "$RET_FILE"
chmod 600 "$RET_FILE"

# 4) Show summary (and which entries were removed, if any)
. /tmp/ret_sync_counts.$$
removed=$(( old_total - kept ))
echo "✅ updated $RET_FILE (root=$ROOT)"
echo "   kept: $kept  | added: $added  | removed: $removed"
if (( removed > 0 )); then
  echo "   removed entries:"
  # Old names not in current folder list
  # (Print only names, suppress noise if none)
  comm -23 \
    <(awk -F= '{gsub(/^[ \t]+|[ \t]+$/,"",$1); if($1!="") print $1}' "$RET_BAK" | LC_ALL=C sort) \
    <(cat "$TMP_FOLDERS") || true
fi

# 5) Cleanup
rm -f "$TMP_FOLDERS" /tmp/ret_sync_counts.$$ || true
