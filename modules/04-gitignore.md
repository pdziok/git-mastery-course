# Module 4: Mastering .gitignore

## Learning Objectives

After this module, you will:
- Understand how .gitignore pattern matching works
- Use root references and directory patterns correctly
- Handle nested .gitignore files
- Keep empty directories in Git
- Debug why files are (not) being ignored

---

## The Basics: What is .gitignore?

A `.gitignore` file tells Git which files and directories to **not track**. Git will pretend these files don't exist.

```bash
# Create a .gitignore in your repo root
echo "node_modules/" > .gitignore
git add .gitignore
git commit -m "Add .gitignore"
```

**Important:** `.gitignore` only works for **untracked** files. If a file is already tracked, adding it to `.gitignore` won't remove it from Git.

---

## Pattern Syntax Reference

| Pattern | Matches | Example |
|---------|---------|---------|
| `file.txt` | Any file named `file.txt` in any directory | `file.txt`, `src/file.txt`, `a/b/file.txt` |
| `/file.txt` | Only `file.txt` in repo root | `file.txt` (not `src/file.txt`) |
| `dir/` | Directory named `dir` anywhere | `dir/`, `src/dir/` |
| `/dir/` | Only `dir` directory in repo root | `dir/` (not `src/dir/`) |
| `*.log` | All `.log` files anywhere | `app.log`, `logs/error.log` |
| `/*.log` | `.log` files only in root | `app.log` (not `logs/error.log`) |
| `**/logs` | `logs` directory at any depth | `logs/`, `src/logs/`, `a/b/logs/` |
| `logs/**` | Everything inside `logs/` | `logs/a.txt`, `logs/sub/b.txt` |
| `**/logs/**` | `logs` dir and contents at any depth | All of the above |
| `!important.log` | Exception: DO track this file | Negates previous pattern |

---

## Part 1: Root References with Leading Slash

The leading slash `/` anchors the pattern to the repository root.

### Without Slash (Matches Anywhere)

```gitignore
# .gitignore
build/
```

This ignores:
```
build/              <-- ignored
src/build/          <-- also ignored!
tests/build/        <-- also ignored!
```

### With Slash (Root Only)

```gitignore
# .gitignore
/build/
```

This ignores:
```
build/              <-- ignored
src/build/          <-- NOT ignored (tracked normally)
tests/build/        <-- NOT ignored
```

### Exercise: Root References

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create directory structure
mkdir -p src/build tests/build
echo "root build output" > build/output.txt
mkdir build
echo "root build output" > build/output.txt
echo "src build" > src/build/output.txt
echo "tests build" > tests/build/output.txt

# First, ignore build/ everywhere
echo "build/" > .gitignore
git status
# Shows: .gitignore (only! all builds ignored)

# Now, only ignore root build/
echo "/build/" > .gitignore
git status
# Shows: .gitignore, src/build/, tests/build/
# Root build/ still ignored, but nested ones are visible!
```

---

## Part 2: Directory vs File Patterns

The trailing slash `/` specifies that the pattern matches only directories.

### Without Trailing Slash

```gitignore
# .gitignore
logs
```

This ignores:
```
logs               <-- file named "logs" - ignored
logs/              <-- directory named "logs" - ignored
src/logs           <-- file - ignored
src/logs/          <-- directory - ignored
```

### With Trailing Slash

```gitignore
# .gitignore
logs/
```

This ignores:
```
logs               <-- file named "logs" - NOT ignored
logs/              <-- directory named "logs" - ignored
src/logs           <-- file - NOT ignored
src/logs/          <-- directory - ignored
```

### Exercise: Directory Patterns

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create both file and directory named "logs"
mkdir -p app/logs
echo "log dir file" > app/logs/app.log
echo "this is a file named logs" > logs-file
mv logs-file logs  # Rename to "logs" (a file)

# Check structure
ls -la
# logs       (file)
# app/       (directory containing logs/)

# Ignore only directories named logs
echo "logs/" > .gitignore
git status --short
# ?? .gitignore
# ?? app/logs/    <-- Wait, this shows? Let's check...
# ?? logs         <-- The FILE is shown (not ignored)

# Actually logs/ directory inside app/ IS ignored
git status
# Untracked: .gitignore, logs (the file)
# The app/logs/ directory is ignored
```

---

## Part 3: Nested .gitignore Files

You can have `.gitignore` files in subdirectories. They apply to that directory and below.

```
project/
├── .gitignore           <-- applies to entire repo
├── src/
│   ├── .gitignore       <-- applies to src/ and below
│   └── components/
└── tests/
    └── .gitignore       <-- applies to tests/ and below
```

### How Patterns Combine

1. Patterns are evaluated in order (top to bottom in each file)
2. Later patterns override earlier ones
3. Nested `.gitignore` patterns are relative to their directory
4. Root `.gitignore` applies first, then nested ones

### Example: Nested .gitignore

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Root ignores all .log files
echo "*.log" > .gitignore

