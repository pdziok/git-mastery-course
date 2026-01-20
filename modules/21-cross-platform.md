# Module 21: Cross-Platform Git - Windows, macOS, and Linux

## 🎯 Learning Objectives

After this module, you will:
- Understand line ending differences (CRLF vs LF)
- Handle case sensitivity issues
- Configure Git for cross-platform teams
- Use Docker for consistent environments

---

## 📖 The Big Three Differences

| Issue | Windows | macOS | Linux |
|-------|---------|-------|-------|
| **Line endings** | CRLF (`\r\n`) | LF (`\n`) | LF (`\n`) |
| **Case sensitivity** | Insensitive | Insensitive* | Sensitive |
| **Path separator** | `\` | `/` | `/` |
| **File permissions** | Limited | Full Unix | Full Unix |

*macOS is case-insensitive but case-preserving by default (depends on filesystem).

---

## 📖 Part 1: Line Endings (The Classic Problem)

### The Issue

```
Windows file:   Hello World\r\n
macOS/Linux:    Hello World\n

When Windows user commits and Linux user pulls:
Git might show the entire file as changed!
```

### The Solution: `core.autocrlf`

```bash
# Windows: Convert LF to CRLF on checkout, CRLF to LF on commit
git config --global core.autocrlf true

# macOS/Linux: Convert CRLF to LF on commit, no conversion on checkout
git config --global core.autocrlf input

# Never convert (not recommended for cross-platform)
git config --global core.autocrlf false
```

### Even Better: .gitattributes

Define line endings in the repo itself (team-wide):

```bash
# .gitattributes file (commit this!)

# Default: auto-detect and normalize to LF on commit
* text=auto

# Force LF for these files
*.sh text eol=lf
*.py text eol=lf
*.js text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.md text eol=lf

# Force CRLF for Windows batch files
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf

# Binary files (don't touch!)
*.png binary
*.jpg binary
*.gif binary
*.ico binary
*.pdf binary
*.zip binary
*.jar binary
```

### Fixing Line Ending Issues

```bash
# Refresh files to apply new .gitattributes
git rm --cached -r .
git reset --hard
# Or:
git add --renormalize .
git commit -m "chore: normalize line endings"
```

---

## 📖 Part 2: Case Sensitivity

### The Issue

```bash
# On macOS/Windows:
# File.txt and file.txt are THE SAME FILE

# On Linux:
# File.txt and file.txt are DIFFERENT FILES

# Developer on Linux creates both, commits
# Developer on Windows pulls - only one file appears!
```

### Prevention

```bash
# Make Git case-sensitive on macOS/Windows (warning-only by default)
git config --global core.ignorecase false

# This will catch issues like:
git mv File.txt file.txt
# Instead of silently doing nothing, Git will properly rename
```

### Detecting Case Conflicts

```bash
# Find case conflicts in repo
git ls-files | sort -f | uniq -di

# If this outputs anything, you have a problem!
```

### Fixing Case Issues

```bash
# On macOS/Windows, to rename with case change:
# Wrong (might not work):
git mv File.txt file.txt

# Right (two steps):
git mv File.txt temp.txt
git mv temp.txt file.txt
```

---

## 📖 Part 3: Executables and Permissions

### The Issue

```bash
# Shell scripts created on Windows won't be executable on Linux
# Because Windows doesn't have the execute bit concept
```

### Setting Execute Permission in Git

```bash
# Make a file executable (cross-platform)
git update-index --chmod=+x script.sh

# Then commit
git add script.sh
git commit -m "chore: make script executable"

# Or when adding:
git add --chmod=+x script.sh
```

### In .gitattributes

```bash
# Mark shell scripts as executable
*.sh    text eol=lf diff=bash
```

Note: Git tracks the executable bit, but Windows won't use it natively.

---

## 📖 Part 4: Path Issues

### Path Separators

```bash
# Windows path:  C:\Users\name\project
# Unix path:     /Users/name/project

# Git internally uses forward slashes
# Git Bash on Windows translates paths

# In scripts, ALWAYS use forward slashes:
git add src/components/Button.js  # Works everywhere
git add src\components\Button.js  # Windows only!
```

### Long Paths on Windows

```bash
# Windows has 260 character path limit by default
# Node.js projects often exceed this (node_modules/...)

# Fix: Enable long paths
git config --global core.longpaths true

# Also need Windows setting (run as Admin):
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1
```

---

## 📖 Part 5: Recommended Cross-Platform Configuration

### For Your Team

Create `.gitattributes` in every repo:

```bash
# .gitattributes

# Auto-detect text files and normalize to LF
* text=auto

# Source code - LF
*.c text eol=lf
*.h text eol=lf
*.cpp text eol=lf
*.py text eol=lf
*.js text eol=lf
*.ts text eol=lf
*.jsx text eol=lf
*.tsx text eol=lf
*.json text eol=lf
*.css text eol=lf
*.scss text eol=lf
*.html text eol=lf
*.xml text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.md text eol=lf
*.txt text eol=lf

# Shell scripts - LF and executable
*.sh text eol=lf
*.bash text eol=lf

