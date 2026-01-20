# Module 13: History Investigation - Detective Work

## 🎯 Learning Objectives

After this module, you will:
- Master advanced git log techniques
- Use git blame to find who changed what and when
- Use git bisect to find bug-introducing commits
- Understand how to search through history

---

## 🏠 The Detective Metaphor

Git history is like a crime scene. You have tools to investigate:

| Tool | Detective Equivalent |
|------|---------------------|
| `git log` | Case timeline - when did things happen? |
| `git blame` | Fingerprint analysis - who touched this? |
| `git bisect` | Binary search - narrow down the suspect |
| `git show` | Evidence examination - what exactly happened? |

---

## 📖 Deep Dive: Advanced git log

### Formatting Options

```bash
# Pretty formats
git log --oneline                    # Short hash + message
git log --format=short               # Hash, author, message
git log --format=medium              # + date (default)
git log --format=full                # + committer
git log --format=fuller              # + both dates

# Custom format
git log --format="%h %an (%ar): %s"
# abc123 John Doe (2 days ago): Fix bug

# Format placeholders:
# %H - full hash       %h - short hash
# %an - author name    %ae - author email
# %ar - relative date  %ad - author date
# %cn - committer      %s - subject (message)
# %b - body
```

### Filtering Options

```bash
# By count
git log -5                           # Last 5 commits

# By date
git log --since="2024-01-01"
git log --until="2024-06-30"
git log --since="2 weeks ago"
git log --after="yesterday"

# By author
git log --author="John"
git log --author="john@example.com"

# By commit message
git log --grep="fix"
git log --grep="JIRA-123"

# By file
git log -- path/to/file.js
git log --follow -- old-name.js      # Follow renames

# By content (when was this string added/removed?)
git log -S "function login"          # Pickaxe search
git log -G "TODO.*fixme"             # Regex search

# Merge commits
git log --merges                     # Only merges
git log --no-merges                  # Exclude merges

# Combine filters
git log --author="John" --since="2024-01-01" --grep="fix" -- src/
```

---

## 🔬 Hands-On Exercise 11.1: Log Investigation

```bash
# Setup a repo with some history
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create history
echo "version 1" > app.js
git add app.js
git commit -m "Initial app" --date="2024-01-01 10:00:00"

echo "function login() {}" >> app.js
git add app.js
git commit -m "Add login function" --date="2024-01-15 10:00:00"

git config user.name "John Doe"
echo "function logout() {}" >> app.js
git add app.js
git commit -m "JIRA-123: Add logout" --date="2024-02-01 10:00:00"

git config user.name "Jane Smith"
echo "// TODO: fix this" >> app.js
git add app.js
git commit -m "WIP: Working on feature" --date="2024-02-15 10:00:00"

# Reset author for remaining exercises
git config --unset user.name

# Now investigate!

# Find all commits by John
git log --author="John" --oneline

# Find commits mentioning JIRA
git log --grep="JIRA" --oneline

# Find when "login" was added
git log -S "login" --oneline

# Find commits in January 2024
git log --since="2024-01-01" --until="2024-01-31" --oneline

# Show which files changed
git log --oneline --name-only

# Show statistics
git log --oneline --stat
```

---

## 📖 Deep Dive: git blame

`git blame` shows who last modified each line of a file.

```bash
git blame file.js

# Output:
# abc123 (John Doe  2024-01-15 10:00:00 +0100  1) version 1
# def456 (John Doe  2024-01-15 10:00:00 +0100  2) function login() {}
# ghi789 (Jane Smith 2024-02-01 10:00:00 +0100  3) function logout() {}
```

### Blame Options

```bash
# Show email instead of name
git blame -e file.js

# Show short commit hash
git blame -s file.js

# Limit to specific lines
git blame -L 10,20 file.js    # Lines 10-20
git blame -L 10,+5 file.js    # 5 lines starting at 10
git blame -L /function/,+10   # From "function" pattern + 10 lines

# Ignore whitespace changes
git blame -w file.js

# Detect moved/copied lines within file
git blame -M file.js

# Detect moved/copied from other files
git blame -C file.js

# Show the actual commit that introduced the line
git blame -l file.js    # Full hash for reference
```

---

## 🔬 Hands-On Exercise 11.2: Using Blame

```bash
# See who wrote what
git blame app.js

# Focus on specific lines
git blame -L 2,3 app.js

# When was the TODO added?
git blame app.js | grep "TODO"
# Shows the commit hash, author, date

# Get more details about that commit
git show <commit-hash>

# Ignore whitespace (useful for reformatted files)
git blame -w app.js
```

---

## 📖 Deep Dive: git bisect

`git bisect` uses binary search to find which commit introduced a bug.

```
You know:
- Commit A (old): working fine ✓
- Commit Z (new): broken ✗

Between them: A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-P-Q-R-S-T-U-V-W-X-Y-Z

Instead of checking 26 commits one by one,
bisect checks: M (middle) → good/bad?
Then:          G or T (new middle) → good/bad?
...

In ~5 checks, you find the exact commit!
log₂(26) ≈ 5 vs. 26 linear checks
```

