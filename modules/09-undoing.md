# Module 9: Undoing Things - The Safety Net

## 🎯 Learning Objectives

After this module, you will:
- Master reset (soft, mixed, hard)
- Understand when to use revert vs reset
- Recover files with restore
- Know what your IDE's "Revert" button actually does

---

## 🏠 The Document Editor Metaphor

Imagine you're writing a document with auto-save versions:

| Git Command | Document Editor Action |
|-------------|----------------------|
| `git reset --soft` | Move the "current version" marker, but keep all edits ready to save again |
| `git reset --mixed` | Move marker, edits are still there but need to be re-selected for saving |
| `git reset --hard` | Move marker AND delete all unsaved edits (use saved version) |
| `git revert` | Keep all history, but add a NEW save that undoes changes |
| `git restore` | Discard edits on ONE file, get the saved version |

---

## 📖 Theory: The Three Resets

Understanding reset requires remembering the three areas:

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│    Working Directory        Staging Area         Repository      │
│    (what you see)           (index)              (commits)       │
│                                                                  │
│    ┌─────────────┐         ┌─────────────┐      ┌─────────────┐  │
│    │  file.txt   │         │  file.txt   │      │  Commit A   │  │
│    │  (edited)   │         │  (staged)   │      │  file.txt   │  │
│    └─────────────┘         └─────────────┘      └─────────────┘  │
│                                                                  │
│    ───────────────────────────────────────────────────────────── │
│                                                                  │
│    reset --soft HEAD~1                               ← moves only│
│    reset --mixed HEAD~1                   ← ──────── ← resets    │
│    reset --hard HEAD~1   ← ────────────── ← ──────── ← resets ALL│
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📖 Theory: Reset Modes Explained

### --soft: Just move HEAD
```
BEFORE:        A ── B ── C (HEAD)
AFTER:         A ── B (HEAD)  ── C (orphaned, changes still staged!)

Working Dir: unchanged
Staging:     unchanged (C's changes are staged!)
HEAD:        moved back
```
**Use case:** "I want to redo my last commit with a different message or add more changes"

### --mixed: Move HEAD, unstage (DEFAULT)
```
BEFORE:        A ── B ── C (HEAD)
AFTER:         A ── B (HEAD)  ── C (orphaned)

Working Dir: unchanged (still has C's changes!)
Staging:     reset to match B
HEAD:        moved back
```
**Use case:** "I want to uncommit AND unstage, but keep my work"

### --hard: Move HEAD, unstage, discard changes
```
BEFORE:        A ── B ── C (HEAD)
AFTER:         A ── B (HEAD)  ── C (orphaned)

Working Dir: reset to match B (changes GONE!)
Staging:     reset to match B
HEAD:        moved back
```
**Use case:** "Throw everything away, go back to this commit" (DANGEROUS!)

---

## 🔬 Hands-On Exercise 7.1: Understanding Reset

```bash
# Fresh start
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create history
echo "version 1" > file.txt
git add file.txt
git commit -m "A: First version"

echo "version 2" > file.txt
git add file.txt
git commit -m "B: Second version"

echo "version 3" > file.txt
git add file.txt
git commit -m "C: Third version"

# Check current state
git log --oneline
cat file.txt  # Shows "version 3"

# Now let's experiment with reset modes

# 1. SOFT reset - move HEAD only
git reset --soft HEAD~1

git status
# "Changes to be committed: modified file.txt"
# The changes from C are STAGED!

cat file.txt
# Still shows "version 3"!

git log --oneline
# Only shows A and B

# Undo our reset to try again
git reset --soft HEAD@{1}  # Go back to where we were

# 2. MIXED reset (default) - move HEAD, unstage
git reset HEAD~1   # --mixed is default

git status
# "Changes not staged for commit: modified file.txt"

cat file.txt
# Still shows "version 3"!

git log --oneline
# Only shows A and B

# Undo again
git add file.txt
git commit -m "C: Third version"

# 3. HARD reset - discard everything
git reset --hard HEAD~1

git status
# "nothing to commit, working tree clean"

cat file.txt
# Shows "version 2" - version 3 is GONE!

git log --oneline
# Only shows A and B
```

---

## 📖 Theory: Reset vs Revert

| | Reset | Revert |
|---|-------|--------|
| Modifies history? | Yes (removes commits) | No (adds new commit) |
| Safe for shared branches? | NO | YES |
| Creates new commit? | No | Yes |
| Can affect multiple commits? | Yes | Usually one at a time |
| Working directory? | Depends on mode | Applies inverse changes |

```
RESET:
A ── B ── C    →    A ── B (C is removed from history)

REVERT:
A ── B ── C    →    A ── B ── C ── C' (C' undoes C's changes)
```

---

## 🔬 Hands-On Exercise 7.2: Using Revert

```bash
# Continue from previous (at commit B)

# Add more commits
echo "version 3 new" > file.txt
git add file.txt
git commit -m "C: New third version"

echo "version 4" > file.txt
git add file.txt
git commit -m "D: Fourth version"

git log --oneline
# aaa D: Fourth version
# bbb C: New third version
# ccc B: Second version
# ddd A: First version

# Now, revert commit C (the third version)
git revert bbb   # Use your actual hash for C

# Editor opens for revert commit message
# Default: "Revert 'C: New third version'"
# Save and close

git log --oneline
# eee Revert "C: New third version"
# aaa D: Fourth version
# bbb C: New third version
# ...

# Check the file
cat file.txt
# Content depends on what C changed

# The key: commit C is STILL in history!
# We just added a new commit that undoes it.
```

---

## 🔬 Hands-On Exercise 7.3: Using Restore

`restore` is for getting files back (without changing commits):

