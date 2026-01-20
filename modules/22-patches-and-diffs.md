# Module 22: Patches and Diffs - Working Without Network

## 🎯 Learning Objectives

After this module, you will:
- Understand the diff/patch format
- Create patches from commits
- Apply patches to repositories
- Transfer changes via SCP/email when Git isn't available
- Use diff and patch commands outside Git

---

## 🏠 The Handwritten Recipe Metaphor

Before Git, developers shared code changes like sharing recipes:

```
EMAIL/LETTER:
┌─────────────────────────────────────────────────────────────────┐
│  Dear colleague,                                                │
│                                                                 │
│  I fixed the bug in authentication. Here's what to change:      │
│                                                                 │
│  In file auth.js, line 42:                                      │
│  - Remove: "if (password == hash)"                              │
│  + Add:    "if (await bcrypt.compare(password, hash))"          │
│                                                                 │
│  Best regards,                                                  │
│  Alice                                                          │
└─────────────────────────────────────────────────────────────────┘

This is essentially what a PATCH is!
A text file describing changes that can be applied automatically.
```

---

## 📖 Theory: The Unified Diff Format

When you run `git diff`, you see the "unified diff" format:

```diff
diff --git a/auth.js b/auth.js
index 1234567..abcdefg 100644
--- a/auth.js
+++ b/auth.js
@@ -40,7 +40,7 @@ function verifyPassword(password, hash) {
     console.log('Verifying password...');

     // Check password
-    if (password == hash) {
+    if (await bcrypt.compare(password, hash)) {
         return true;
     }
     return false;
```

### Anatomy of a Diff

| Line | Meaning |
|------|---------|
| `diff --git a/auth.js b/auth.js` | Which file is being compared |
| `index 1234567..abcdefg` | Blob hashes (old..new) |
| `--- a/auth.js` | Old file indicator |
| `+++ b/auth.js` | New file indicator |
| `@@ -40,7 +40,7 @@` | Hunk header: line numbers and context |
| Lines starting with space | Context (unchanged) |
| Lines starting with `-` | Removed lines |
| Lines starting with `+` | Added lines |

### The Hunk Header Explained

```
@@ -40,7 +40,7 @@
    │  │  │  │
    │  │  │  └─ 7 lines shown from new file
    │  │  └──── starting at line 40 in new file
    │  └─────── 7 lines shown from old file
    └────────── starting at line 40 in old file
```

---

## 📖 Creating Patches with Git

### Method 1: git diff → Patch File

```bash
# Unstaged changes to a file
git diff > my_changes.patch

# Staged changes
git diff --staged > staged_changes.patch

# Specific file
git diff -- src/auth.js > auth_fix.patch

# Between commits
git diff abc123..def456 > between_commits.patch

# Between branches
git diff main..feature > feature_changes.patch
```

### Method 2: git format-patch (Commit-Based)

Better for sharing commits - includes metadata!

```bash
# Last commit as patch
git format-patch -1

# Last 3 commits
git format-patch -3

# All commits on feature branch not in main
git format-patch main..feature

# Output to specific directory
git format-patch -o patches/ main..feature

# Single file with all commits combined
git format-patch main..feature --stdout > all_changes.patch
```

---

## 🔬 Hands-On Exercise 14.1: Create and Examine Patches

```bash
# Setup
cd ~/git-workshop
rm -rf patch-test && mkdir patch-test && cd patch-test
git init

# Create initial file
cat > app.js << 'EOF'
function greet(name) {
    console.log("Hello " + name);
}

function farewell(name) {
    console.log("Goodbye " + name);
}
EOF
git add app.js
git commit -m "Initial version"

# Make changes
cat > app.js << 'EOF'
function greet(name) {
    console.log(`Hello, ${name}!`);
}

function farewell(name) {
    console.log(`Goodbye, ${name}!`);
}

function wave(name) {
    console.log(`*waves at ${name}*`);
}
EOF

# View the diff
git diff

# Save as patch
git diff > my_changes.patch

# Examine the patch file
cat my_changes.patch

# Revert changes and apply patch
git checkout -- app.js
cat app.js  # Back to original

# Apply the patch
git apply my_changes.patch
cat app.js  # Changes are back!
```

