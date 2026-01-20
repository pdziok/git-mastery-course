# Module 16: Git Config and Aliases - Customizing Your Git

## 🎯 Learning Objectives

After this module, you will:
- Understand Git configuration levels
- Configure essential settings
- Create powerful aliases
- Set up merge tools and diff tools
- Manage multiple identities

---

## 📖 Theory: Configuration Levels

Git has three configuration levels:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONFIGURATION HIERARCHY                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SYSTEM  (all users on the machine)                             │
│    Location: /etc/gitconfig (Unix) or Program Files (Windows)   │
│    Set with: git config --system                                │
│                                                                 │
│         ▼ (overridden by)                                       │
│                                                                 │
│  GLOBAL  (your user account)                                    │
│    Location: ~/.gitconfig  or  ~/.config/git/config             │
│    Set with: git config --global                                │
│                                                                 │
│         ▼ (overridden by)                                       │
│                                                                 │
│  LOCAL   (specific repository)                                  │
│    Location: .git/config                                        │
│    Set with: git config --local  (or just git config)           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Local overrides Global, Global overrides System.
```

---

## 🔬 Hands-On Exercise 15.1: View Your Configuration

```bash
# View all settings and their origins
git config --list --show-origin

# View just global settings
git config --global --list

# View local settings (in a repo)
git config --local --list

# View specific setting
git config user.name
git config user.email

# View where a setting comes from
git config --show-origin user.name
```

---

## 📖 Essential Configuration Settings

### Identity (Required)

```bash
# Your name (appears in commits)
git config --global user.name "Your Full Name"

# Your email (appears in commits - use GitHub noreply for privacy)
git config --global user.email "username@users.noreply.github.com"
```

### Editor

```bash
# Set your preferred editor
git config --global core.editor "nano"        # Easy
git config --global core.editor "vim"         # Powerful
git config --global core.editor "code --wait" # VS Code
git config --global core.editor "subl -n -w"  # Sublime
```

### Default Branch

```bash
# Use 'main' instead of 'master' for new repos
git config --global init.defaultBranch main
```

### Pull Strategy

```bash
# Rebase when pulling (cleaner history)
git config --global pull.rebase true

# Or require explicit choice
git config --global pull.ff only
```

### Push Behavior

```bash
# Push current branch by default
git config --global push.default current

# Automatically set up tracking on first push
git config --global push.autoSetupRemote true
```

### Line Endings (Cross-Platform)

```bash
# On macOS/Linux: convert CRLF to LF on commit
git config --global core.autocrlf input

# On Windows: convert to CRLF on checkout, LF on commit
git config --global core.autocrlf true

# Warn about line ending issues
git config --global core.safecrlf warn
```

### Colors

```bash
# Enable colored output (usually default)
git config --global color.ui auto
```

---

## 📖 Aliases - Supercharge Your Git

Aliases save keystrokes and encode complex commands.

### Basic Aliases

```bash
# Short versions
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.sw switch

# Now use:
git co main      # instead of git checkout main
git br -a        # instead of git branch -a
git st           # instead of git status
```

### Useful Status/Log Aliases

```bash
# Pretty log with graph
git config --global alias.lg "log --oneline --graph --all"

# Even prettier
git config --global alias.lol "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Last commit
git config --global alias.last "log -1 HEAD"

# Short status
git config --global alias.s "status -s"

# Show branches with last commit
git config --global alias.branches "branch -vv"
```

### Undo Aliases

```bash
# Unstage files
git config --global alias.unstage "restore --staged"

# Discard changes
git config --global alias.discard "restore"

# Undo last commit (keep changes)
git config --global alias.uncommit "reset --soft HEAD~1"

# Amend without editing message
git config --global alias.amend "commit --amend --no-edit"
```

### Diff Aliases

```bash
# Staged changes
git config --global alias.staged "diff --staged"

# Word-level diff
git config --global alias.wdiff "diff --word-diff"

# Show changed files only
git config --global alias.changed "diff --name-only"
```

### Branch Cleanup

```bash
# Delete merged branches
git config --global alias.cleanup "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d"

# Prune remote-tracking branches
git config --global alias.prune-remote "remote prune origin"
```

### Complex Aliases (Shell Commands)

Aliases starting with `!` run shell commands:

```bash
# Find which branch contains a commit
git config --global alias.contains "!f() { git branch -a --contains \$1; }; f"

# Show all aliases
git config --global alias.aliases "config --get-regexp '^alias\\.'"

# Quick add, commit, push
git config --global alias.acp "!f() { git add -A && git commit -m \"\$1\" && git push; }; f"
# Usage: git acp "My commit message"

# Open current repo in browser (GitHub)
git config --global alias.browse "!open \$(git remote get-url origin | sed 's/git@/https:\\/\\//' | sed 's/.git$//' | sed 's/com:/com\\//')"
```

---

## 🔬 Hands-On Exercise 15.2: Set Up Aliases

```bash
# Add all the essentials
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "restore --staged"
git config --global alias.amend "commit --amend --no-edit"

