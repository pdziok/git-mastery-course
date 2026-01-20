# Module 5: Branching - Git's Killer Feature

## 🎯 Learning Objectives

After this module, you will:
- Create, switch, and delete branches fluently
- Understand branches as movable pointers
- Know the difference between `switch` and `checkout`
- Follow branch naming conventions

---

## 🏠 The Parallel Universes Metaphor

Imagine you're writing a story with multiple possible endings:

```
                         "What if the hero takes the dangerous path?"
                                          │
                                          ▼
                              ┌─────────────────────┐
                              │   feature/danger    │
                              │   (alternate story) │
                              └─────────────────────┘
                                          │
    ┌─────┐    ┌─────┐    ┌─────┐        │
    │Ch.1 │───>│Ch.2 │───>│Ch.3 │───>────┴────────────>
    └─────┘    └─────┘    └─────┘    ┌─────────────────┐
                              │      │      main       │
                              │      │ (main timeline) │
                              │      └─────────────────┘
                              │
                              ▼
                  ┌─────────────────────┐
                  │   feature/safe      │
                  │ (another alternate) │
                  └─────────────────────┘
                          │
            "What if the hero plays it safe?"
```

- **main** = The "prime" timeline (will be published)
- **feature branches** = Experimental timelines (might be merged back)
- **Switching branches** = Jumping between alternate stories
- **Merging** = Incorporating discoveries from alternate timeline into main

---

## 📖 Theory: Branches Are Just Pointers (Revisited)

Remember from Module 2:

```bash
$ cat .git/refs/heads/main
a1b2c3d4e5f6789...  # Just 40 characters!
```

**Creating a branch = creating a 41-byte file**

This is why Git branches are:
- **Instant** to create
- **Instant** to switch
- **Cheap** to have hundreds of them

Compare to other VCS where branching means copying files!

---

## 📖 Theory: checkout vs switch vs restore

Git used to overload `checkout` for many things. Now there are focused commands:

| Old Way | New Way | Purpose |
|---------|---------|---------|
| `git checkout main` | `git switch main` | Switch branches |
| `git checkout -b new` | `git switch -c new` | Create & switch |
| `git checkout -- file.txt` | `git restore file.txt` | Discard changes |
| `git checkout abc123 -- file.txt` | `git restore --source abc123 file.txt` | Get old version |

**Recommendation:** Use the new commands - they're clearer and safer!

---

## 🔬 Hands-On Exercise 4.1: Branch Basics

```bash
# Fresh start
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Initial commit
echo "# My App" > README.md
git add README.md
git commit -m "Initial commit"

# 1. See current branches
git branch
# Shows: * main (asterisk = current branch)

# 2. Create a new branch (doesn't switch to it!)
git branch feature-login

# 3. See both branches
git branch
# * main
#   feature-login

# 4. Both point to same commit
git log --oneline --all
# abc123 (HEAD -> main, feature-login) Initial commit

# 5. Switch to the new branch
git switch feature-login
# or: git checkout feature-login

# 6. Verify
git branch
#   main
# * feature-login

# 7. Make a commit on this branch
echo "login code" > login.js
git add login.js
git commit -m "Add login feature"

# 8. See the branches diverge
git log --oneline --all --graph
# * def456 (HEAD -> feature-login) Add login feature
# * abc123 (main) Initial commit

# 9. Switch back to main
git switch main

# 10. login.js is GONE! (it only exists on feature-login)
ls
# Only README.md
```

---

## 🔬 Hands-On Exercise 4.2: Create and Switch in One Command

```bash
# The most common workflow: create + switch

# Old way
git checkout -b feature-signup

# New way (recommended)
git switch -c feature-payments

# See all branches
git branch

# The -c flag means "create" (like -b in checkout)

# Quick tip: delete merged branches
git switch main
git branch -d feature-signup    # Safe delete (only if merged)
git branch -D feature-payments  # Force delete (even if not merged)
```

---

## 🔬 Hands-On Exercise 4.3: What Your IDE Does

```bash
# When you click "New Branch" in IDE:
git switch -c <branch-name>

# When you double-click a branch to switch:
git switch <branch-name>

# When you see the branch dropdown and current branch:
git branch             # List branches
cat .git/HEAD          # Current branch

# When you right-click → Delete Branch:
git branch -d <branch-name>

# When IDE shows "branch is X commits ahead/behind main":
git rev-list --left-right --count main...feature
# Example output: 2    3
# Means: main has 2 commits not in feature, feature has 3 not in main
```

---

## 📖 Branch Naming Conventions

Good branch names help the team:

```
TYPE/SHORT-DESCRIPTION

Types:
  feature/    New functionality
  bugfix/     Bug fixes
  hotfix/     Urgent production fixes
  release/    Release preparation
  chore/      Maintenance tasks
  experiment/ Experiments (might be thrown away)

Examples:
  feature/user-authentication
  bugfix/fix-login-redirect
  hotfix/security-patch-2024-01
  release/v2.3.0
  chore/update-dependencies

Bad examples:
  new-stuff            (too vague)
  johns-branch         (not descriptive)
  asdfjkl              (meaningless)
  fix                  (fix what?)
```