---

## 🔬 Hands-On Exercise 14.2: git format-patch

```bash
# Continue from above - commit our changes
git add app.js
git commit -m "feat: use template literals and add wave function"

# Make another commit
cat >> app.js << 'EOF'

function highFive(name) {
    console.log(`*high fives ${name}*`);
}
EOF
git add app.js
git commit -m "feat: add highFive function"

# Create patches for last 2 commits
git format-patch -2

# List created patches
ls *.patch
# 0001-feat-use-template-literals-and-add-wave-function.patch
# 0002-feat-add-highFive-function.patch

# Examine a format-patch file
cat 0001-*.patch
```

The format-patch output includes:
```
From abc123def456 Mon Sep 17 00:00:00 2001
From: Your Name <you@example.com>
Date: Mon, 15 Jan 2024 10:30:00 +0100
Subject: [PATCH 1/2] feat: use template literals and add wave function

---
 app.js | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/app.js b/app.js
...
```

---

## 📖 Applying Patches

### Method 1: git apply (Just Changes)

```bash
# Apply a diff patch
git apply my_changes.patch

# Check if patch applies cleanly (dry run)
git apply --check my_changes.patch

# Apply with more context tolerance
git apply -3 my_changes.patch

# Reverse a patch (undo)
git apply -R my_changes.patch

# Apply to staging area too
git apply --index my_changes.patch
```

### Method 2: git am (Apply Mailbox - Full Commits)

```bash
# Apply format-patch files (recreates commits!)
git am 0001-*.patch

# Apply multiple patches in order
git am *.patch

# If it fails, you can:
git am --abort      # Cancel
git am --skip       # Skip current patch
git am --continue   # Continue after fixing

# Apply from stdin (piped)
cat patches/*.patch | git am
```

**Key difference:**
- `git apply` = Just applies changes, no commit
- `git am` = Applies AND creates commits (with original author, message, etc.)

---

## 🔬 Hands-On Exercise 14.3: The SCP Scenario

Real-world scenario: You need to apply changes to a server that has Git but no network access to your repository.

```bash
# On your LOCAL machine:
cd ~/git-workshop

# Create "local" development repo
rm -rf local-dev && mkdir local-dev && cd local-dev
git init

cat > app.py << 'EOF'
def process_data(data):
    # Old implementation
    return data.upper()
EOF
git add app.py
git commit -m "Initial app"

# Make your fix
cat > app.py << 'EOF'
def process_data(data):
    # Fixed implementation with error handling
    if not data:
        return ""
    return data.strip().upper()
EOF
git add app.py
git commit -m "fix: handle empty input and strip whitespace"

# Create patch for the fix
git format-patch -1
# Creates: 0001-fix-handle-empty-input-and-strip-whitespace.patch

# In real life: scp 0001-*.patch user@server:/path/to/repo/

# Simulate "server" with separate directory
cd ~/git-workshop
mkdir -p server-repo && cd server-repo
git init

# Server has the OLD version
cat > app.py << 'EOF'
def process_data(data):
    # Old implementation
    return data.upper()
EOF
git add app.py
git commit -m "Initial app"

# "Receive" the patch (simulate scp)
cp ../local-dev/0001-*.patch .

# Apply the patch on the server
git am 0001-*.patch

# Check it worked
cat app.py
git log --oneline
# Shows the commit from your local machine!
```

---

## 📖 Using diff and patch Commands (Without Git)

Sometimes the target machine doesn't even have Git!

### Creating a Patch Without Git

```bash
# Standard Unix diff
diff -u old_file.txt new_file.txt > changes.patch

# Recursive for directories
diff -ruN old_directory/ new_directory/ > all_changes.patch

# Flags:
# -r  Recursive (directories)
# -u  Unified format (the readable one)
# -N  Treat missing files as empty
```

### Applying a Patch Without Git

```bash
# Apply patch
patch < changes.patch

# Apply with specified strip level (remove path prefixes)
patch -p1 < changes.patch    # Strips one directory level

# Dry run (test without applying)
patch --dry-run < changes.patch

# Reverse a patch
patch -R < changes.patch

# Specify target directory
patch -d /path/to/dir -p1 < changes.patch
```

