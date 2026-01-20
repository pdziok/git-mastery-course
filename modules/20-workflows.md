# Module 20: Git Workflows - Team Collaboration Patterns

## 🎯 Learning Objectives

After this module, you will:
- Understand different Git workflow models
- Know when to use Gitflow vs simpler alternatives
- Implement GitHub Flow for most projects
- Understand Trunk-Based Development

---

## 📖 Why Workflows Matter

Without a workflow, teams end up with:
- Merge conflicts everywhere
- Unclear which branch is "safe"
- Long-lived branches that drift
- No clear release process

```
CHAOS:                              ORDER (with workflow):

     ???                            main ──────────────────────>
    /   \                              \        /      \     /
   ?     ???                            feat-A─/        feat-B
  /         \                                    release-1.0
 ???         ?
    \       /
     ?????
```

---

## 📖 The Three Main Workflows

| Workflow | Complexity | Best For |
|----------|------------|----------|
| **GitHub Flow** | Simple | Web apps, continuous deployment |
| **Gitflow** | Complex | Scheduled releases, multiple versions |
| **Trunk-Based** | Minimal | High-performing teams, feature flags |

---

## 📖 Part 1: GitHub Flow (Recommended for Most)

The simplest workflow that actually works for teams.

### The Rules

1. `main` is always deployable
2. Create feature branches from `main`
3. Push regularly, open PR early
4. Merge only after review
5. Deploy immediately after merge

### Visualization

```
main:     ●────●────●────●────●────●────●────●
              \    /    \    /    \    /
feature-a:     ●──●     |    |    |    |
                        |    |    |    |
feature-b:              ●───●     |    |
                                  |    |
bugfix-c:                         ●───●
```

### Implementation

```bash
# 1. Start from updated main
git switch main
git pull origin main

# 2. Create feature branch
git switch -c feature/user-search

# 3. Work and commit
# ... make changes ...
git add .
git commit -m "feat(search): add user search API"

# 4. Push and open PR
git push -u origin feature/user-search
# Open PR on GitHub/GitLab

# 5. After review and approval, merge
# (Usually done via GitHub UI with "Squash and merge")

# 6. Clean up
git switch main
git pull origin main
git branch -d feature/user-search
```

### Pros & Cons

```
✅ PROS:
  - Simple to understand
  - Fast feedback cycles
  - main is always deployable
  - Works well with CI/CD

❌ CONS:
  - Needs good CI/CD pipeline
  - Difficult to manage multiple releases
  - Requires discipline to keep main stable
```

---

## 📖 Part 2: Gitflow (For Scheduled Releases)

Created by Vincent Driessen in 2010. Complex but structured.

### The Branches

| Branch | Purpose | Long-lived? |
|--------|---------|-------------|
| `main` | Production code | ✓ |
| `develop` | Integration branch | ✓ |
| `feature/*` | New features | No |
| `release/*` | Release preparation | No |
| `hotfix/*` | Emergency fixes | No |

### Visualization

```
main:     ●────────────────●─────────────────●
          │                 ↑                 ↑
          │                 │                 │
          │            release/1.0        hotfix/1.0.1
          │                 ↑                 ↑
          ▼                 │                 │
develop:  ●───●───●───●───●───●───●───●───●───●───●
              \   /   \   /       \   /
feature:       ●─●     ●─●         ●─●
```

### The Flow

```bash
# 1. Start a feature
git switch develop
git pull origin develop
git switch -c feature/new-dashboard

# Work, commit, push...

# 2. Finish feature (merge back to develop)
git switch develop
git merge --no-ff feature/new-dashboard
git push origin develop
git branch -d feature/new-dashboard

# 3. Start a release
git switch develop
git switch -c release/1.0.0

# Only bugfixes here, no new features!
git commit -m "fix: version bump to 1.0.0"

# 4. Finish release
git switch main
git merge --no-ff release/1.0.0
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin main --tags

git switch develop
git merge --no-ff release/1.0.0
git push origin develop

git branch -d release/1.0.0

# 5. Hotfix (emergency production fix)
git switch main
git switch -c hotfix/1.0.1

# Fix the bug...
git commit -m "fix: critical security patch"

git switch main
git merge --no-ff hotfix/1.0.1
git tag -a v1.0.1 -m "Hotfix 1.0.1"
git push origin main --tags

git switch develop
git merge --no-ff hotfix/1.0.1
git push origin develop

git branch -d hotfix/1.0.1
```