---

## 🔬 Hands-On Exercise 4.4: Tracking Remote Branches

```bash
# Let's simulate a remote (we'll use a local folder)
cd ~/git-workshop
mkdir remote-repo && cd remote-repo
git init --bare  # Bare repo = no working directory, only .git stuff

# Back to our playground and add remote
cd ../playground
git remote add origin ../remote-repo

# Push main to remote
git push -u origin main
# -u (or --set-upstream) creates tracking relationship

# Now let's see tracking
git branch -vv
# * main abc123 [origin/main] Initial commit
#                ^^^^^^^^^^^^^ tracking branch

# When you push a new branch for the first time:
git switch -c feature-new
echo "new" > new.txt && git add . && git commit -m "New feature"
git push -u origin feature-new

# IDE's "Push" button does:
git push
# If no upstream: git push -u origin <current-branch>

# See all branches including remotes:
git branch -a
# * feature-new
#   main
#   remotes/origin/feature-new
#   remotes/origin/main

# See tracking info:
git branch -vv
```

---

## 📖 Theory: What is origin/main?

```
YOUR MACHINE                         REMOTE (GitHub/GitLab)
┌──────────────────────────────┐     ┌─────────────────────┐
│  Working Directory           │     │                     │
│  ────────────────            │     │      main           │
│                              │     │    (the truth)      │
│  .git/                       │     │                     │
│  ├── refs/heads/             │     │                     │
│  │   ├── main  ────────────────────┼──> main             │
│  │   └── feature             │     │                     │
│  │                           │     │                     │
│  └── refs/remotes/origin/    │     │                     │
│      ├── main  (memory of ─────────┼──> main             │
│      │           remote)     │     │                     │
│      └── feature             │     │                     │
└──────────────────────────────┘     └─────────────────────┘

origin/main = "What main looked like last time I fetched/pulled"
```

- `main` = your local branch (you can move it)
- `origin/main` = your memory of remote's main (updated by fetch/pull)

---

## 🔬 Hands-On Exercise 4.5: Simulating Team Work

```bash
# Simulate a coworker making changes on remote
# We'll directly modify the bare repo (pretend it's GitHub)

cd ../remote-repo

# Create a file directly in the bare repo (simulating teammate's push)
git config core.bare false  # Temporarily allow
echo "teammate work" > /tmp/teammate.txt
git --work-tree=/tmp add teammate.txt
git commit -m "Teammate's commit"
git config core.bare true

# Back to playground
cd ../playground

# Your origin/main is outdated now
git log --oneline --all
# Doesn't show teammate's commit yet!

# Fetch updates (downloads but doesn't merge)
git fetch origin

# Now you can see it
git log --oneline --all
# Shows teammate's commit on origin/main

# Your local main is BEHIND origin/main
git status
# "Your branch is behind 'origin/main' by 1 commit"

# Pull to update (fetch + merge)
git pull

# Now you're up to date
git log --oneline
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What file does Git create when you run `git branch feature`?

2. **Q:** What's the difference between `git branch feature` and `git switch -c feature`?

3. **Q:** What does `origin/main` represent?

4. **Q:** You want to get updates from remote without merging. What command?

5. **Q:** How do you delete a branch that hasn't been merged?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `.git/refs/heads/feature` containing the current commit's hash

2. **A:** `git branch` only creates the branch. `git switch -c` creates AND switches to it.

3. **A:** Your local memory of what `main` looked like on the remote last time you fetched/pulled

4. **A:** `git fetch origin` (or just `git fetch`)

5. **A:** `git branch -D <branch-name>` (capital D = force delete)

</details>

---

## 🎯 Branch Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    BRANCH COMMANDS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  CREATE & SWITCH                                                 │
│  git branch <name>           Create branch (stay where you are) │
│  git switch <name>           Switch to branch                   │
│  git switch -c <name>        Create AND switch (preferred!)     │
│  git checkout -b <name>      Old way of create + switch         │
│                                                                   │
│  LIST & INFO                                                     │
│  git branch                  List local branches                 │
│  git branch -a               List all (including remotes)       │
│  git branch -vv              Verbose with tracking info         │
│                                                                   │
│  DELETE                                                          │
│  git branch -d <name>        Delete (safe - must be merged)     │
│  git branch -D <name>        Force delete                       │
│                                                                   │
│  REMOTE OPERATIONS                                               │
│  git push -u origin <name>   Push & set up tracking             │
│  git fetch                   Download remote changes             │
│  git pull                    Fetch + merge                       │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 6: Merging**, we'll learn:
- Fast-forward vs merge commits
- How to resolve conflicts
- Merge strategies
