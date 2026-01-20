# Module 23: Advanced Techniques - Senior Engineer Toolkit

## 🎯 Learning Objectives

After this module, you will:
- Use interactive staging (`git add -p`)
- Work with multiple branches using worktrees
- Handle advanced rebase scenarios (`--onto`)
- Manage repository performance and cleanup
- Create archives and bundles

---

## 📖 Part 1: Interactive Staging (`git add -p`)

Stage parts of files, not entire files. Essential for clean commits!

### The Workflow

```bash
# You've made multiple unrelated changes in one file
# Stage only some of them

git add -p file.js
# or: git add --patch file.js
```

Git shows each "hunk" (chunk of changes) and asks:

```
@@ -10,6 +10,8 @@ function processData(data) {
     console.log("Processing...");

+    // Added validation
+    if (!data) return null;
+
     return data.toUpperCase();
 }

Stage this hunk [y,n,q,a,d,s,e,?]?
```

### The Commands

| Key | Action |
|-----|--------|
| `y` | Yes, stage this hunk |
| `n` | No, skip this hunk |
| `q` | Quit (don't stage remaining) |
| `a` | Stage this and all remaining |
| `d` | Don't stage this or any remaining |
| `s` | Split into smaller hunks |
| `e` | Manually edit the hunk |
| `?` | Show help |

### Exercise: Interactive Staging

```bash
cd ~/git-workshop
mkdir -p advanced-test && cd advanced-test
git init

# Create file with initial content
cat > app.js << 'EOF'
function greet(name) {
    console.log("Hello " + name);
}

function farewell(name) {
    console.log("Goodbye " + name);
}
EOF
git add app.js
git commit -m "Initial functions"

# Make multiple changes
cat > app.js << 'EOF'
function greet(name) {
    // Added validation
    if (!name) return;
    console.log("Hello " + name);
}

function farewell(name) {
    // Added validation
    if (!name) return;
    console.log("Goodbye " + name);
}

function wave(name) {
    console.log("*waves at " + name + "*");
}
EOF

# Stage only the greet function changes
git add -p app.js

# Use 'y' for greet changes, 'n' for farewell, 'n' for wave
# Then:
git commit -m "feat(greet): add validation"

# Stage and commit farewell
git add -p app.js  # 'y' for farewell
git commit -m "feat(farewell): add validation"

# Stage and commit wave
git add app.js
git commit -m "feat: add wave function"

# Clean commits!
git log --oneline
```

---

## 📖 Part 2: Git Worktrees

Work on multiple branches simultaneously without switching!

```
Traditional workflow:
  ~/project/   (main branch)
     ↓ git switch feature → files change!
     ↓ git switch main → files change again!

With worktrees:
  ~/project/           (main branch)
  ~/project-feature/   (feature branch) ← separate directory!
  ~/project-hotfix/    (hotfix branch)  ← another directory!
```

### Commands

```bash
# List current worktrees
git worktree list

# Create a new worktree for a branch
git worktree add ../project-feature feature-branch

# Create worktree with new branch
git worktree add -b new-feature ../project-newfeature

# Remove a worktree
git worktree remove ../project-feature

# Prune stale worktree info
git worktree prune
```

### Exercise: Using Worktrees

```bash
cd ~/git-workshop/advanced-test

# Create main content
echo "v1.0" > VERSION
git add VERSION
git commit -m "Add version"

# Create feature branch
git branch feature-x

# Add worktree for feature
git worktree add ../advanced-test-feature feature-x

# Now you have TWO directories!
ls ../
# advanced-test/         ← main
# advanced-test-feature/ ← feature-x

# Work on main
echo "main work" > main.txt
git add main.txt
git commit -m "Main work"

# Work on feature (in separate terminal or:)
cd ../advanced-test-feature
echo "feature work" > feature.txt
git add feature.txt
git commit -m "Feature work"

# Both branches have different commits!
cd ../advanced-test
git log --oneline --all --graph

# Clean up
git worktree remove ../advanced-test-feature
```

### When to Use Worktrees

- Running tests on main while developing on feature
- Quick hotfix without stashing current work
- Comparing behavior between branches
- Long-running builds on one branch

---

## 📖 Part 3: Advanced Rebase with `--onto`

Rebase only PART of a branch onto a new base.

### The Scenario

```
You branched feature from develop.
But the feature should have been based on main!

Current:
main:      A ── B
            \
develop:     C ── D
                  \
feature:           E ── F ── G

Want:
main:      A ── B ── E' ── F' ── G'

Not:
main:      A ── B ── C ── D ── E' ── F' ── G'  (includes develop commits!)
```

### The Command

```bash
# git rebase --onto <new-base> <old-base> <branch>
git rebase --onto main develop feature

# This means:
# "Take commits from feature that are NOT in develop,
#  and replay them onto main"
```

### Exercise: Rebase --onto

```bash
cd ~/git-workshop
rm -rf onto-test && mkdir onto-test && cd onto-test
git init

# Create main
echo "main" > main.txt
git add . && git commit -m "A: main base"
echo "more main" >> main.txt
git add . && git commit -m "B: main update"

# Create develop from main
git checkout -b develop
echo "develop" > develop.txt
git add . && git commit -m "C: develop start"
echo "more develop" >> develop.txt
git add . && git commit -m "D: develop update"

# Create feature from develop (oops, should be from main!)
git checkout -b feature
echo "feature" > feature.txt
git add . && git commit -m "E: feature start"
echo "more feature" >> feature.txt
git add . && git commit -m "F: feature update"

# See the current state
git log --oneline --graph --all

# Now rebase feature onto main, excluding develop commits
git rebase --onto main develop feature

# Check - feature now has only E, F on top of B (main)!
git log --oneline --graph --all
ls
# main.txt, feature.txt - NO develop.txt!
```

---

## 📖 Part 4: Git Clean - Remove Untracked Files

```bash
# See what would be deleted (dry run)
git clean -n

# Remove untracked files
git clean -f

# Remove untracked directories too
git clean -fd

# Remove ignored files too (careful!)
git clean -fdx

# Interactive mode
git clean -i
```

### When to Use

- Before important operations
- After failed build/test that created artifacts
- Resetting to pristine state

```bash
# Complete reset (tracked files + untracked)
git checkout -- .
git clean -fd
```

---

## 📖 Part 5: Git Maintenance and Performance

### Repository Maintenance

```bash
# Run garbage collection (cleans up loose objects)
git gc

# Aggressive GC (slower, more thorough)
git gc --aggressive

# Verify repository integrity
git fsck

# Prune unreachable objects
git prune

# Pack objects for efficiency
git repack -a -d
```

### Repository Statistics

```bash
# Count objects
git count-objects -v

# Largest objects
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sort -k3 -n | tail -20

# Find large files in history
git rev-list --objects --all | git cat-file --batch-check='%(objectname) %(objectsize) %(rest)' | sort -k2 -n | tail -20
```

### Shallow and Partial Clones

```bash
# Clone with limited history (faster!)
git clone --depth 1 https://github.com/user/repo.git

# Clone specific branch only
git clone --single-branch --branch main https://github.com/user/repo.git

# Deepen a shallow clone later
git fetch --unshallow

# Partial clone (blobs on-demand)
git clone --filter=blob:none https://github.com/user/repo.git
```

---

## 📖 Part 6: Git Archive and Bundle

### Archive (Export without .git)

```bash
# Create zip archive of current HEAD
git archive --format=zip HEAD > release.zip

# Create tar.gz
git archive --format=tar.gz --prefix=project-v1.0/ HEAD > project-v1.0.tar.gz

# Archive specific path
git archive HEAD -- src/ > src-only.tar

# Archive from specific tag
git archive --prefix=myproject-1.0/ v1.0.0 | gzip > myproject-1.0.tar.gz
```

### Bundle (Transfer repos without network)

```bash
# Create bundle of entire repo
git bundle create repo.bundle --all

# Create bundle of specific branch
git bundle create main.bundle main

# Create bundle of new commits only
git bundle create updates.bundle main ^origin/main

# Clone from bundle
git clone repo.bundle myproject

# Fetch from bundle
git fetch repo.bundle main:main
```

### When to Use Bundle

- Sneakernet (USB transfer)
- Firewalled environments
- Backup of repo
- Sharing without central server

---

## 📖 Part 7: Git Notes

Add metadata to commits without modifying them.

```bash
# Add note to current commit
git notes add -m "Reviewed by Alice"

# Add note to specific commit
git notes add -m "Approved for release" abc123

# Show notes
git log --show-notes

# Edit a note
git notes edit abc123

# Remove note
git notes remove abc123

# Push notes (not pushed by default!)
git push origin refs/notes/*
```

### Use Cases

- Code review tracking
- External metadata
- CI/CD annotations

---

## 📖 Part 8: Useful Log Queries

```bash
# Commits by author in date range
git log --author="John" --since="2024-01-01" --until="2024-03-31"

# Files changed in a commit
git show --name-only abc123

# Commits that changed a function
git log -p -S "function calculateTotal"

# All commits that touched a file
git log --follow -- path/to/file

# Commits between tags
git log v1.0..v2.0

# Contributors ranking
git shortlog -sn --all

# Commits per day
git log --format="%ai" | cut -d' ' -f1 | sort | uniq -c

# Find merge commits
git log --merges

# Find non-merge commits
git log --no-merges

# Commits with specific file patterns
git log -- "*.js"

# Diff between branches (files only)
git diff --name-only main..feature
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What does `git add -p` do?

2. **Q:** How do you work on two branches simultaneously?

3. **Q:** What does `git rebase --onto main develop feature` do?

4. **Q:** How do you remove all untracked files and directories?

5. **Q:** How do you transfer a Git repo without network access?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** Interactive/patch staging - lets you choose which parts of changes to stage

2. **A:** Use worktrees: `git worktree add ../other-dir other-branch`

3. **A:** Takes commits unique to feature (not in develop) and replays them onto main

4. **A:** `git clean -fd`

5. **A:** Use bundle: `git bundle create repo.bundle --all`, then transfer and clone from it

</details>

---

## 🎯 Advanced Commands Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    ADVANCED TECHNIQUES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INTERACTIVE STAGING                                            │
│  git add -p                 Stage hunks interactively           │
│  git reset -p               Unstage hunks interactively         │
│  git checkout -p            Discard hunks interactively         │
│                                                                 │
│  WORKTREES                                                      │
│  git worktree list          List all worktrees                  │
│  git worktree add <path> <branch>  Create worktree              │
│  git worktree remove <path>  Remove worktree                    │
│                                                                 │
│  ADVANCED REBASE                                                │
│  git rebase --onto A B C    Rebase C's unique commits onto A    │
│                                                                 │
│  CLEANUP                                                        │
│  git clean -n               Dry run                             │
│  git clean -fd              Remove untracked files/dirs         │
│  git gc                     Garbage collection                  │
│                                                                 │
│  EXPORT                                                         │
│  git archive HEAD > file.tar  Export without .git               │
│  git bundle create f.bundle --all  Portable repo                │
│                                                                 │
│  NOTES                                                          │
│  git notes add -m "text"    Add metadata to commit              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 24: Repository Cleaning**, we'll learn:
- Removing large files from Git history
- Cleaning up accidentally committed secrets
- Using git-filter-repo and Git LFS