# But src/ wants to track important.log
mkdir src
echo "!important.log" > src/.gitignore

# Create log files
echo "root log" > app.log
echo "src log" > src/debug.log
echo "important!" > src/important.log

# Check status
git status
# .gitignore
# src/.gitignore
# src/important.log    <-- this is tracked!
# (app.log and src/debug.log are ignored)
```

---

## Part 4: The Double-Star Pattern

The `**` matches any number of directories (including zero).

| Pattern | Meaning |
|---------|---------|
| `**/foo` | Match `foo` anywhere |
| `foo/**` | Match everything inside `foo/` |
| `a/**/b` | Match `a/b`, `a/x/b`, `a/x/y/b`, etc. |

### Exercise: Double-Star Patterns

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create deep structure
mkdir -p src/components/buttons
mkdir -p src/utils/helpers
mkdir -p tests/unit/components
touch src/index.js
touch src/components/Button.js
touch src/components/buttons/IconButton.js
touch src/utils/helpers/format.js
touch tests/unit/components/Button.test.js

# Ignore all test files anywhere
echo "**/*.test.js" > .gitignore
git status
# tests/unit/components/Button.test.js is ignored

# Ignore everything in any "helpers" directory
echo "**/helpers/**" >> .gitignore
git status
# src/utils/helpers/format.js is now ignored
```

---

## Part 5: Keeping Empty Directories

Git doesn't track empty directories. Only files are tracked, and directories are created as needed.

### The Problem

```bash
mkdir logs
git add logs
# Nothing happens - Git ignores empty directories!
```

### The Solution: .gitkeep Convention

Create a placeholder file (commonly named `.gitkeep` or `.keep`):

```bash
mkdir logs
touch logs/.gitkeep
git add logs/.gitkeep
git commit -m "Add empty logs directory"
```

### Keeping Directory but Ignoring Contents

A common pattern: track the directory but ignore everything inside:

```gitignore
# .gitignore

# Ignore everything in logs/
logs/*

# But keep the directory (track .gitkeep)
!logs/.gitkeep
```

### Exercise: Empty Directory Patterns

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create directories that should exist but be empty
mkdir -p uploads
mkdir -p cache
mkdir -p logs

# Add .gitkeep files
touch uploads/.gitkeep
touch cache/.gitkeep
touch logs/.gitkeep