# Windows scripts - CRLF
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf

# Makefiles - LF (tabs are significant)
Makefile text eol=lf
*.mk text eol=lf

# Docker - LF
Dockerfile text eol=lf
*.dockerfile text eol=lf
docker-compose*.yml text eol=lf

# Git configs - LF
.gitignore text eol=lf
.gitattributes text eol=lf
.gitmodules text eol=lf

# Binary files
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.svg binary
*.pdf binary
*.zip binary
*.gz binary
*.tar binary
*.7z binary
*.exe binary
*.dll binary
*.so binary
*.dylib binary
*.jar binary
*.war binary
*.ear binary
*.class binary
```

### For Windows Users

```bash
# Essential Windows Git config
git config --global core.autocrlf true
git config --global core.longpaths true
git config --global core.ignorecase false
git config --global init.defaultBranch main
```

### For macOS/Linux Users

```bash
# Essential macOS/Linux Git config
git config --global core.autocrlf input
git config --global core.ignorecase false
git config --global init.defaultBranch main
```

---

## 📖 Part 6: Windows-Specific Tips

### Git Bash vs PowerShell vs CMD

| Shell | Pros | Cons |
|-------|------|------|
| **Git Bash** | Unix-like, most compatible | Slower, some Windows tools missing |
| **PowerShell** | Native, powerful | Different syntax, some Git quirks |
| **CMD** | Simple, legacy | Limited, no tab completion |
| **WSL2** | Real Linux! | Filesystem performance across boundary |

### Recommended: WSL2

```bash
# Install WSL2 (PowerShell as Admin)
wsl --install

# Choose a distro (Ubuntu recommended)
wsl --install -d Ubuntu

# Now you have real Linux inside Windows!
# Clone repos INTO WSL filesystem for speed:
cd /home/username/projects  # Good, fast
cd /mnt/c/Users/...         # Slow, cross-filesystem
```

### Git Credential Manager

Windows comes with Git Credential Manager:

```bash
# Should be auto-configured, but if not:
git config --global credential.helper manager-core

# To clear stored credentials:
# Windows Settings → Credential Manager → Windows Credentials
# Find git:... entries and remove
```

---

## 📖 Part 7: Common Cross-Platform Issues

### "Entire file shows as changed"

```bash
# Probably line endings
# Check:
git diff --check

# Fix:
git config core.autocrlf true  # or input
git add --renormalize .
git commit -m "fix: normalize line endings"
```

### "File not found" on Linux that works on Windows

```bash
# Probably case sensitivity
# Check if you have case variants:
git ls-files | sort -f | uniq -di

# Fix: rename properly
git mv TheFile.js thefile.js  # Might need two-step rename
```

### "Permission denied" running scripts

```bash
# Script doesn't have execute bit
chmod +x script.sh  # On Linux/macOS
# Or:
git update-index --chmod=+x script.sh
```

### "Filename too long" on Windows

```bash
git config --global core.longpaths true
```

---

## 📖 Part 8: Docker for Consistent Environment

See the `docker/` directory for a ready-to-use Docker setup for this workshop.

Benefits:
- Same environment for everyone
- No "works on my machine" issues
- Easy to reset and restart

```bash
# Run the workshop in Docker
cd /path/to/git-workshops/docker
docker-compose up -d
docker exec -it git-workshop bash

# Now you're in a Linux container!
# All exercises work the same way
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What setting should Windows users set for `core.autocrlf`?

2. **Q:** What file ensures consistent line endings for the whole team?

3. **Q:** How do you rename `File.txt` to `file.txt` on macOS?

4. **Q:** How do you make a script executable in Git?

5. **Q:** Why is WSL2 recommended for Git on Windows?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `true` (convert LF to CRLF on checkout, CRLF to LF on commit)

2. **A:** `.gitattributes` (committed to the repo)

3. **A:** Two-step: `git mv File.txt temp.txt` then `git mv temp.txt file.txt`

4. **A:** `git update-index --chmod=+x script.sh` or `git add --chmod=+x script.sh`

5. **A:** Real Linux environment, proper case sensitivity, native Unix tools, better Git performance

</details>

---

## 🎯 Cross-Platform Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    CROSS-PLATFORM GIT                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LINE ENDINGS                                                   │
│  Windows:  git config --global core.autocrlf true               │
│  macOS:    git config --global core.autocrlf input              │
│  Team:     Use .gitattributes file                              │
│                                                                 │
│  CASE SENSITIVITY                                               │
│  git config --global core.ignorecase false                      │
│  Rename:   git mv File.txt temp.txt && git mv temp.txt file.txt │
│                                                                 │
│  LONG PATHS (Windows)                                           │
│  git config --global core.longpaths true                        │
│                                                                 │
│  EXECUTABLES                                                    │
│  git update-index --chmod=+x script.sh                          │
│                                                                 │
│  REFRESH AFTER .gitattributes                                   │
│  git add --renormalize .                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 22: Patches and Diffs**, we'll learn:
- Creating and applying patches
- Working without network access
- Using diff and patch commands

Check out the `docker/` directory for a containerized workshop environment that works identically on Windows, macOS, and Linux!