### Gitflow Tools

```bash
# Install gitflow extensions
# macOS:
brew install git-flow

# Ubuntu:
sudo apt install git-flow

# Initialize in a repo
git flow init

# Use the commands
git flow feature start new-dashboard
git flow feature finish new-dashboard
git flow release start 1.0.0
git flow release finish 1.0.0
git flow hotfix start 1.0.1
git flow hotfix finish 1.0.1
```

### Pros & Cons

```
✅ PROS:
  - Clear structure for complex projects
  - Supports multiple release versions
  - Parallel development streams
  - Good for scheduled releases (mobile apps, etc.)

❌ CONS:
  - Complex! Many branches to manage
  - Merge hell with long-lived branches
  - Overhead for simple projects
  - Slower release cycles
```

### When to Use Gitflow

```
USE GITFLOW IF:
✓ You have scheduled releases (not continuous)
✓ You support multiple versions simultaneously
✓ You have separate QA environments
✓ You need release branches for stabilization

DON'T USE GITFLOW IF:
✗ You deploy continuously (use GitHub Flow)
✗ You have a small team
✗ You don't need multiple live versions
✗ Speed of delivery is critical
```

---

## 📖 Part 3: Trunk-Based Development (Advanced)

Everyone commits to main/trunk. Requires discipline and tooling.

### The Rules

1. Small, frequent commits to main
2. Feature flags for incomplete features
3. Very fast CI (minutes, not hours)
4. Code review before merge (short-lived branches OK)

### Visualization

```
main:     ●──●──●──●──●──●──●──●──●──●──●──●──●
             │  │     │     │     │
           small commits, all to main

With short-lived branches (common variant):

main:     ●────●────●────●────●────●────●────●
              /    /    /    /    /    /
feature:     ● (hours, not days)
```

### Pros & Cons

```
✅ PROS:
  - Minimal merge conflicts
  - Always releasable
  - Fast feedback
  - Simple mental model

❌ CONS:
  - Requires excellent CI
  - Needs feature flags
  - Requires team discipline
  - Harder for junior developers
```

---

## 📖 Comparison Chart

```
┌────────────────┬────────────────┬────────────────┬────────────────┐
│                │  GitHub Flow   │    Gitflow     │  Trunk-Based   │
├────────────────┼────────────────┼────────────────┼────────────────┤
│ Complexity     │ Low            │ High           │ Low            │
│ Release Cycle  │ Continuous     │ Scheduled      │ Continuous     │
│ Long Branches  │ No             │ Yes            │ No             │
│ Merge Conflicts│ Rare           │ Common         │ Very Rare      │
│ Versions       │ Latest only    │ Multiple       │ Latest only    │
│ CI Required    │ Yes            │ Optional       │ Critical       │
│ Feature Flags  │ Optional       │ No             │ Essential      │
│ Team Size      │ Any            │ Large          │ Mature teams   │
└────────────────┴────────────────┴────────────────┴────────────────┘
```

---

## 🔬 Hands-On Exercise 18.1: GitHub Flow in Action

```bash
cd ~/git-workshop
rm -rf workflow-demo && mkdir workflow-demo && cd workflow-demo
git init

# Create initial project
echo "# My App" > README.md
echo "v1.0.0" > VERSION
git add .
git commit -m "chore: initial project setup"

# Simulate main as production
git branch -M main

# Developer 1: Feature A
git switch -c feature/user-auth
echo "auth code" > auth.js
git add auth.js
git commit -m "feat(auth): add authentication module"
git commit --allow-empty -m "feat(auth): add login endpoint"

# Create PR (simulated)
echo "PR #1: Add user authentication"
echo "Review: Approved"

# Merge with squash (simulating GitHub's "Squash and merge")
git switch main
git merge --squash feature/user-auth
git commit -m "feat(auth): add user authentication (#1)"

# Clean up
git branch -d feature/user-auth

# Developer 2: Feature B (parallel)
git switch -c feature/search
echo "search code" > search.js
git add search.js
git commit -m "feat(search): add search functionality"

# Merge normally
git switch main
git merge --no-ff feature/search -m "Merge PR #2: Add search feature"

git branch -d feature/search

# Check clean history
git log --oneline --graph
```