---

## 🔬 Hands-On Exercise 11.3: Using Bisect

```bash
# Create a repo with a "bug" introduced somewhere
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create many commits, one introduces a bug
for i in {1..10}; do
  echo "version $i" > file.txt
  git add file.txt
  git commit -m "Commit $i"
done

# Simulate "bug" was introduced in commit 6 by adding "BUG"
git log --oneline
# Find commit 6's hash and amend it (for simulation)
# For this exercise, let's just know commit 6 is bad

# Start bisect
git bisect start

# Current HEAD is bad
git bisect bad

# Commit 1 was good (use actual hash)
git log --oneline | tail -1   # Get first commit hash
git bisect good <first-commit-hash>

# Git checks out middle commit
# You test it. Let's say commit 5 is still "good"
# Check: git log --oneline -1
# If commit <= 5: git bisect good
# If commit >= 6: git bisect bad

# Continue until Git tells you "abc123 is the first bad commit"

# When done:
git bisect reset   # Go back to where you were
```

### Automating Bisect

```bash
# If you have a test script that exits 0 for good, non-zero for bad:
git bisect start
git bisect bad HEAD
git bisect good <old-good-commit>
git bisect run ./test-script.sh

# Git runs the script at each step automatically!
```

---

## 📖 Theory: Other Investigation Tools

### git show
```bash
# Show a commit
git show abc123

# Show a file at specific commit
git show abc123:path/to/file.js

# Show changes in a merge commit
git show --stat abc123
```

### git diff (for history)
```bash
# Difference between two commits
git diff abc123..def456

# What changed on branch since it diverged
git diff main...feature

# Diff specific file between commits
git diff abc123..def456 -- file.js
```

### git shortlog
```bash
# Summary of commits by author
git shortlog -sn
#  42  John Doe
#  38  Jane Smith
#  15  Bob Wilson
```

---

## 🔬 Hands-On Exercise 11.4: What Your IDE Does

```bash
# When you right-click a file → "Annotate" / "Show History":
git blame file.js
git log --follow -- file.js

# When you click on a blame annotation:
git show <commit-hash>

# When IDE shows file history with diffs:
git log -p -- file.js

# When you compare a file between versions:
git diff <commit1>..<commit2> -- file.js

# When you "Find in Path" with history:
git log -S "search term" --all
```

---

## 📖 Pro Tips: Investigation Workflows

### "Who broke this?"
```bash
git blame file.js                    # Find the commit
git show <commit>                    # See what they did
git log --author="Name" --oneline    # Check their other commits
```

### "When did this behavior change?"
```bash
git log -S "function behavior"       # When was this code added/removed
git bisect start                     # Binary search if unclear
```

### "What changed between versions?"
```bash
git diff v1.0..v2.0                 # All changes
git diff v1.0..v2.0 --stat          # Summary
git log v1.0..v2.0 --oneline        # Commit list
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** How do you find commits that mention "JIRA-123" in the message?

2. **Q:** How do you see when a specific string was added to the codebase?

3. **Q:** What does git bisect do?

4. **Q:** How do you see who last modified line 42 of a file?

5. **Q:** What's the difference between `git log -S` and `git log --grep`?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `git log --grep="JIRA-123"`

2. **A:** `git log -S "the string"` (pickaxe search)

3. **A:** Uses binary search to find which commit introduced a bug. You mark commits as good/bad and it narrows down.

4. **A:** `git blame -L 42,42 file.js` or just `git blame file.js` and look at line 42

5. **A:** `-S` searches in file content changes. `--grep` searches in commit messages.

</details>

---

## 🎯 Investigation Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    INVESTIGATION COMMANDS                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LOG FILTERING                                                  │
│  git log --author="Name"       By author                        │
│  git log --grep="text"         By commit message                │
│  git log -S "code"             When code was added/removed      │
│  git log --since="date"        After date                       │
│  git log -- path/file          Changes to specific file         │
│                                                                 │
│  BLAME                                                          │
│  git blame file.js             Who last changed each line       │
│  git blame -L 10,20 file.js    Specific line range              │
│  git blame -w file.js          Ignore whitespace                │
│                                                                 │
│  BISECT                                                         │
│  git bisect start              Begin binary search              │
│  git bisect bad                Current is broken                │
│  git bisect good <commit>      This was working                 │
│  git bisect reset              End and go back                  │
│  git bisect run ./test.sh      Automate with script             │
│                                                                 │
│  COMPARISON                                                     │
│  git diff A..B                 Changes from A to B              │
│  git diff A...B                Changes on B since common base   │
│  git show <commit>             Details of one commit            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 14: Best Practices**, we'll cover:
- Conventional commits
- Feature branch workflow
- Linear history
- Professional Git habits