# View your aliases
git config --get-regexp '^alias\.'

# Test them
cd ~/git-workshop
mkdir alias-test && cd alias-test
git init
echo "test" > file.txt
git add file.txt
git ci -m "Test commit"   # Uses alias!
git lg                     # Pretty log!
git last                   # Last commit details
```

---

## 📖 Merge and Diff Tools

### Configure External Diff Tool

```bash
# Use VS Code for diffs
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

# Use the tool
git difftool              # Opens VS Code for each changed file
git difftool --dir-diff   # Opens VS Code with directory comparison
```

### Configure External Merge Tool

```bash
# Use VS Code for merges
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Use P4Merge (popular free tool)
git config --global merge.tool p4merge
git config --global mergetool.p4merge.cmd 'p4merge $BASE $LOCAL $REMOTE $MERGED'
git config --global mergetool.p4merge.trustExitCode true

# Don't keep .orig backup files
git config --global mergetool.keepBackup false
```

### Using Merge Tool

```bash
# When you have conflicts
git merge feature-branch  # Conflict!
git mergetool             # Opens configured tool for each conflicted file
```

---

## 📖 Multiple Identities

When you work on personal and work projects:

### Method 1: Per-Repository Config

```bash
# In work repository
cd ~/work/project
git config user.email "you@company.com"
git config user.name "Your Name (Company)"

# In personal repository
cd ~/personal/project
git config user.email "you@personal.com"
git config user.name "Your Name"
```

### Method 2: Conditional Includes (Recommended)

In `~/.gitconfig`:

```ini
[user]
    name = Your Name
    email = personal@email.com

# Work projects (all repos under ~/work/)
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

# Open source (all repos under ~/opensource/)
[includeIf "gitdir:~/opensource/"]
    path = ~/.gitconfig-opensource
```

Create `~/.gitconfig-work`:
```ini
[user]
    email = you@company.com
    name = Your Name (Company)
    signingkey = WORK_GPG_KEY
```

---

## 🔬 Hands-On Exercise 15.3: View and Edit Config Directly

```bash
# Open global config in editor
git config --global --edit

# You'll see a file like:
```

```ini
[user]
    name = Your Name
    email = you@example.com

[core]
    editor = vim
    autocrlf = input

[init]
    defaultBranch = main

[pull]
    rebase = true

[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    lg = log --oneline --graph --all
    last = log -1 HEAD
    unstage = restore --staged
    amend = commit --amend --no-edit

[diff]
    tool = vscode

[difftool "vscode"]
    cmd = code --wait --diff $LOCAL $REMOTE
```

---

## 📖 Useful Configuration Options

### Performance

```bash
# Enable file system cache (Windows)
git config --global core.fscache true

# Parallel index operations
git config --global index.threads true

# Faster status in large repos
git config --global core.untrackedCache true
```

### Safety

```bash
# Require force-push to be explicit
git config --global push.default simple

# Warn about whitespace issues
git config --global core.whitespace trailing-space,space-before-tab

# Show more context in diffs
git config --global diff.context 5
```

### Credentials

```bash
# Cache credentials (in memory for 15 min)
git config --global credential.helper cache

# Cache for 1 hour
git config --global credential.helper 'cache --timeout=3600'

# Store credentials permanently (macOS Keychain)
git config --global credential.helper osxkeychain

# Store credentials (Windows)
git config --global credential.helper manager-core

# Store credentials (Linux - plaintext, less secure)
git config --global credential.helper store
```

---

## 📖 Useful Credential Configurations for Specific Hosts

```ini
# In ~/.gitconfig

# Different credentials for work GitLab
[credential "https://gitlab.company.com"]
    username = work-username

# GitHub with token
[credential "https://github.com"]
    helper = osxkeychain
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What are the three levels of Git configuration?

2. **Q:** Which level overrides the others?

3. **Q:** How do you create an alias for `git log --oneline`?

4. **Q:** How do you view all your configured aliases?

5. **Q:** What's the benefit of conditional includes?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** System, Global, and Local

2. **A:** Local overrides Global, Global overrides System

3. **A:** `git config --global alias.lo "log --oneline"`

4. **A:** `git config --get-regexp '^alias\.'` or `git config --global -l | grep alias`

5. **A:** Different settings for different project directories (e.g., work vs personal email)

</details>

---

## 🎯 Recommended Initial Setup

```bash
# Run these to set up a good Git environment:

# Identity
git config --global user.name "Your Name"
git config --global user.email "you@email.com"

# Editor
git config --global core.editor "nano"  # or vim, code --wait

# Default branch
git config --global init.defaultBranch main

# Pull strategy
git config --global pull.rebase true

# Push behavior
git config --global push.autoSetupRemote true

# Essential aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "restore --staged"
git config --global alias.amend "commit --amend --no-edit"

# Safety
git config --global core.autocrlf input  # or 'true' on Windows
```

---

## 🚀 What's Next?

In **Module 17: Authentication**, we'll learn:
- SSH vs HTTPS for Git operations
- Setting up SSH keys for GitHub/GitLab
- Credential helpers and security
