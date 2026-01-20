# Module 11: Stash - The Pocket Dimension

## 🎯 Learning Objectives

After this module, you will:
- Use stash to temporarily save work in progress
- Manage multiple stashes
- Apply stashes selectively
- Know when stash is (and isn't) the right tool

---

## 🏠 The Magic Drawer Metaphor

Imagine you're working at a desk with papers everywhere. Your boss walks in and needs you to do something urgent.

```
┌─────────────────────────────────────────────────────────────────┐
│                          YOUR DESK                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│   Papers everywhere!          git stash          Clean desk!    │
│   ┌────┐ ┌────┐ ┌────┐       ─────────>         ┌──────────┐    │
│   │    │ │    │ │    │                          │          │    │
│   └────┘ └────┘ └────┘                          │ (empty)  │    │
│                                                  └──────────┘    │
│          ║                                                       │
│          ║                   git stash pop                       │
│          ▼                   <───────────                        │
│   ┌─────────────┐                                               │
│   │ MAGIC       │  You can have multiple drawers!               │
│   │ DRAWER      │  stash@{0}, stash@{1}, stash@{2}...          │
│   │ (invisible) │                                               │
│   └─────────────┘                                               │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

**The magic:**
- Papers go into a hidden drawer
- Desk looks clean (git says "working tree clean")
- Later, you pull papers back out
- You can have MULTIPLE drawers!

---

## 📖 Theory: What Stash Does

Stash saves:
1. **Staged changes** (things you've `git add`ed)
2. **Unstaged changes** to tracked files
3. Optionally: untracked files (with `-u`)
4. Optionally: ignored files too (with `-a`)

```
BEFORE git stash:
Working Dir: modified file1.txt (staged)
             modified file2.txt (unstaged)
             new_file.txt (untracked)

AFTER git stash:
Working Dir: clean! (matches last commit)
Stash: contains file1.txt and file2.txt changes
       (new_file.txt NOT included unless you use -u)
```

---

## 🔬 Hands-On Exercise 10.1: Basic Stash

```bash
# Fresh start
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create initial commit
echo "original content" > file.txt
git add file.txt
git commit -m "Initial commit"

# Make some changes (work in progress)
echo "work in progress" >> file.txt
echo "staged change" > staged.txt
git add staged.txt

git status
# Changes to be committed:
#   new file: staged.txt
# Changes not staged:
#   modified: file.txt

# Suddenly need to switch branches for urgent work!
# But current work isn't ready to commit...

# STASH it!
git stash

git status
# nothing to commit, working tree clean

# Changes are GONE from working directory!
cat file.txt
# original content (back to committed version!)

ls
# file.txt (staged.txt is gone!)

# See stash list
git stash list
# stash@{0}: WIP on main: abc123 Initial commit
```

---

## 🔬 Hands-On Exercise 10.2: Getting Stash Back

```bash
# Now you can do your urgent work...
echo "urgent fix" > urgent.txt
git add urgent.txt
git commit -m "Urgent fix"

# Done with urgent work. Get your WIP back!

# Option 1: pop (apply AND remove from stash)
git stash pop

# Option 2: apply (apply but KEEP in stash)
git stash apply

# Let's use pop
git stash pop

git status
# Changes to be committed:
#   new file: staged.txt
# Changes not staged:
#   modified: file.txt

# Everything is back!
cat file.txt
# original content
# work in progress

git stash list
# (empty - pop removed it)
```

---

## 🔬 Hands-On Exercise 10.3: Multiple Stashes

```bash
# Make changes
echo "first work" >> file.txt
git stash push -m "First piece of work"

# Make different changes
echo "second work" >> file.txt
git stash push -m "Second piece of work"

# Make more changes
echo "third work" >> file.txt
git stash push -m "Third piece of work"

# List stashes (LIFO - most recent first)
git stash list
# stash@{0}: On main: Third piece of work
# stash@{1}: On main: Second piece of work
# stash@{2}: On main: First piece of work

# Apply specific stash (doesn't remove it)
git stash apply stash@{1}   # Gets "Second piece of work"

# Pop specific stash (applies AND removes)
git stash pop stash@{2}     # Gets "First piece of work"

# Drop a stash without applying
git stash drop stash@{0}    # Removes "Third piece of work"

# Clear all stashes (DANGEROUS!)
git stash clear
```

---

## 🔬 Hands-On Exercise 10.4: Stash Options

```bash
# Stash with a descriptive message
git stash push -m "WIP: Login feature - need to fix validation"

# Much better than:
# stash@{0}: WIP on main: abc123 Some old commit message

# Include untracked files
echo "new untracked file" > untracked.txt
git stash -u   # or --include-untracked

# Include EVERYTHING (even ignored files)
git stash -a   # or --all

# Stash only specific files
git stash push -m "Only these files" file1.txt file2.txt

# Stash but keep staged changes
git stash --keep-index
# Useful when you've staged what you want to commit,
# but want to stash the unstaged stuff
```

---

## 🔬 Hands-On Exercise 10.5: Stash as a Branch

```bash
# Sometimes stash conflicts when you try to pop
# Solution: Create a branch from the stash

# Create some changes and stash them
echo "feature work" >> file.txt
git stash push -m "Feature work"

# Imagine main has moved and now conflicts with your stash
echo "conflicting change" >> file.txt
git add file.txt
git commit -m "Conflicting change"

# Pop would cause conflict. Instead:
git stash branch new-feature-branch stash@{0}

# This:
# 1. Creates new branch from where stash was created
# 2. Checks out that branch
# 3. Applies the stash
# 4. Drops the stash
# Perfect recovery!
```

---

## 🔬 Hands-On Exercise 10.6: Viewing Stash Contents

```bash
# Make and stash some changes
echo "changes" >> file.txt
git stash push -m "Some changes"

# View stash summary
git stash show
# file.txt | 1 +
# 1 file changed, 1 insertion(+)

# View stash with full diff
git stash show -p
# Shows actual diff content

# View specific stash
git stash show -p stash@{1}
```

---

## 📖 Theory: When to Use (and NOT Use) Stash

### Use Stash When ✅

1. **Need to quickly switch branches**
   ```bash
   # In middle of work on feature
   git stash
   git switch main
   # Handle urgent thing
   git switch feature
   git stash pop
   ```

2. **Want to try something and might throw it away**
   ```bash
   git stash   # Save current approach
   # Try new approach
   # If it works: git stash drop
   # If not: git stash pop (go back to saved)
   ```

3. **Pulling when you have local changes**
   ```bash
   git stash
   git pull
   git stash pop
   ```

### Avoid Stash When ⚠️

1. **Work will take more than a few hours** → Commit it on a WIP branch instead
   ```bash
   git switch -c wip/my-feature
   git add .
   git commit -m "WIP: checkpoint"
   ```

2. **You need to share the work** → Stash is local only!

3. **Changes are complex** → Easy to forget what's stashed

---

## 🔬 Hands-On Exercise 10.7: What Your IDE Does

```bash
# When you click "Stash Changes" (or Shelve):
git stash push -m "description"

# When you click "Unstash" or "Pop":
git stash pop

# When you see the Stash list in IDE:
git stash list

# When you click "Apply" on a specific stash:
git stash apply stash@{N}

# When you click "Drop" on a specific stash:
git stash drop stash@{N}

# When IDE says "Cannot switch branches with local changes":
git stash
# (IDE might offer to do this automatically)
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What's the difference between `pop` and `apply`?

2. **Q:** Does stash include untracked files by default?

3. **Q:** How do you stash with a descriptive message?

4. **Q:** What does `git stash show -p` display?

5. **Q:** When should you use a WIP commit instead of stash?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `pop` applies AND removes from stash. `apply` just applies, keeps the stash.

2. **A:** No! Untracked files need `-u` flag: `git stash -u`

3. **A:** `git stash push -m "Your message here"`

4. **A:** The full diff of what's in the stash (the actual changes)

5. **A:** When work will take more than a few hours, or when you need to share it (stash is local only)

</details>

---

## 🎯 Stash Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    STASH COMMANDS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  BASIC                                                           │
│  git stash                     Quick stash                      │
│  git stash push -m "msg"       Stash with description           │
│  git stash pop                 Apply & remove latest stash      │
│  git stash apply               Apply but keep stash             │
│                                                                   │
│  OPTIONS                                                         │
│  git stash -u                  Include untracked files          │
│  git stash -a                  Include everything (ignored too) │
│  git stash --keep-index        Keep staged changes              │
│  git stash push file1 file2    Stash specific files            │
│                                                                   │
│  MANAGEMENT                                                      │
│  git stash list                List all stashes                  │
│  git stash show                Summary of latest stash          │
│  git stash show -p             Full diff of stash               │
│  git stash drop stash@{N}      Delete specific stash           │
│  git stash clear               Delete ALL stashes              │
│                                                                   │
│  ADVANCED                                                        │
│  git stash pop stash@{N}       Apply specific stash            │
│  git stash branch <name>       Create branch from stash        │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 12: Cherry-Pick**, we'll learn:
- Applying specific commits to any branch
- Backporting fixes
- When cherry-pick is the right tool
