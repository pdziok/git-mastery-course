# Module 12: Cherry-Pick - Surgical Transplants

## 🎯 Learning Objectives

After this module, you will:
- Understand when and why to use cherry-pick
- Apply specific commits to other branches
- Handle cherry-pick conflicts
- Know the limitations and gotchas

---

## 🏠 The Recipe Book Metaphor

Imagine you have two cookbooks:

```
COOKBOOK A (feature branch):
  Recipe 1: Pancakes
  Recipe 2: Waffles       ← You want just THIS one!
  Recipe 3: French Toast

COOKBOOK B (main branch):
  Recipe 1: Eggs
  Recipe 2: Bacon
```

**Cherry-pick** = Copy Recipe 2 (Waffles) from Cookbook A to Cookbook B.

- The recipe content is the same
- But it gets a new page number (new commit hash)
- Cookbook A still has its copy

---

## 📖 Theory: What Cherry-Pick Does

```
BEFORE:

main:     A ── B ── C
               \
feature:        D ── E ── F
                     ↑
                     This one!

AFTER git cherry-pick E:

main:     A ── B ── C ── E'   (E' = copy of E's changes)
               \
feature:        D ── E ── F    (unchanged)
```

**Key points:**
- E' has a NEW hash (different parent, different timestamp)
- E' contains the same CHANGES as E
- E still exists on feature (not moved)
- Git doesn't know E and E' are related (potential duplicate later)

---

## 🔬 Hands-On Exercise 9.1: Basic Cherry-Pick

```bash
# Fresh start
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create main history
echo "base" > app.js
git add app.js
git commit -m "Initial"

# Create feature branch with multiple commits
git switch -c feature-work

echo "feature code" > feature.js
git add feature.js
git commit -m "Add feature module"

echo "bugfix in feature" >> app.js
git add app.js
git commit -m "Fix critical bug"   # ← We need THIS one on main!

echo "more feature work" >> feature.js
git add feature.js
git commit -m "Expand feature"

# Note the hash of "Fix critical bug"
git log --oneline
# abc123 Expand feature
# def456 Fix critical bug     ← Note this hash!
# ghi789 Add feature module
# jkl012 Initial

# Switch to main and cherry-pick just the bug fix
git switch main

git cherry-pick def456   # Use your actual hash!

# Check the result
git log --oneline
# mno345 Fix critical bug     ← New hash, same message!
# jkl012 Initial

# The bug fix is now on main!
cat app.js
# base
# bugfix in feature
```

---

## 🔬 Hands-On Exercise 9.2: Cherry-Pick Multiple Commits

```bash
# You can cherry-pick several commits

# Get multiple specific commits
git cherry-pick abc123 def456

# Get a range of commits (exclusive start, inclusive end)
git cherry-pick abc123..def456

# Get a range (inclusive both ends)
git cherry-pick abc123^..def456

# Cherry-pick from another branch (last 2 commits)
git cherry-pick feature-work~2..feature-work
```

---

## 🔬 Hands-On Exercise 9.3: Cherry-Pick Options

```bash
# Cherry-pick but don't commit (stage changes only)
git cherry-pick -n abc123
# or: git cherry-pick --no-commit abc123

# Now changes are staged, you can:
# - Modify before committing
# - Combine with other changes
# - Write a different commit message

git status   # Shows staged changes
git commit -m "Different message for this fix"

# Cherry-pick and edit message
git cherry-pick -e abc123
# Opens editor to change the commit message

# Cherry-pick with reference to original
git cherry-pick -x abc123
# Adds "(cherry picked from commit abc123)" to message
# Recommended for tracking!
```

---

## 🔬 Hands-On Exercise 9.4: Cherry-Pick Conflicts

```bash
# Setup conflict scenario
git switch main
echo "main changes line 1" >> app.js
git add app.js
git commit -m "Main work"

git switch feature-work
echo "feature changes line 1" >> app.js
git add app.js
git commit -m "Feature modifies same line"

# Try to cherry-pick
git switch main
git cherry-pick feature-work

# CONFLICT!
# error: could not apply abc123... Feature modifies same line

# Check status
git status
# both modified: app.js

# Resolve the conflict (edit app.js, remove markers)
cat > app.js << 'EOF'
base
bugfix in feature
main changes line 1
feature changes line 1
EOF

# Complete the cherry-pick
git add app.js
git cherry-pick --continue

# Or abort if you change your mind
# git cherry-pick --abort
```