```bash
# Make some changes
echo "experimental stuff" > file.txt
echo "new file" > new.txt
git add new.txt

git status
# modified: file.txt (not staged)
# new file: new.txt (staged)

# RESTORE working directory file (discard changes)
git restore file.txt

cat file.txt
# Back to the committed version!

# RESTORE staged file (unstage it)
git restore --staged new.txt

git status
# new.txt is now untracked

# RESTORE file from a specific commit
git restore --source HEAD~2 file.txt

cat file.txt
# Shows content from 2 commits ago!
# (But this is a working directory change - not committed)
```

---

## 📖 The restore Command Explained

```bash
# Discard working directory changes
git restore <file>
git restore .                    # All files

# Unstage a file (keep working dir changes)
git restore --staged <file>

# Both: unstage AND discard
git restore --staged --worktree <file>

# Get file from specific commit
git restore --source <commit> <file>
git restore --source HEAD~3 app.js
```

---

## 🔬 Hands-On Exercise 7.4: What Your IDE Does

```bash
# When you right-click a file → "Revert":
# IDE might mean different things!

# If file is MODIFIED (not staged):
git restore <file>           # Discard changes

# If file is STAGED:
git restore --staged <file>  # Unstage (keep changes)

# When you right-click a COMMIT → "Revert Commit":
git revert <commit-hash>

# When you right-click a COMMIT → "Reset Current Branch to Here":
git reset <commit-hash>      # Default: --mixed
# or with option:
git reset --hard <commit-hash>

# When you "Undo Last Commit" (keeping changes):
git reset --soft HEAD~1

# When you use "Drop Commit" in interactive rebase:
git rebase -i
# Then "drop" that commit
```

---

## 📖 Emergency Recovery: Reflog

Even after `git reset --hard`, you can often recover!

```bash
# See where HEAD has been
git reflog

# Output:
# abc123 HEAD@{0}: reset: moving to HEAD~1
# def456 HEAD@{1}: commit: Accidentally deleted  ← HERE!
# ghi789 HEAD@{2}: commit: Previous commit

# Go back to the "lost" commit
git reset --hard HEAD@{1}
# or
git reset --hard def456

# Your lost commit is back!
```

**Reflog** = Reference log. Git keeps track of where HEAD has been for ~90 days.

---

## 🔬 Hands-On Exercise 7.5: Reflog Recovery

```bash
# Create a commit we'll "lose"
echo "important work" > important.txt
git add important.txt
git commit -m "Important work"

# Record the hash
git log --oneline -1

# Accidentally reset --hard
git reset --hard HEAD~1

# Oh no! important.txt is gone!
ls  # No important.txt

# Check reflog
git reflog
# Shows the reset, and before it, our commit!

# Recover
git reset --hard HEAD@{1}

# It's back!
ls  # important.txt is there!
cat important.txt
```

---

## 📖 Quick Decision Guide

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHAT DO YOU WANT TO UNDO?                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  "I want to discard changes to a file"                          │
│  → git restore <file>                                           │
│                                                                 │
│  "I want to unstage a file"                                     │
│  → git restore --staged <file>                                  │
│                                                                 │
│  "I want to redo my last commit (change message or add files)"  │
│  → git reset --soft HEAD~1  (then recommit)                     │
│  OR: git commit --amend                                         │
│                                                                 │
│  "I want to uncommit but keep changes for different commits"    │
│  → git reset HEAD~1  (mixed, keeps changes unstaged)            │
│                                                                 │
│  "I want to throw away my last commit completely"               │
│  → git reset --hard HEAD~1  (DANGEROUS! Changes lost!)          │
│                                                                 │
│  "I need to undo a commit that's been pushed/shared"            │
│  → git revert <commit>  (safe, creates new commit)              │
│                                                                 │
│  "I accidentally reset --hard and lost work!"                   │
│  → git reflog  (find the commit, then reset --hard to it)       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What's the difference between reset --soft and --mixed?

2. **Q:** When should you use revert instead of reset?

3. **Q:** What command unstages a file but keeps your changes?

4. **Q:** How can you recover after an accidental `reset --hard`?

5. **Q:** What does `git reset HEAD~3` do? (Note: no mode specified)

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** --soft keeps changes staged, --mixed keeps changes but unstaged (working directory only)

2. **A:** When the commits have been pushed/shared. Revert is safe for public history.

3. **A:** `git restore --staged <file>`

4. **A:** Use `git reflog` to find where HEAD was before, then `git reset --hard <that-ref>`

5. **A:** Uses --mixed (default). Moves HEAD back 3 commits, changes are in working dir but unstaged.

</details>

---

## 🎯 Undo Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNDO COMMANDS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  DISCARD / RESTORE                                              │
│  git restore <file>            Discard working dir changes      │
│  git restore --staged <file>   Unstage (keep changes)           │
│  git restore --source X <file> Get file from commit X           │
│                                                                 │
│  RESET (move HEAD)                                              │
│  git reset --soft HEAD~1       Uncommit, keep staged            │
│  git reset HEAD~1              Uncommit, keep unstaged          │
│  git reset --hard HEAD~1       Uncommit, DISCARD all            │
│                                                                 │
│  REVERT (safe for shared)                                       │
│  git revert <commit>           Create undo commit               │
│  git revert -n <commit>        Revert without committing        │
│                                                                 │
│  RECOVERY                                                       │
│  git reflog                    See HEAD history                 │
│  git reset --hard HEAD@{N}     Go back to Nth previous state    │
│                                                                 │
│  AMEND (fix last commit)                                        │
│  git commit --amend            Edit last commit                 │
│  git commit --amend --no-edit  Add staged to last commit        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 10: Remote Operations**, we'll learn:
- `fetch` vs `pull`
- Tracking branches
- Collaboration workflows