### The -p Flag Explained

```
Patch file says:
--- a/src/auth/login.js
+++ b/src/auth/login.js

-p0  Looks for: a/src/auth/login.js
-p1  Looks for: src/auth/login.js      (strips a/)
-p2  Looks for: auth/login.js          (strips a/src/)
```

Git patches typically need `-p1` because they have `a/` and `b/` prefixes.

---

## 🔬 Hands-On Exercise 14.4: Patch Without Git

```bash
# Scenario: Server has files but NO Git installed

cd ~/git-workshop

# Create "production server" directory (no git)
mkdir -p prod-server/app
cat > prod-server/app/server.py << 'EOF'
def handle_request(req):
    # Old buggy version
    return req.data
EOF

# Your local dev version
mkdir -p local-copy/app
cat > local-copy/app/server.py << 'EOF'
def handle_request(req):
    # Fixed version with validation
    if not req or not req.data:
        return {"error": "Invalid request"}
    return req.data
EOF

# Create patch using standard diff
diff -ruN prod-server/ local-copy/ > server_fix.patch

# Look at the patch
cat server_fix.patch

# "Transfer" to server and apply (without git!)
cd prod-server
patch -p1 < ../server_fix.patch

# Verify
cat app/server.py
# Shows the fixed version!
```

---

## 📖 Email Patches (Old School but Still Used)

Git was designed for email-based workflows:

```bash
# Create patch ready for email
git format-patch -1 --stdout > email_patch.txt

# Send via git send-email (if configured)
git send-email --to="colleague@example.com" 0001-*.patch

# Recipient applies:
git am email_patch.txt
```

---

## 📖 Best Practices for Patches

1. **Always test patches first**
   ```bash
   git apply --check my.patch
   ```

2. **Include enough context**
   ```bash
   git diff -U10 > patch_with_more_context.patch  # 10 lines of context
   ```

3. **Name patches descriptively**
   ```
   0001-fix-auth-null-pointer.patch
   0002-feat-add-rate-limiting.patch
   ```

4. **Use format-patch for commits** (preserves metadata)
   ```bash
   git format-patch -1  # Better than git diff for commits
   ```

5. **Document the application order**
   ```
   README.patches:
   Apply in order:
   1. 0001-base-fix.patch
   2. 0002-security-patch.patch
   3. 0003-feature.patch
   ```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What's the difference between `git apply` and `git am`?

2. **Q:** What does `-` at the start of a line mean in a diff?

3. **Q:** How do you test if a patch will apply without actually applying it?

4. **Q:** What command creates patches that include commit metadata?

5. **Q:** On a machine without Git, what command applies patches?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `git apply` only applies changes. `git am` applies AND creates commits with full metadata.

2. **A:** A removed line (line was deleted in the new version)

3. **A:** `git apply --check my.patch` or `patch --dry-run < my.patch`

4. **A:** `git format-patch`

5. **A:** `patch -p1 < file.patch`

</details>

---

## 🎯 Patches Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    PATCH COMMANDS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CREATING PATCHES                                               │
│  git diff > file.patch              Uncommitted changes         │
│  git diff --staged > file.patch     Staged changes              │
│  git format-patch -1                Last commit                 │
│  git format-patch -3                Last 3 commits              │
│  git format-patch main..feature     Branch diff                 │
│  diff -ruN old/ new/ > file.patch   Without Git                 │
│                                                                 │
│  APPLYING PATCHES                                               │
│  git apply file.patch               Apply changes only          │
│  git apply --check file.patch       Test first                  │
│  git apply -R file.patch            Reverse (undo)              │
│  git am file.patch                  Apply as commit             │
│  git am *.patch                     Apply multiple              │
│  patch -p1 < file.patch             Without Git                 │
│                                                                 │
│  TROUBLESHOOTING                                                │
│  git apply -3 file.patch            3-way merge on conflict     │
│  git am --abort                     Cancel am in progress       │
│  patch --dry-run < file.patch       Test without Git            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 23: Advanced Techniques**, we'll learn:
- Interactive staging with `git add -p`
- Git worktrees for parallel work
- Advanced rebase with `--onto`