---

## 📖 Theory: When to Use Cherry-Pick

### Good Use Cases ✅

1. **Hotfix needs to go to multiple branches**
   ```bash
   # Fix on main, cherry-pick to release branch
   git switch release-1.0
   git cherry-pick <hotfix-commit>
   ```

2. **Specific commit from abandoned branch**
   ```bash
   # Feature branch was rejected, but one commit is useful
   git cherry-pick <useful-commit>
   ```

3. **Backporting to older version**
   ```bash
   # Bug fixed in v2, need it in v1.x
   git switch v1-maintenance
   git cherry-pick <v2-bugfix>
   ```

### Avoid Cherry-Pick When ⚠️

1. **You want ALL commits from a branch** → Use merge or rebase instead

2. **You'll eventually merge that branch** → Creates duplicates
   ```
   After cherry-pick and then merge:
   main:    A ── B ── E' ── ... ── M (merge)
                 \               /
   feature:       C ── D ── E ──

   E and E' have same changes! Git usually handles this,
   but conflicts can arise.
   ```

3. **Complex commits with many dependencies** → Might not work in isolation

---

## 📖 Cherry-Pick vs Other Operations

| Operation | Use When |
|-----------|----------|
| **Cherry-pick** | Need specific commit(s), not the whole branch |
| **Merge** | Want to integrate an entire branch |
| **Rebase** | Want to move your branch to new base |
| **Revert** | Want to undo a commit's effects |

---

## 🔬 Hands-On Exercise 9.5: What Your IDE Does

```bash
# When you right-click a commit → "Cherry-Pick":
git cherry-pick <commit-hash>

# If there's a conflict, IDE shows:
# - Conflicted files
# - "Continue Cherry-Pick" and "Abort Cherry-Pick" buttons

# Continue:
git add <resolved-files>
git cherry-pick --continue

# Abort:
git cherry-pick --abort

# When IDE shows "Cherry-Pick Selected Commits":
git cherry-pick <commit1> <commit2> <commit3>
```

---

## 📖 Pro Tip: Tracking Cherry-Picks

Always use `-x` to leave a breadcrumb:

```bash
git cherry-pick -x abc123
```

Commit message becomes:
```
Fix critical bug

(cherry picked from commit abc123def456...)
```

This helps when:
- Investigating where a change came from
- Avoiding confusion about duplicate commits
- Understanding the history later

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** After cherry-picking commit E, does the original E still exist?

2. **Q:** Why does the cherry-picked commit have a different hash?

3. **Q:** What flag adds "(cherry picked from commit ...)" to the message?

4. **Q:** How do you cherry-pick without immediately committing?

5. **Q:** When should you NOT use cherry-pick?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** Yes! Cherry-pick creates a COPY. Original commit remains on its branch.

2. **A:** Because the parent commit is different (and timestamp changes). Hash = hash of content + metadata.

3. **A:** `-x` flag: `git cherry-pick -x <commit>`

4. **A:** Use `-n` or `--no-commit`: `git cherry-pick -n <commit>`

5. **A:** When you'll eventually merge the whole branch (creates duplicates), or when you want all commits (use merge instead).

</details>

---

## 🎯 Cherry-Pick Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    CHERRY-PICK COMMANDS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  BASIC                                                          │
│  git cherry-pick <commit>      Apply commit to current branch   │
│  git cherry-pick A B C         Apply multiple commits           │
│  git cherry-pick A..B          Apply range (A exclusive)        │
│  git cherry-pick A^..B         Apply range (A inclusive)        │
│                                                                 │
│  OPTIONS                                                        │
│  git cherry-pick -n <commit>   Don't commit, just stage         │
│  git cherry-pick -e <commit>   Edit commit message              │
│  git cherry-pick -x <commit>   Add "cherry picked from" note    │
│                                                                 │
│  CONFLICT HANDLING                                              │
│  git cherry-pick --continue    After resolving conflicts        │
│  git cherry-pick --abort       Cancel the cherry-pick           │
│  git cherry-pick --skip        Skip current commit              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 13: History Investigation**, we'll learn:
- `git log` advanced techniques
- `git blame` for finding who changed what
- `git bisect` for finding which commit introduced a bug