# Create .gitignore to ignore contents but keep directories
cat > .gitignore << 'EOF'
# Ignore all contents
uploads/*
cache/*
logs/*

# But keep the .gitkeep files
!uploads/.gitkeep
!cache/.gitkeep
!logs/.gitkeep
EOF

# Add and commit
git add .
git commit -m "Add empty directories with .gitkeep"

# Verify - create files that should be ignored
echo "user upload" > uploads/photo.jpg
echo "cached data" > cache/data.tmp
echo "log entry" > logs/app.log

git status
# Nothing to commit - new files are ignored!

# But directories exist with .gitkeep
ls -la uploads/
# .gitkeep
# photo.jpg (ignored)
```

---

## Part 6: Negation Patterns

Use `!` to un-ignore (track) specific files.

### Important Rules for Negation

1. You cannot negate a file inside an ignored directory
2. Order matters - negation must come AFTER the ignore pattern
3. You may need to un-ignore parent directories first

### This Works

```gitignore
# Ignore all log files
*.log

# But track this specific one
!important.log
```

### This Does NOT Work

```gitignore
# Ignore the entire directory
logs/

# This WON'T work - parent is ignored!
!logs/important.log
```

### The Fix: Ignore Contents, Not Directory

```gitignore
# Ignore contents of logs, not the directory itself
logs/*

# Now this works!
!logs/important.log
```

### Exercise: Negation Patterns

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create structure
mkdir -p config
echo "secret" > config/secrets.json
echo "public" > config/settings.json
echo "also public" > config/features.json

# First attempt (WRONG)
cat > .gitignore << 'EOF'
config/
!config/settings.json
EOF

git status
# Only .gitignore shown - settings.json is NOT tracked!
# Because config/ directory itself is ignored

# Correct approach
cat > .gitignore << 'EOF'
config/*
!config/settings.json
!config/features.json
EOF

git status
# .gitignore
# config/features.json
# config/settings.json
# (config/secrets.json is ignored!)
```

---

## Part 7: Debugging .gitignore

### Check Why a File is Ignored

```bash
# See which .gitignore rule is ignoring a file
git check-ignore -v path/to/file

# Example output:
# .gitignore:3:*.log    path/to/file.log
#            ^line      ^pattern
```

### Check Multiple Files

```bash
# Check all ignored files in a directory
git check-ignore -v *

# Check recursively
find . -type f | git check-ignore -v --stdin
```

### Force Add an Ignored File

```bash
# If you REALLY need to track an ignored file
git add -f path/to/ignored/file

# But better: fix your .gitignore instead!
```

### Exercise: Debugging

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create .gitignore with multiple rules
cat > .gitignore << 'EOF'
*.log
/build/
node_modules/
!important.log
EOF

# Create test files
mkdir build node_modules
echo "test" > app.log
echo "test" > build/output.js
echo "test" > important.log
echo "test" > node_modules/package.js

# Debug: why is app.log ignored?
git check-ignore -v app.log
# .gitignore:1:*.log    app.log

# Debug: why is build/output.js ignored?
git check-ignore -v build/output.js
# .gitignore:2:/build/    build/output.js

# Check if important.log is ignored
git check-ignore -v important.log
# (no output = not ignored, negation worked!)
```

---

## Part 8: Global .gitignore

For files you ALWAYS want to ignore (across all projects):

```bash
# Create global gitignore
touch ~/.gitignore_global

# Configure Git to use it
git config --global core.excludesfile ~/.gitignore_global
```

### Recommended Global Ignores

```gitignore
# ~/.gitignore_global

# OS files
.DS_Store
.DS_Store?
._*
Thumbs.db
ehthumbs.db
Desktop.ini

# Editor files
*.swp
*.swo
*~
.idea/
.vscode/
*.sublime-workspace
*.sublime-project

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
```

---

## Part 9: Common .gitignore Templates

### Node.js / JavaScript

```gitignore
node_modules/
dist/
build/
coverage/
.env
.env.local
.env.*.local
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.eslintcache
```

### Python

```gitignore
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
.venv/
ENV/
.env
*.egg-info/
dist/
build/
.pytest_cache/
.coverage
htmlcov/
```

### Java / Kotlin

```gitignore
*.class
*.jar
*.war
*.ear
target/
build/
.gradle/
out/
*.iml
.idea/
```

### General Template

```gitignore
# Dependencies
node_modules/
vendor/
venv/

# Build outputs
dist/
build/
out/
target/

# IDE
.idea/
.vscode/
*.sublime-*
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment
.env
.env.local
*.local

# Test coverage
coverage/
.nyc_output/
htmlcov/

# Temporary
tmp/
temp/
*.tmp
*.temp
```

---

## Checkpoint: Test Your Understanding

1. **Q:** What's the difference between `logs` and `logs/` in .gitignore?

2. **Q:** How do you ignore a directory but keep it in the repo?

3. **Q:** What does `/build/` ignore vs `build/`?

4. **Q:** How do you debug which rule is ignoring a file?

5. **Q:** Can you negate a file inside an ignored directory?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `logs` ignores both files and directories named "logs". `logs/` only ignores directories.

2. **A:** Ignore contents with `logs/*`, create `logs/.gitkeep`, and add exception `!logs/.gitkeep`

3. **A:** `/build/` ignores only root-level build directory. `build/` ignores build directories anywhere.

4. **A:** `git check-ignore -v path/to/file` shows which rule ignores it.

5. **A:** No. You must ignore directory contents (`dir/*`) instead of the directory itself (`dir/`), then negate specific files.

</details>

---

## .gitignore Cheat Sheet

```
PATTERN SYNTAX
------------------------------------------------------------
file.txt        Any file.txt, anywhere
/file.txt       file.txt only in root
dir/            Directory named dir, anywhere
/dir/           Directory dir only in root
*.log           All .log files
/*.log          .log files only in root
**/logs         logs directory at any level
logs/**         Everything inside logs/
!pattern        Negate (un-ignore) a pattern

COMMON PATTERNS
------------------------------------------------------------
# Ignore directory contents, keep directory
dir/*
!dir/.gitkeep

# Ignore all except specific files
*
!.gitignore
!README.md

# Ignore files only in root
/*.log
/*.tmp

COMMANDS
------------------------------------------------------------
git check-ignore -v <file>     Debug: which rule ignores file?
git add -f <file>              Force add ignored file
git rm --cached <file>         Stop tracking (already tracked) file
git config core.excludesfile   Set global gitignore
```

---

## Pro Tips

1. **Create .gitignore first** - Before adding any files to a new repo
2. **Use templates** - GitHub has great templates at github.com/github/gitignore
3. **Global gitignore for personal files** - Don't pollute project with your editor settings
4. **Already tracked?** - Use `git rm --cached <file>` to stop tracking, then add to .gitignore
5. **Keep it organized** - Group patterns with comments

---

## Removing Already Tracked Files

If you added a file before creating .gitignore:

```bash
# Stop tracking but keep the file locally
git rm --cached secrets.json
echo "secrets.json" >> .gitignore
git commit -m "Stop tracking secrets.json"

# Stop tracking entire directory
git rm -r --cached node_modules/
echo "node_modules/" >> .gitignore
git commit -m "Stop tracking node_modules"
```

**Warning:** The file remains in Git history! See Module 24 for removing from history.

---

## 🚀 What's Next?

In **Module 5: Branching**, we dive into Git's killer feature:
- Create and switch branches
- Understand why branches are so cheap
- Learn branch naming conventions
