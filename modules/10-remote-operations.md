# Module 10: Remote Operations - Collaboration

## 🎯 Learning Objectives

After this module, you will:
- Understand remotes, origin, and tracking branches
- Master fetch, pull, and push
- Handle "rejected" pushes
- Know what your IDE does for sync operations

---

## 🏠 The Shared Dropbox Metaphor (Expanded)

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│   YOUR COMPUTER                        THE CLOUD (GitHub/GitLab)   │
│   ─────────────                        ──────────────────────      │
│                                                                    │
│   ┌───────────────────────┐           ┌───────────────────────┐    │
│   │   Working Directory   │           │       origin          │    │
│   │   (your files)        │           │    (remote repo)      │    │
│   └───────────────────────┘           │                       │    │
│                                        │   main ─────────┐    │    │
│   ┌───────────────────────┐           │                  │    │    │
│   │   .git/               │           │   feature ──┐    │    │    │
│   │                       │           │             │    │    │    │
│   │   refs/heads/         │           └─────────────┴────┴────┘    │
│   │   ├── main ──────────────────────────────────────────┤         │
│   │   └── feature         │                               push     │
│   │                       │                               fetch    │
│   │   refs/remotes/origin/│      "My memory of remote"    pull     │
│   │   ├── main ───────────│      (updated by fetch/pull)           │
│   │   └── feature         │                                        │
│   └───────────────────────┘                                        │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

**Key insight:** `origin/main` is NOT the remote. It's your LOCAL memory of what the remote looked like last time you checked.

---

