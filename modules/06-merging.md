# Module 6: Merging - Bringing Timelines Together

## 🎯 Learning Objectives

After this module, you will:
- Understand fast-forward vs merge commits
- Handle merge conflicts confidently
- Know when to use different merge strategies
- Understand what your IDE's "Merge" button does

---

## 🏠 The Two Writers Metaphor

Imagine two writers collaborating on a book:

### Scenario 1: Fast-Forward (Simple)
```
Writer A stops at Chapter 3.
Writer B continues, writing Chapters 4, 5, 6.
Writer A returns and wants to "merge" B's work.

Solution: Just move A's bookmark to where B is!
No actual "merging" needed - just advancing the pointer.
```

### Scenario 2: True Merge (Diverged)
```
Writer A stops at Chapter 3, then writes an Epilogue.
Writer B continues from Chapter 3, writing Chapters 4, 5, 6.
Now we need to actually combine both works!

Solution: Create a "combined edition" that has both.
This new edition (merge commit) has TWO parents.
```

### Scenario 3: Conflict
```
Both writers edited Chapter 3 differently!
Writer A: "The hero escaped through the window"
Writer B: "The hero escaped through the secret tunnel"

Solution: A human must decide which version (or combination) to keep.
```

---

## 📖 Theory: Fast-Forward Merge

When the branch you're merging INTO hasn't moved since you branched off:

```
BEFORE:
main:     A ── B ── C
                     \
feature:              D ── E ── F

AFTER git merge feature (fast-forward):
main:     A ── B ── C ── D ── E ── F
                                   ▲
                                 (main just moved forward)
```

**No merge commit created** - just moved the pointer!

---

## 📖 Theory: True Merge (Merge Commit)

When both branches have new commits:

```
BEFORE:
main:     A ── B ── C ── X ── Y
                     \
feature:              D ── E ── F

AFTER git merge feature:
main:     A ── B ── C ── X ── Y ── M (merge commit)
                     \           /
feature:              D ── E ── F

M has TWO parents: Y and F
```

**Merge commit M** = "I combined both branches here"

---

## 🔬 Hands-On Exercise 5.1: Fast-Forward Merge

```bash
# Fresh start
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Initial setup
echo "# App" > README.md
git add README.md
git commit -m "Initial commit"

# Create feature branch
git switch -c feature-add-login

# Work on feature
echo "login code" > login.js
git add login.js
git commit -m "Add login.js"

echo "more login" >> login.js
git add login.js
git commit -m "Enhance login"

# Check the graph
git log --oneline --graph --all
# * abc123 (HEAD -> feature-add-login) Enhance login
# * def456 Add login.js
# * 789ghi (main) Initial commit

# Switch to main and merge
git switch main

# main hasn't moved since we branched - fast-forward possible!
git merge feature-add-login

# Check the result
git log --oneline --graph --all
# * abc123 (HEAD -> main, feature-add-login) Enhance login
# * def456 Add login.js
# * 789ghi Initial commit

# Notice: NO merge commit! main just moved forward.
# Both branches point to the same commit now.
```

---

## 🔬 Hands-On Exercise 5.2: True Merge (With Merge Commit)

```bash
# Continue from previous exercise

# Create another feature branch
git switch -c feature-add-logout

# Work on logout
echo "logout code" > logout.js
git add logout.js
git commit -m "Add logout"

# NOW, switch to main and make a different change
git switch main

# main moves ahead on its own path
echo "config stuff" > config.js
git add config.js
git commit -m "Add config"

# Check the graph - branches have DIVERGED
git log --oneline --graph --all
# * aaa111 (HEAD -> main) Add config
# | * bbb222 (feature-add-logout) Add logout
# |/
# * abc123 Enhance login
# ...

# Now merge - this CANNOT be fast-forward!
git merge feature-add-logout

# Git opens your editor for merge commit message
# Default: "Merge branch 'feature-add-logout'"
# Save and close

# Check the result
git log --oneline --graph --all
# *   ccc333 (HEAD -> main) Merge branch 'feature-add-logout'
# |\
# | * bbb222 (feature-add-logout) Add logout
# * | aaa111 Add config
# |/
# * abc123 Enhance login
# ...

# The merge commit has TWO parents!
git cat-file -p HEAD
# tree ...
# parent aaa111...  (main's previous commit)
# parent bbb222...  (feature's commit)
```

---

## 🔬 Hands-On Exercise 5.3: Merge Conflicts

```bash
# Create a conflict scenario

git switch -c feature-update-readme

# Modify README
echo "# App v2" > README.md
echo "Updated by feature branch" >> README.md
git add README.md
git commit -m "Update README on feature"

# Switch to main and make CONFLICTING change
git switch main

echo "# My Application" > README.md
echo "Updated by main branch" >> README.md
git add README.md
git commit -m "Update README on main"

# Now try to merge - CONFLICT!
git merge feature-update-readme

# Output:
# Auto-merging README.md
# CONFLICT (content): Merge conflict in README.md
# Automatic merge failed; fix conflicts and then commit the result.

# Check status
git status
# both modified: README.md

# Look at the file
cat README.md
```

