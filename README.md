<h1>📁✨ Per-Folder File Retention System (Linux)</h1>

<p>This project provides an automated file retention and cleanup system for Linux folders.  
Each folder can have its own custom retention period (number of days to keep files).  
The system is safe, flexible, and designed for production environments.</p>

<hr>

<h2>📐 Project Background</h2>

<p>This solution was developed as part of a real client project.  
The client needed an automated way to remove old files from many folders, but each folder required its own retention rule.</p>

<p>A simple one-rule cleanup script was not enough.  
So I designed and engineered a complete solution that:</p>

<ul>
  <li>✅ Detects new folders automatically and assigns a default retention</li>
  <li>✅ Removes folder entries when they no longer exist</li>
  <li>✅ Allows each folder to have a different retention period</li>
  <li>✅ Performs safe dry-run mode by default (no accidental deletions)</li>
  <li>✅ Creates logs for tracking and auditing</li>
</ul>

<p>This system demonstrates my practical experience in:</p>
<ul>
  <li>• Bash scripting</li>
  <li>• Linux automation</li>
  <li>• Production-safe file operations</li>
  <li>• Designing real-world client solutions</li>
  <li>• Systems engineering and reliability</li>
</ul>

<p><b>All logic, safety checks, and system design were implemented and tested by me to fulfill a real client requirement.</b></p>

<hr>

<h2>🧠 What This System Does (Simple Explanation)</h2>

<p>This tool automatically cleans old files inside multiple folders.  
However, every folder can have its <b>own retention rule</b>.</p>

<p>Example rules:</p>
<ul>
  <li>📁 folder A → keep files for 7 days</li>
  <li>📁 folder B → keep files for 30 days</li>
  <li>📁 folder C → keep files for 60 days</li>
</ul>

<p>The system does 3 main things:</p>

<ol>
  <li><b>Detects new folders</b> and automatically adds them to the retention list (default 30 days).</li>
  <li><b>Removes deleted folders</b> from the retention file automatically.</li>
  <li><b>Deletes files older than X days</b> depending on the rule for each folder.</li>
</ol>

<p><b>Nothing is deleted accidentally.</b>  
The default mode is <b>DRY-RUN</b> which only shows what would be deleted.</p>

<p>Files are only deleted when run with <code>--apply</code>.</p>

<hr>

<h2>🚀 Features</h2>
<ul>
  <li>🆕 Auto-detects new folders</li>
  <li>🗑️ Cleans up deleted folder entries</li>
  <li>⏳ Per-folder retention days supported</li>
  <li>🛡️ Safe dry-run by default</li>
  <li>🕒 Cron-ready scheduling</li>
  <li>📘 Logging included</li>
  <li>✅ Production tested and stable</li>
</ul>

<hr>

<h2>📂 Directory & File Layout</h2>
<ul>
  <li>📁 Data root: <code>/mnt/test</code></li>
  <li>📝 Retention map file: <code>/root/retention.txt</code></li>
  <li>🔄 Sync script: <code>/root/generate_retention_file.sh</code></li>
  <li>🧹 Cleanup script: <code>/root/apply_retention.sh</code></li>
  <li>📘 Log output: <code>/var/log/apply_retention.log</code></li>
</ul>

<hr>

<h2>📄 Retention File Format</h2>

<pre><code>folder1 = 30
folder2 = 60
another-folder = 14
</code></pre>

<p>✅ Blank lines ignored<br>
✅ Comment lines (starting with <code>#</code>) are ignored</p>

<hr>

<h2>⚙️ Scripts Overview</h2>

<h3>🔄 generate_retention_file.sh</h3>
<p>Updates the retention file based on real folders:</p>
<ul>
  <li>🟢 Adds new folders with default 30 days</li>
  <li>🔴 Removes entries for deleted folders</li>
  <li>🟡 Keeps existing retention days intact</li>
</ul>

<h3>🧹 apply_retention.sh</h3>
<p>Deletes files older than each folder's retention rule:</p>
<ul>
  <li>👀 <b>Dry-run</b> (default) — shows what would be deleted</li>
  <li>🔥 <b>Apply mode</b> — run with <code>--apply</code> to delete</li>
</ul>

<hr>

<h2>🧪 Quick Usage</h2>

<ol>
  <li><b>Generate retention list</b><br>
      <code>/root/generate_retention_file.sh</code>
  </li>
  <br>
  <li><b>Edit retention days</b> (optional)<br>
      <code>nano /root/retention.txt</code>
  </li>
  <br>
  <li><b>Preview cleanup (safe)</b><br>
      <code>/root/apply_retention.sh</code>
  </li>
  <br>
  <li><b>Apply cleanup (permanent deletion)</b><br>
      <code>/root/apply_retention.sh --apply</code>
  </li>
</ol>

<hr>

<h2>🧪 Testing</h2>

<pre><code>
mkdir -p /mnt/test/testfolder
touch /mnt/test/testfolder/old.txt
touch -d "60 days ago" /mnt/test/testfolder/old.txt

# Dry-run (no delete)
/root/apply_retention.sh

# Actual delete
/root/apply_retention.sh --apply
</code></pre>

<hr>

<h2>⏱️ Cron Automation</h2>

<pre><code>
# Sync retention file daily at 03:00
0 3 * * * /root/generate_retention_file.sh >/dev/null 2>&1

# Apply deletion at 03:15
15 3 * * * /root/apply_retention.sh --apply >> /var/log/apply_retention.log 2>&1
</code></pre>

<hr>

<h2>👨‍💻 Author & Credits</h2>

<p><b>👤 Kasun (kasundigital)</b><br>
Designed, implemented, and validated as part of a real client project.</p>

<p><b>🤖 ChatGPT (OpenAI)</b><br>
Helped with generating documentation and improving script readability.<br>
All system logic, validation, and production testing were done by a human engineer.</p>

<hr>

<h2>📜 License</h2>
<p>MIT License</p>