---

## 🔬 Hands-On Exercise 18.2: Simulated Gitflow

```bash
cd ~/git-workshop
rm -rf gitflow-demo && mkdir gitflow-demo && cd gitflow-demo
git init

# Initial setup
echo "# My App v0.1" > README.md
git add .
git commit -m "chore: initial setup"
git branch -M main

# Create develop branch
git switch -c develop

# Feature work
git switch -c feature/dashboard
echo "dashboard" > dashboard.js
git add .
git commit -m "feat: add dashboard"
git switch develop
git merge --no-ff feature/dashboard -m "Merge feature/dashboard"
git branch -d feature/dashboard

# More features
git switch -c feature/reports
echo "reports" > reports.js
git add .
git commit -m "feat: add reports"
git switch develop
git merge --no-ff feature/reports -m "Merge feature/reports"
git branch -d feature/reports

# Start release
git switch -c release/1.0
echo "1.0.0" > VERSION
git add .
git commit -m "chore: bump version to 1.0.0"

# Finish release
git switch main
git merge --no-ff release/1.0 -m "Release 1.0.0"
git tag v1.0.0

git switch develop
git merge --no-ff release/1.0 -m "Merge release/1.0 back to develop"
git branch -d release/1.0

# Hotfix!
git switch main
git switch -c hotfix/1.0.1
echo "1.0.1" > VERSION
echo "// security fix" >> dashboard.js
git add .
git commit -m "fix: security patch"

git switch main
git merge --no-ff hotfix/1.0.1 -m "Hotfix 1.0.1"
git tag v1.0.1

git switch develop
git merge --no-ff hotfix/1.0.1 -m "Merge hotfix back to develop"
git branch -d hotfix/1.0.1

# View the result
git log --oneline --graph --all
```

---

## 📖 Recommendations by Project Type

| Project Type | Recommended Workflow |
|--------------|---------------------|
| Web App (SaaS) | GitHub Flow |
| Mobile App | Gitflow |
| Open Source Library | GitHub Flow + release branches |
| Microservices | Trunk-Based or GitHub Flow |
| Enterprise Monolith | Gitflow |
| Startup/MVP | GitHub Flow |
| High-frequency trading | Trunk-Based |

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** Which workflow is simplest?

2. **Q:** In Gitflow, what's the purpose of the `develop` branch?

3. **Q:** What's required for Trunk-Based Development?

4. **Q:** When should you consider Gitflow?

5. **Q:** In GitHub Flow, when is `main` safe to deploy?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** GitHub Flow (just main + feature branches)

2. **A:** Integration branch where features are merged before release

3. **A:** Excellent CI, feature flags, team discipline

4. **A:** When you have scheduled releases, need multiple versions, or have long QA cycles

5. **A:** Always - main should always be deployable in GitHub Flow

</details>

---

## 🎯 Workflow Quick Reference

```
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW SELECTION                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  GITHUB FLOW (default choice)                                   │
│  main ──────────────────────────                                │
│       \──feature──/                                              │
│                                                                   │
│  GITFLOW (scheduled releases)                                   │
│  main ────────────────────────                                   │
│  develop ──────────────────                                      │
│          \feature/ \release/                                     │
│                                                                   │
│  TRUNK-BASED (mature teams)                                     │
│  main ──●──●──●──●──●──                                         │
│  (everyone commits to main)                                      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 21: Cross-Platform Git**, we'll cover:
- Windows vs macOS/Linux differences
- Line ending issues
- Path and case sensitivity
- Running exercises in Docker
