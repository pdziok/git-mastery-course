# Module 8: Rebasing - Rewriting History

## 🎯 Learning Objectives

After this module, you will:
- Understand what rebase actually does internally
- Use interactive rebase to clean up commits
- Know the golden rule: never rebase public history
- Choose confidently between merge and rebase

---

## 🏠 The Time Machine Metaphor

Imagine you have a time machine:

### Merge (What we did before):
```
"I wrote chapters 4-6 starting from chapter 3 last week.
Main now has chapters 3.1 and 3.2 (new stuff I missed).
Let me COMBINE everything into chapter 7."
→ Creates a new chapter (merge commit) that links both
```

### Rebase:
```
"I wrote chapters 4-6 starting from chapter 3 last week.
Main now has chapters 3.1 and 3.2.
Let me go BACK IN TIME, start from 3.2 instead,
and RE-WRITE my chapters 4-6 from there."
→ My chapters become 4', 5', 6' (new versions, new "dates")
```

---

## 📖 Theory: What Rebase Does

```
BEFORE REBASE:

main:     A ── B ── C ── D        (main moved on)
                \
feature:         E ── F ── G      (your work, based on C)


AFTER git rebase main:

main:     A ── B ── C ── D
                          \
feature:                   E' ── F' ── G'  (your work, now based on D!)
```

**Key insight:** E, F, G are REPLACED by E', F', G'!
- Same changes, but different commit hashes
- It's like your branch was created NOW, from the latest main

---

## 📖 Theory: Why New Commit Hashes?

Remember from Module 2: commit hash = hash of content + metadata.

Metadata includes:
- Parent commit
- Timestamp
- Author date

When you rebase:
- Parent changes (now based on D instead of C)
- Committer date changes (now)
- Therefore: new hash!

**E, F, G still exist** in Git's object database (until garbage collection).
**E', F', G'** are NEW commits with your same changes.

---

## 🔬 Hands-On Exercise 6.1: Basic Rebase

```bash
# Fresh start
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create base history
echo "# App" > README.md
git add README.md
git commit -m "A: Initial commit"

echo "base code" > app.js
git add app.js
git commit -m "B: Add app.js"

# Create feature branch
git switch -c feature-x

# Make feature commits
echo "feature code" > feature.js
git add feature.js
git commit -m "E: Add feature"

echo "more feature" >> feature.js
git add feature.js
git commit -m "F: Enhance feature"

# NOTE the commit hashes!
git log --oneline
# Example:
# abc123 (HEAD -> feature-x) F: Enhance feature
# def456 E: Add feature
# ghi789 B: Add app.js
# ...

# Now, main moves on (simulate teammate commits)
git switch main
echo "main updates" > utils.js
git add utils.js
git commit -m "C: Add utils"

echo "more main" >> app.js
git add app.js
git commit -m "D: Update app"

# See the diverged state
git log --oneline --all --graph
# * jkl012 (HEAD -> main) D: Update app
# * mno345 C: Add utils
# | * abc123 (feature-x) F: Enhance feature
# | * def456 E: Add feature
# |/
# * ghi789 B: Add app.js

# Now REBASE feature onto main
git switch feature-x
git rebase main

# See the result
git log --oneline --all --graph
# * pqr678 (HEAD -> feature-x) F: Enhance feature
# * stu901 E: Add feature
# * jkl012 (main) D: Update app
# * mno345 C: Add utils
# * ghi789 B: Add app.js

# Notice:
# 1. Feature commits are NOW ON TOP of main
# 2. Commit hashes CHANGED (pqr678, stu901 instead of abc123, def456)
# 3. Linear history! No merge commit needed.
```

---

## 📖 Theory: The Golden Rule

```
╔════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║   🚨 NEVER REBASE COMMITS THAT HAVE BEEN PUSHED AND SHARED! 🚨     ║
║                                                                      ║
╚════════════════════════════════════════════════════════════════════╝
```

Why? Because others might have based their work on those commits.

```
You:      A ── B ── C    (pushed, teammate pulled)
Teammate:            \── D ── E  (based on your C)

You rebase, creating C':
You:      A ── B' ── C'  (C is gone!)

Teammate's D and E now point to a commit (C) that
doesn't exist in the remote anymore!
```

**Safe to rebase:**
- Commits only on YOUR local branch
- Commits not yet pushed
- Commits on a branch only you use

**Never rebase:**
- Commits already pushed to shared branches
- main/master
- Any branch others might have pulled

---

## 🔬 Hands-On Exercise 6.2: Interactive Rebase - Clean Up History

Interactive rebase is the power tool for crafting clean commits.

```bash
# Continue from previous exercise (feature-x)
git switch feature-x

# Add some messy commits
echo "oops" > oops.js
git add oops.js
git commit -m "WIP"

echo "typo fix" >> feature.js
git add feature.js
git commit -m "fix typo"

echo "forgot this" >> feature.js
git add feature.js
git commit -m "forgot to add this"

# Now we have messy history
git log --oneline
# aaa111 forgot to add this
# bbb222 fix typo
# ccc333 WIP
# pqr678 F: Enhance feature
# stu901 E: Add feature
# ...

# Let's clean up the last 5 commits
git rebase -i HEAD~5
```

An editor opens with:
```
pick stu901 E: Add feature
pick pqr678 F: Enhance feature
pick ccc333 WIP
pick bbb222 fix typo
pick aaa111 forgot to add this

# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's message
# d, drop = remove commit
```

---

## 🔬 Hands-On Exercise 6.3: Squashing Commits

