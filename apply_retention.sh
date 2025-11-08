#!/usr/bin/env bash
set -euo pipefail

# Defaults (can be overridden by flags)
ROOT="/mnt/test"
RETENTION_FILE="/root/retention.txt"
APPLY=0
LOG_FILE="/var/log/apply_retention.log"

usage() {
  cat <<'USAGE'
apply_retention.sh [--root PATH] [--file RETENTION_FILE] [--apply] [--log LOG_FILE]

- Default is DRY-RUN (lists files that would be deleted).
- To actually delete, pass --apply

Retention file format (either is OK):
  sitename = 30
  sitename=30

Lines starting with # or blank lines are ignored.
USAGE
}

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    --file) RETENTION_FILE="${2:-}"; shift 2 ;;
    --apply) APPLY=1; shift ;;
    --log) LOG_FILE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

ACTION="dry-run"
[[ $APPLY -eq 1 ]] && ACTION="apply"

# --- Preconditions ---
if [[ ! -f "$RETENTION_FILE" ]]; then
  echo "ERROR: Retention file not found: $RETENTION_FILE" >&2
  exit 2
fi
if [[ ! -d "$ROOT" ]]; then
  echo "ERROR: Root directory not found: $ROOT" >&2
  exit 3
fi

# Ensure log dir exists
mkdir -p "$(dirname "$LOG_FILE")"

# --- Header ---
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
echo "=== apply_retention | $(timestamp) | root=$ROOT | action=$ACTION ===" | tee -a "$LOG_FILE"

total_sites=0
total_listed=0
total_deleted=0
declare -a site_reports=()

trim() { awk '{$1=$1; print}'; }  # trim leading/trailing spaces

# --- Process retention lines ---
while IFS= read -r rawline || [[ -n "$rawline" ]]; do
  line="$(echo "$rawline" | sed 's/[[:space:]]\{1,\}=[[:space:]]\{1,\}/=/' )"
  # ignore comments/blank
  [[ -z "${line// }" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  # split on first '='
  if [[ "$line" != *"="* ]]; then
    echo "WARN: Skipping malformed line (no '='): $rawline" | tee -a "$LOG_FILE"
    continue
  fi

  site="$(echo "${line%%=*}" | trim)"
  days_raw="${line#*=}"
  days="$(echo "$days_raw" | trim)"

  # validate
  if [[ -z "$site" || -z "$days" || ! "$days" =~ ^[0-9]+$ ]]; then
    echo "WARN: Skipping bad entry: site='$site' days='$days' (line: $rawline)" | tee -a "$LOG_FILE"
    continue
  fi

  path="$ROOT/$site"
  if [[ ! -d "$path" ]]; then
    echo "INFO: Skipping (missing dir): $path" | tee -a "$LOG_FILE"
    continue
  fi

  (( total_sites++ )) || true
  echo "--- Scanning: $path | Days: $days | action=$ACTION ---" | tee -a "$LOG_FILE"

  if [[ $APPLY -eq 0 ]]; then
    # DRY RUN: list matching files (with timestamps)
    # Use printf for readable output; don't delete
    count_listed=$(find "$path" -type f -mtime +"$days" -printf '%TY-%Tm-%Td %TH:%TM  %p\n' | tee -a "$LOG_FILE" | wc -l || true)
    total_listed=$(( total_listed + count_listed ))
    site_reports+=("SITE: $site | would delete: $count_listed files")
  else
    # APPLY: print then delete
    # print before delete so you see what was removed
    count_deleted=$(find "$path" -type f -mtime +"$days" -print -delete | tee -a "$LOG_FILE" | wc -l || true)
    total_deleted=$(( total_deleted + count_deleted ))
    site_reports+=("SITE: $site | deleted: $count_deleted files")
  fi
done < "$RETENTION_FILE"

# --- Summary ---
echo "=== Summary ($(timestamp)) | sites=$total_sites | action=$ACTION ===" | tee -a "$LOG_FILE"
for r in "${site_reports[@]}"; do
  echo "$r" | tee -a "$LOG_FILE"
done

if [[ $APPLY -eq 0 ]]; then
  echo "TOTAL would delete: $total_listed files" | tee -a "$LOG_FILE"
  echo "DRY-RUN complete. To apply deletions, run with --apply" | tee -a "$LOG_FILE"
else
  echo "TOTAL deleted: $total_deleted files" | tee -a "$LOG_FILE"
  echo "APPLY complete." | tee -a "$LOG_FILE"
fi