You'll see conflict markers:
```
<<<<<<< HEAD
# My Application
Updated by main branch
=======
# App v2
Updated by feature branch
>>>>>>> feature-update-readme
```

**The markers mean:**
- `<<<<<<< HEAD` to `=======` = Your current branch (main)
- `=======` to `>>>>>>>>` = The branch being merged in

---

## 🔬 Hands-On Exercise 5.4: Resolving Conflicts

```bash
# Option 1: Edit manually
# Open README.md in editor, choose what to keep, remove markers

# Option 2: Use git checkout to pick a side
git checkout --ours README.md    # Keep main's version
# OR
git checkout --theirs README.md  # Keep feature's version

# Option 3: Use a merge tool
git mergetool

# For this exercise, let's manually resolve:
cat > README.md << 'EOF'
# My Application v2
Updated by both branches - combined!
EOF

# Mark as resolved by staging
git add README.md

# Complete the merge
git commit
# Git knows this is a merge, opens editor with pre-filled message

# Check the result
git log --oneline --graph --all

# Verify the content
cat README.md
```

---

## 📖 Theory: Merge Strategies

```bash
# Force a merge commit even if fast-forward possible
git merge --no-ff feature-branch

# Fast-forward only - fail if not possible
git merge --ff-only feature-branch

# Abort a conflicted merge
git merge --abort

# Squash all feature commits into one (no merge commit)
git merge --squash feature-branch
git commit -m "Add feature"
```

### Why Use --no-ff?

```
With fast-forward:              With --no-ff:

A ── B ── C ── D ── E           A ── B ── C ── ─ ─ ─ ── M
     main                                    \       /
     (where did feature start?)               D ── E
                                              feature (clear history!)
```

`--no-ff` preserves the fact that a branch existed.

---

## 🔬 Hands-On Exercise 5.5: What Your IDE Does

```bash
# When you right-click a branch → "Merge into Current":
git merge <selected-branch>

# When you click "Resolve using Mine":
git checkout --ours <file>
git add <file>

# When you click "Resolve using Theirs":
git checkout --theirs <file>
git add <file>

# When you use the 3-way merge editor:
# IDE shows: LEFT (ours) | RESULT (middle) | RIGHT (theirs)
# You edit the RESULT, then:
git add <file>
git commit

# When you click "Abort Merge":
git merge --abort

# When IDE shows "Merge Conflicts: 3 files":
git diff --name-only --diff-filter=U
# Lists only unmerged (conflicted) files
```

---

## 📖 The Anatomy of a Conflict File

```
normal content here is fine

<<<<<<< HEAD
This is what YOUR branch (the one you're on) has.
This is the "current" change.
=======
This is what the INCOMING branch has.
This is the change being merged in.
>>>>>>> feature-branch

more normal content
```

**To resolve:**
1. Decide what the final content should be
2. Remove ALL marker lines (`<<<<<<<`, `=======`, `>>>>>>>`)
3. Stage the file (`git add`)
4. Complete the merge (`git commit`)

---

## 📖 Conflict Prevention Tips

1. **Pull often** - Stay up to date with main
2. **Small, focused branches** - Fewer files touched = fewer conflicts
3. **Communicate** - "I'm working on auth.js this week"
4. **Merge main into feature regularly** - Keep your branch current

```bash
# While on feature branch, get updates from main
git switch feature-branch
git merge main
# or: git rebase main (Module 8!)
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** When does a fast-forward merge happen?

2. **Q:** How many parents does a merge commit have?

3. **Q:** What command aborts a merge in progress?

4. **Q:** What's between `=======` and `>>>>>>>` in a conflict?

5. **Q:** How do you force a merge commit even when fast-forward is possible?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** When the branch you're merging into hasn't moved since the other branch was created

2. **A:** Two - one from each branch being merged

3. **A:** `git merge --abort`

4. **A:** The incoming changes from the branch being merged in

5. **A:** `git merge --no-ff <branch>`

</details>

---

## 🎯 Merge Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    MERGE COMMANDS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  BASIC MERGE                                                     │
│  git merge <branch>          Merge branch into current           │
│  git merge --no-ff <branch>  Force merge commit                  │
│  git merge --ff-only <branch> Fail if not fast-forward          │
│  git merge --squash <branch> Squash into single commit          │
│                                                                   │
│  CONFLICT RESOLUTION                                             │
│  git status                  See conflicted files                │
│  git diff                    See conflict details                │
│  git checkout --ours <file>  Keep our version                   │
│  git checkout --theirs <file> Keep their version                │
│  git add <file>              Mark as resolved                   │
│  git commit                  Complete merge                      │
│  git merge --abort           Cancel and go back                  │
│                                                                   │
│  USEFUL                                                          │
│  git log --merge             Show commits causing conflict       │
│  git diff --name-only --diff-filter=U  List conflicted files    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 7: Conflict Resolution**, we'll learn:
- Handling merge conflicts step by step
- Using your IDE's merge tools
- Strategies for complex conflicts