```bash
# In the interactive rebase editor, change to:

pick stu901 E: Add feature
pick pqr678 F: Enhance feature
squash ccc333 WIP
squash bbb222 fix typo
squash aaa111 forgot to add this

# This means: keep E and F, but squash the messy commits into F

# Save and close. Another editor opens for the combined message.
# Edit the message to be clean:

F: Enhance feature

- Added feature enhancements
- Fixed typos
- Added missing functionality

# Save and close

# Check the result
git log --oneline
# xyz789 F: Enhance feature
# stu901 E: Add feature
# jkl012 (main) D: Update app
# ...

# 5 commits became 2 clean commits!
```

---

## 📖 Interactive Rebase Commands Explained

| Command | Short | What It Does |
|---------|-------|--------------|
| `pick` | `p` | Keep the commit as-is |
| `reword` | `r` | Keep commit, edit message |
| `edit` | `e` | Stop at this commit, let me amend it |
| `squash` | `s` | Meld into previous, combine messages |
| `fixup` | `f` | Meld into previous, discard this message |
| `drop` | `d` | Delete this commit entirely |

You can also **reorder** commits by moving lines around!

---

## 🔬 Hands-On Exercise 6.4: Reword Commits

```bash
# Rename a commit message
git rebase -i HEAD~2

# Change:
pick stu901 E: Add feature
pick xyz789 F: Enhance feature

# To:
pick stu901 E: Add feature
reword xyz789 F: Enhance feature

# Save. Editor opens for xyz789's message.
# Change it to:
feat: Enhance feature with improvements

# Save and close.
git log --oneline
```

---

## 🔬 Hands-On Exercise 6.5: Rebase Conflicts

```bash
# Sometimes rebase has conflicts (just like merge)

git switch main
echo "conflict line" >> feature.js
git add feature.js
git commit -m "Main changes feature.js"

git switch feature-x
echo "different line" >> feature.js
git add feature.js
git commit -m "Feature also changes feature.js"

# Try to rebase
git rebase main

# CONFLICT!
# Git is replaying your commits one by one on top of main.
# When it tries to apply "Feature also changes feature.js",
# it conflicts with main's change.

# Options:
# 1. Fix conflict, then:
#    git add feature.js
#    git rebase --continue

# 2. Skip this commit:
#    git rebase --skip

# 3. Abort entire rebase:
#    git rebase --abort

# Let's fix it:
# Edit feature.js, resolve conflicts, remove markers
echo "resolved content" > feature.js
git add feature.js
git rebase --continue

# Check result
git log --oneline --graph --all
```

---

## 📖 Merge vs Rebase: When to Use Which

### Use MERGE when:
- ✅ Working on shared branches
- ✅ Want to preserve exact history
- ✅ Need to see when branches diverged
- ✅ Resolving pull requests (usually)

### Use REBASE when:
- ✅ Cleaning up local work before sharing
- ✅ Keeping feature branch up-to-date with main
- ✅ Want linear history (easier to read)
- ✅ Squashing WIP commits before PR

### The Hybrid Approach (Common)
```bash
# While working on feature, keep up to date:
git switch feature
git rebase main    # Linear updates, no merge commits

# When feature is ready, merge into main:
git switch main
git merge --no-ff feature   # Creates merge commit for history
```

---

## 🔬 Hands-On Exercise 6.6: What Your IDE Does

```bash
# When you right-click main → "Rebase Current onto Selected":
git rebase main

# When you "Interactively Rebase from Here":
git rebase -i <that-commit>^

# When you "Squash with Previous" in interactive rebase:
# Changes "pick" to "squash" in the rebase-todo file

# When you click "Continue Rebase" after resolving:
git add <resolved-files>
git rebase --continue

# When you click "Abort Rebase":
git rebase --abort
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What happens to commit hashes when you rebase?

2. **Q:** Why should you never rebase public/shared commits?

3. **Q:** What's the difference between `squash` and `fixup`?

4. **Q:** How do you abort a rebase that has conflicts?

5. **Q:** What does `git rebase -i HEAD~3` do?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** They change! Rebased commits are technically new commits with new hashes.

2. **A:** Others may have based their work on the original commits. Those commits will "disappear" from their perspective.

3. **A:** Both combine with previous commit. `squash` keeps both messages (you edit combined). `fixup` discards the message.

4. **A:** `git rebase --abort`

5. **A:** Opens interactive rebase for the last 3 commits, letting you pick/squash/reword/reorder them.

</details>

---

## 🎯 Rebase Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    REBASE COMMANDS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  BASIC REBASE                                                    │
│  git rebase main             Rebase current onto main            │
│  git rebase -i HEAD~N        Interactive rebase last N commits   │
│  git rebase -i main          Interactive rebase since main       │
│                                                                   │
│  DURING REBASE (conflicts)                                       │
│  git status                  See what needs resolving            │
│  git add <file>              Mark conflict as resolved           │
│  git rebase --continue       Continue after resolving            │
│  git rebase --skip           Skip current commit                 │
│  git rebase --abort          Cancel entire rebase                │
│                                                                   │
│  INTERACTIVE COMMANDS                                            │
│  pick (p)    Keep commit                                         │
│  reword (r)  Keep commit, edit message                           │
│  squash (s)  Meld into previous, combine messages                │
│  fixup (f)   Meld into previous, discard message                 │
│  drop (d)    Remove commit                                       │
│  edit (e)    Stop for amending                                   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 9: Undoing Things**, we'll learn:
- `reset` - soft, mixed, hard
- `revert` - safe undo for public history
- `restore` - getting files back
