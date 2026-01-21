# Module 3: Basic Commands - The Daily Bread

## 🎯 Learning Objectives

After this module, you will:
- Master `git status` and read it fluently
- Understand all variants of `git diff`
- Use `git log` like a detective
- Know what your IDE is doing with each click

---

## 📖 Theory: The Command Categories

Git commands generally do one of these things:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  INSPECT                MOVE DATA              MANIPULATE       │
│  ───────                ─────────              ──────────       │
│  status                 add                    commit           │
│  diff                   restore               reset             │
│  log                    switch/checkout       revert            │
│  show                   stash                 rebase            │
│  blame                  merge                 cherry-pick       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

Today we focus on **INSPECT** commands - understanding before acting.

---

## 📖 Deep Dive: git status

### The Four Possible States of a File

```
┌─────────────────────────────────────────────────────────────────┐
│                     FILE LIFECYCLE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    git add    ┌──────────┐    git commit          │
│  │UNTRACKED │──────────────>│ STAGED   │─────────────────┐      │
│  │(new file)│               │          │                 │      │
│  └──────────┘               └──────────┘                 │      │
│       ▲                          ▲                       ▼      │
│       │                          │               ┌──────────┐   │
│   create                     git add             │COMMITTED │   │
│   new file                       │               │(unmodified)  │
│       │                          │               └──────────┘   │
│       │                    ┌──────────┐                 │       │
│       │                    │ MODIFIED │<────────────────┘       │
│       │                    │          │    edit file            │
│       └────────────────────┴──────────┘                         │
│                               git rm                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Reading git status Output

```bash
$ git status

On branch main                           # Where HEAD points
Your branch is ahead of 'origin/main'    # vs remote tracking branch
by 2 commits.

Changes to be committed:                 # STAGED (green in IDE)
  (use "git restore --staged <file>..." to unstage)
        modified:   app.js
        new file:   utils.js

Changes not staged for commit:           # MODIFIED but not staged (red)
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   config.json

Untracked files:                         # NEW files Git doesn't know
  (use "git add <file>..." to include in what will be committed)
        temp.log
        notes.txt
```

---

## 🔬 Hands-On Exercise 3.1: Understanding Status

```bash
# Fresh start
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create initial structure
echo "# My Project" > README.md
echo "config=value" > config.txt
git add .
git commit -m "Initial commit"

# Now let's create all four states at once:

# 1. MODIFIED (not staged) - edit existing tracked file
echo "new config" >> config.txt

# 2. STAGED - add a modification
echo "## Description" >> README.md
git add README.md

# 3. UNTRACKED - create new file
echo "console.log('hi')" > app.js

# 4. Now check status
git status

# You should see all three sections:
# - Changes to be committed (README.md)
# - Changes not staged (config.txt)
# - Untracked files (app.js)
```

---

## 📖 Deep Dive: git diff

### The Three Comparisons

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   WORKING    │     │   STAGING    │     │    LAST      │
│  DIRECTORY   │     │    AREA      │     │   COMMIT     │
└──────────────┘     └──────────────┘     └──────────────┘
       │                    │                    │
       │   git diff         │                    │
       ├───────────────────>│                    │
       │                    │                    │
       │          git diff --staged              │
       │                    ├───────────────────>│
       │                    │                    │
       │              git diff HEAD              │
       ├────────────────────────────────────────>│
       │                    │                    │
```

| Command | Compares | Use When |
|---------|----------|----------|
| `git diff` | Working Dir vs Staging | "What would `git add` stage?" |
| `git diff --staged` | Staging vs Last Commit | "What will my next commit include?" |
| `git diff HEAD` | Working Dir vs Last Commit | "All my changes since last commit" |

---

## 🔬 Hands-On Exercise 3.2: Mastering Diff

```bash
# Continuing from previous exercise

# 1. See unstaged changes (config.txt)
git diff
# Shows config.txt changes (red/green lines)

# 2. See staged changes (README.md)
git diff --staged
# Shows README.md changes

# 3. See ALL changes vs last commit
git diff HEAD
# Shows both files

# 4. Diff specific file
git diff config.txt

# 5. Now let's make it interesting - modify a staged file again
echo "## Installation" >> README.md  # README is already staged!

git status
# README.md appears in BOTH sections!

git diff           # Shows the NEW change (not staged)
git diff --staged  # Shows the ORIGINAL staged change

# This is why IDE shows files in multiple colors sometimes!
```

---

## 📖 Deep Dive: git log

### Useful Log Formats