## 📖 Theory: fetch vs pull

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│   git fetch                          git pull                  │
│   ──────────                         ────────                  │
│                                                                │
│   1. Download new commits            1. Download new commits   │
│   2. Update origin/main              2. Update origin/main     │
│   3. STOP                            3. Merge into local main  │
│                                         (or rebase if config'd)│
│                                                                │
│   Safe, just looks.                  May cause conflicts!      │
│   "What's new?"                      "Get new AND apply it"    │
│                                                                │
└────────────────────────────────────────────────────────────────┘

git pull = git fetch + git merge  (by default)
git pull --rebase = git fetch + git rebase
```

---

## 🔬 Hands-On Exercise 8.1: Understanding Remotes

```bash
# Create a "remote" repository (simulating GitHub)
cd ~/git-workshop
rm -rf playground remote-repo

mkdir remote-repo && cd remote-repo
git init --bare   # Bare repo (no working directory)

# Create our local repo
cd ..
mkdir playground && cd playground
git init

# Add the remote
git remote add origin ../remote-repo

# See remotes
git remote -v
# origin  ../remote-repo (fetch)
# origin  ../remote-repo (push)

# Initial commit and push
echo "# Project" > README.md
git add README.md
git commit -m "Initial commit"

# Push to remote
git push -u origin main
# -u = --set-upstream: creates tracking relationship

# Check tracking
git branch -vv
# * main abc123 [origin/main] Initial commit
```

---

## 🔬 Hands-On Exercise 8.2: fetch vs pull

```bash
# Simulate a teammate's push (modify bare repo directly)
cd ../remote-repo
git config core.bare false
GIT_WORK_TREE=/tmp git checkout main
echo "teammate's work" > /tmp/teammate.txt
GIT_WORK_TREE=/tmp git add teammate.txt
GIT_WORK_TREE=/tmp git commit -m "Teammate's commit"
git config core.bare true

# Back to our repo
cd ../playground

# Check - we don't see the change yet
git log --oneline --all
# Just our commit

# FETCH - download but don't merge
git fetch origin

# Now we can see it
git log --oneline --all
# abc123 (HEAD -> main) Initial commit
# def456 (origin/main) Teammate's commit

# Our main hasn't moved, but origin/main has!
git status
# Your branch is behind 'origin/main' by 1 commit

# We can look at what changed
git log main..origin/main
# Shows commits in origin/main that we don't have

# Now PULL to actually get the changes
git pull
# Updates our main

git log --oneline
# def456 (HEAD -> main, origin/main) Teammate's commit
# abc123 Initial commit
```

---

## 📖 Theory: Tracking Branches

```bash
# When you clone, tracking is set up automatically
git clone <url>
# Creates: main -> origin/main

# When you create a branch from remote
git switch feature-x  # If origin/feature-x exists, tracks it

# Manually set tracking
git branch --set-upstream-to=origin/feature feature

# Or during first push
git push -u origin feature   # -u sets tracking

# See tracking relationships
git branch -vv
# * main     abc123 [origin/main] Latest commit
#   feature  def456 [origin/feature: ahead 2, behind 1] My work
```

**ahead 2, behind 1** = you have 2 commits they don't, they have 1 you don't.

---

## 🔬 Hands-On Exercise 8.3: Push Rejection

```bash
# Make a local commit
echo "local work" > local.txt
git add local.txt
git commit -m "Local work"

# Simulate another teammate push (while you were working)
cd ../remote-repo
git config core.bare false
GIT_WORK_TREE=/tmp git checkout main
echo "another teammate" > /tmp/another.txt
GIT_WORK_TREE=/tmp git add another.txt
GIT_WORK_TREE=/tmp git commit -m "Another teammate"
git config core.bare true

# Try to push
cd ../playground
git push

# REJECTED!
# "Updates were rejected because the remote contains work that you do not have locally"

# Solution 1: Pull and merge, then push
git pull   # Fetches + merges (might have conflicts)
git push   # Now it works

# OR Solution 2: Pull with rebase
git pull --rebase   # Fetches + rebases your work on top
git push            # Clean history!
```

---

## 📖 Theory: Common Remote Scenarios

### Scenario 1: "Your branch is ahead"
```bash
git status
# Your branch is ahead of 'origin/main' by 2 commits.

# You have unpushed work
git push  # Share it!
```

### Scenario 2: "Your branch is behind"
```bash
git status
# Your branch is behind 'origin/main' by 3 commits.

git pull  # Get the updates!
```

### Scenario 3: "Diverged"
```bash
git status
# Your branch and 'origin/main' have diverged,
# and have 2 and 3 different commits each.

# You both have work the other doesn't
# Option A: Merge
git pull  # Creates merge commit

# Option B: Rebase (cleaner)
git pull --rebase  # Replays your work on top
```

---

## 🔬 Hands-On Exercise 8.4: Working with Multiple Remotes

```bash
# Sometimes you have multiple remotes (fork workflow)
cd ~/git-workshop

# Create an "upstream" repo (original project)
mkdir upstream-repo && cd upstream-repo
git init --bare
cd ../playground

# Add it as another remote
git remote add upstream ../upstream-repo
git remote -v
# origin   ../remote-repo (fetch)
# origin   ../remote-repo (push)
# upstream ../upstream-repo (fetch)
# upstream ../upstream-repo (push)

# You can fetch from any remote
git fetch upstream
git fetch origin
git fetch --all  # All remotes

# Push to specific remote
git push origin main
git push upstream main
```

---

## 📖 Theory: push Configurations

```bash
# Push current branch (most common)
git push

# Push and set tracking
git push -u origin feature

# Push all branches
git push --all origin

# Push with tags
git push --tags

# Force push (DANGEROUS - overwrites remote history!)
git push --force

# Safer force (fails if remote has new commits)
git push --force-with-lease
```

⚠️ **NEVER** force push to shared branches (main, develop, etc.)!

---

## 🔬 Hands-On Exercise 8.5: What Your IDE Does

```bash
# When you click "Fetch":
git fetch origin

# When you click "Pull":
git pull
# (might be configured as git pull --rebase)

# When you click "Push":
git push

# When you see "↑2 ↓3" in status bar:
git rev-list --left-right --count origin/main...main
# Output: 3    2  (3 behind, 2 ahead)

# When you click "Sync" or "Update Project":
git fetch --all
git pull   # on current branch

# When you right-click remote branch → "Checkout":
git switch -c <branch> origin/<branch>

# When you "Create Pull Request" (IDE extension):
# Opens browser to GitHub/GitLab PR creation page
# After you've pushed your branch
```

---

## 📖 Pro Tips: Pull Strategies

Set up your preferred pull behavior:

```bash
# Always rebase when pulling (recommended for clean history)
git config --global pull.rebase true

# Always merge when pulling (default)
git config --global pull.rebase false

# Require explicit choice
git config --global pull.ff only
# Then you must specify: git pull --rebase or git pull --no-rebase
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What's the difference between `git fetch` and `git pull`?

2. **Q:** What does `origin/main` represent on your machine?

3. **Q:** What does "Your branch has diverged" mean?

4. **Q:** How do you push a new branch and set up tracking in one command?

5. **Q:** Why should you never `git push --force` to main?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `fetch` only downloads, doesn't merge. `pull` = fetch + merge (or rebase).

2. **A:** Your local memory/cache of what `main` looked like on the remote last time you fetched/pulled.

3. **A:** Both you and the remote have commits the other doesn't. You need to merge or rebase.

4. **A:** `git push -u origin <branch-name>` (the -u flag sets upstream tracking)

5. **A:** It overwrites history that others may have based their work on. Their repos will be out of sync.

</details>

---

## 🎯 Remote Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    REMOTE COMMANDS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SETUP                                                          │
│  git remote add <name> <url>   Add a remote                     │
│  git remote -v                 List remotes                     │
│  git remote remove <name>      Remove a remote                  │
│                                                                 │
│  FETCH & PULL                                                   │
│  git fetch                     Download all remotes             │
│  git fetch origin              Download from origin             │
│  git pull                      Fetch + merge                    │
│  git pull --rebase             Fetch + rebase (cleaner)         │
│                                                                 │
│  PUSH                                                           │
│  git push                      Push current branch              │
│  git push -u origin <branch>   Push + set tracking              │
│  git push --force-with-lease   Safe force push                  │
│                                                                 │
│  INSPECTION                                                     │
│  git branch -vv                Show tracking info               │
│  git remote show origin        Detailed remote info             │
│  git log main..origin/main     What's on remote we don't have   │
│  git log origin/main..main     What we have remote doesn't      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 11: Stash**, we'll learn:
- Temporarily saving work in progress
- Managing multiple stashes
- When stash is the right tool