```bash
# Basic log
git log

# Compact one-liner
git log --oneline

# With graph (essential for branches!)
git log --oneline --graph

# All branches, not just current
git log --oneline --graph --all

# With stats (what files changed)
git log --stat

# With actual diff
git log -p

# Last N commits
git log -3

# Search commit messages
git log --grep="fix"

# Search by author
git log --author="John"

# Search by date
git log --since="2024-01-01" --until="2024-01-31"

# Changes to specific file
git log -- path/to/file

# Show diff for specific file
git log -p -- path/to/file
```

---

## 🔬 Hands-On Exercise 3.3: Log Detective Work

```bash
# Let's create some history to explore
git add .
git commit -m "Add app and update config"

echo "function helper() {}" >> app.js
git add app.js
git commit -m "Add helper function"

git branch feature-auth
git checkout feature-auth

echo "auth code" > auth.js
git add auth.js
git commit -m "Add authentication"

git checkout main
echo "more stuff" >> README.md
git add README.md
git commit -m "Update readme"

# Now explore!

# 1. Basic log
git log

# 2. Compact view
git log --oneline

# 3. THE MOST USEFUL COMMAND - graph all branches
git log --oneline --graph --all

# You'll see something like:
# * abc123 (HEAD -> main) Update readme
# | * def456 (feature-auth) Add authentication
# |/
# * 789ghi Add helper function
# * ...

# 4. What changed in each commit?
git log --oneline --stat

# 5. Who wrote what?
git log --format="%h %an: %s"
# Shows: hash author-name: message

# 6. Follow a specific file
git log --oneline -- config.txt
```

---

## 📖 Deep Dive: git show

The `show` command shows a specific object:

```bash
# Show a commit (default is HEAD)
git show

# Show specific commit
git show abc123

# Show a file at a specific commit
git show abc123:config.txt

# Show what's on a branch
git show feature-auth

# Show just the files that changed
git show --stat abc123

# Show just the message and stats (no diff)
git show --no-patch --stat abc123
```

---

## 🔬 Hands-On Exercise 3.4: IDE Translation

Let's understand what your IDE does:

```bash
# When IDE shows "Local Changes" panel:
git status
git diff

# When you hover over a file to see changes:
git diff -- <that-file>

# When you right-click → "Show History":
git log --follow -- <that-file>

# When you click on a commit in history:
git show <commit-hash>

# When IDE shows "X commits ahead/behind origin":
git rev-list --left-right --count origin/main...main
# Output: "0    2" means 0 behind, 2 ahead

# When IDE shows modified lines in the editor gutter:
git diff -- <current-file>  # (parsed and shown inline)

# When IDE shows "Compare with Branch...":
git diff main...feature-branch

# When you click "Annotate" or "Blame":
git blame <file>
```

---

## 📖 Bonus: The Shorthand Status

For quick checks, use `-s` (short) flag:

```bash
$ git status -s

 M config.txt      # Modified, not staged (space + M)
M  README.md       # Modified and staged (M + space)
MM package.json    # Modified, staged, AND modified again!
?? temp.log        # Untracked
A  new-file.js     # Added (new file, staged)
D  old-file.js     # Deleted
R  old.js -> new.js # Renamed
```

**Position matters:**
- First column = staged status
- Second column = working directory status

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** How do you see changes that will be in your next commit?

2. **Q:** A file appears in both "staged" and "modified" sections. What happened?

3. **Q:** What command shows all branches as a graph?

4. **Q:** What does `git show HEAD~2:app.js` display?

5. **Q:** In short status `MM file.txt`, what does each M mean?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `git diff --staged` (or `--cached`)

2. **A:** You staged the file, then modified it again without re-staging

3. **A:** `git log --oneline --graph --all`

4. **A:** The content of app.js as it was 2 commits before HEAD

5. **A:** First M = staged changes, Second M = unstaged changes (file was modified, staged, then modified again)

</details>

---

## 🎯 Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│                    DAILY COMMANDS CHEAT SHEET                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  STATUS & DIFF                                                  │
│  git status              What's the current state?              │
│  git status -s           Short format                           │
│  git diff                Unstaged changes                       │
│  git diff --staged       Staged changes (will be committed)     │
│  git diff HEAD           All changes since last commit          │
│                                                                 │
│  HISTORY                                                        │
│  git log --oneline       Compact history                        │
│  git log --graph --all   Visual branch graph                    │
│  git log -p              With diffs                             │
│  git log -- <file>       History of one file                    │
│  git show <commit>       Details of one commit                  │
│  git blame <file>        Who wrote each line                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 4: Mastering .gitignore**, we'll learn:
- Patterns and syntax for ignoring files
- Root references and directory patterns
- How to keep empty directories
- Debugging with `git check-ignore`
