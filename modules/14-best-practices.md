# Module 14: Best Practices - The Professional Way

## 🎯 Learning Objectives

After this module, you will:
- Write conventional commits that tell a story
- Reference tickets (Jira, GitHub, GitLab) in commits and branches
- Use feature branches effectively
- Maintain linear, readable history
- Know professional Git workflows

---

## 📖 Part 1: Conventional Commits

### Why Conventional Commits?

```
BAD COMMITS:                        GOOD COMMITS:
─────────────                       ─────────────
"update"                            "feat: add user authentication"
"fix"                               "fix: resolve login redirect loop"
"WIP"                               "docs: update API documentation"
"stuff"                             "refactor: extract validation logic"
"changes"                           "test: add unit tests for auth"
"asdfgh"                            "chore: update dependencies"
```

Good commits:
- Are searchable (`git log --grep="feat"`)
- Can generate changelogs automatically
- Help teammates understand changes
- Make code review easier

### The Format

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature for the user |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, no feature/fix |
| `test` | Adding/updating tests |
| `chore` | Maintenance tasks |
| `perf` | Performance improvements |
| `ci` | CI/CD configuration |
| `build` | Build system changes |
| `revert` | Reverting a previous commit |

### Examples

```bash
# Feature
git commit -m "feat(auth): add Google OAuth login"

# Bug fix
git commit -m "fix(cart): prevent negative quantities"

# With body for more context
git commit -m "fix(api): handle timeout on slow connections

The API client was failing silently when requests took longer
than 30 seconds. Now we properly catch timeout errors and
show a user-friendly message.

Closes #423"

# Breaking change
git commit -m "feat(api)!: change authentication to JWT

BREAKING CHANGE: API now requires Bearer token in header.
Old session-based auth is no longer supported."
```

---

## 🔬 Hands-On Exercise 12.1: Writing Good Commits

```bash
# Setup
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create initial structure
mkdir -p src tests docs
echo "# My App" > README.md
git add README.md
git commit -m "chore: initial project setup"

# Add a feature
echo "function login() {}" > src/auth.js
git add src/auth.js
git commit -m "feat(auth): add login function skeleton"

# Fix something
echo "function login(user, pass) {}" > src/auth.js
git add src/auth.js
git commit -m "fix(auth): require credentials for login

Login was callable without parameters, causing null
reference errors. Now properly requires user and pass."

# Add documentation
echo "## Authentication\nUse login() to authenticate." > docs/auth.md
git add docs/auth.md
git commit -m "docs(auth): add authentication guide"

# Refactor
echo "// Validation module" > src/validate.js
git add src/validate.js
git commit -m "refactor: extract validation to separate module"

# Add tests
echo "test('login works', () => {})" > tests/auth.test.js
git add tests/auth.test.js
git commit -m "test(auth): add login function tests"

# Check your beautiful history!
git log --oneline
```

### Commit Message Guidelines

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMMIT MESSAGE RULES                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Use imperative mood: "add" not "added" or "adds"            │
│     ✓ "feat: add login button"                                  │
│     ✗ "feat: added login button"                                │
│                                                                 │
│  2. Don't end with period                                       │
│     ✓ "fix: resolve null pointer"                               │
│     ✗ "fix: resolve null pointer."                              │
│                                                                 │
│  3. Keep subject under 50 characters                            │
│     ✓ "feat(api): add user endpoint"                            │
│     ✗ "feat(api): add new user endpoint with authentication..." │
│                                                                 │
│  4. Separate subject from body with blank line                  │
│                                                                 │
│  5. Use body to explain WHAT and WHY, not HOW                   │
│     (code shows how)                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📖 Part 2: Ticket/Issue References in Git

In enterprise environments, you'll work with issue trackers like Jira, GitHub Issues, or GitLab Issues. Referencing tickets in commits and branches creates traceability between code and requirements.

### Why Reference Tickets?

- **Traceability** - See which code change addressed which requirement
- **Auto-linking** - Click from commit to ticket (and vice versa)
- **Automation** - Auto-close issues, update ticket status
- **Context** - Future developers can find the "why" behind changes

### Branch Naming with Tickets

```bash
# Format: type/TICKET-ID-short-description

# Jira (PROJECT-123 format)
git switch -c feat/PROJ-123-user-authentication
git switch -c fix/PROJ-456-login-redirect-loop
git switch -c chore/PROJ-789-update-dependencies

# GitHub Issues (#123 format)
git switch -c feat/123-user-authentication
git switch -c fix/456-login-redirect-loop

# GitLab Issues (#123 format)
git switch -c feat/123-user-authentication

# Some teams prefer ticket first
git switch -c PROJ-123/feat/user-authentication
git switch -c PROJ-123-user-authentication
```

### Commit Messages with Ticket References

Different platforms have different conventions for auto-linking:

```bash
# GitHub/GitLab - use # followed by issue number
git commit -m "feat(auth): add login form

Implements the new login UI with validation.

Closes #123"

# Jira - use PROJECT-ID format
git commit -m "feat(auth): add login form

Implements the new login UI with validation.

Resolves: PROJ-123"

# You can also put the ticket in the subject line
git commit -m "feat(auth): add login form [PROJ-123]"
git commit -m "PROJ-123 feat(auth): add login form"
```

### Combining Tickets with Conventional Commits

The cleanest approach is putting the ticket in the footer or scope:

```bash
# Method 1: Ticket in footer (recommended)
git commit -m "feat(auth): add OAuth2 login flow

Adds Google and GitHub OAuth providers with proper
token refresh handling.

Refs: PROJ-123"

# Method 2: Ticket in scope
git commit -m "feat(PROJ-123): add OAuth2 login flow"

# Method 3: Ticket at end of subject
git commit -m "feat(auth): add OAuth2 login flow [PROJ-123]"

# Method 4: Ticket prefix (some teams prefer this)
git commit -m "PROJ-123 feat(auth): add OAuth2 login flow"
```

### Auto-Linking and Automation

**GitHub** auto-links when you:
```bash
# Reference an issue
git commit -m "Related to #123"

# Close an issue (when merged to default branch)
git commit -m "Fixes #123"
git commit -m "Closes #123"
git commit -m "Resolves #123"

# Close multiple issues
git commit -m "Fixes #123, closes #456"
```

**GitLab** uses similar keywords:
```bash
git commit -m "Closes #123"
git commit -m "Fixes #123"
# Also supports: close, closed, fix, fixed, resolve, resolved
```

**Jira** (with GitHub/GitLab integration):
```bash
# Smart commits (if configured)
git commit -m "PROJ-123 #done Add login feature"
git commit -m "PROJ-123 #time 2h Fixed the login bug"
git commit -m "PROJ-123 #comment This needs review"
```

### Team Conventions Examples

```
┌─────────────────────────────────────────────────────────────────┐
│                 TICKET REFERENCE PATTERNS                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  BRANCHES                                                       │
│  feat/PROJ-123-short-description    Jira style                  │
│  fix/123-short-description          GitHub/GitLab style         │
│  PROJ-123/feat/description          Ticket-first style          │
│                                                                 │
│  COMMITS (choose one pattern for your team)                     │
│                                                                 │
│  Pattern A: Footer reference (cleanest)                         │
│  feat(auth): implement SSO login                                │
│                                                                 │
│  Refs: PROJ-123                                                 │
│                                                                 │
│  Pattern B: Scope contains ticket                               │
│  feat(PROJ-123): implement SSO login                            │
│                                                                 │
│  Pattern C: Subject suffix                                      │
│  feat(auth): implement SSO login [PROJ-123]                     │
│                                                                 │
│  Pattern D: Subject prefix (non-conventional)                   │
│  PROJ-123 implement SSO login                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 🔬 Hands-On Exercise: Ticket References

```bash
cd ~/git-workshop
rm -rf ticket-demo && mkdir ticket-demo && cd ticket-demo
git init

# Create branch with ticket reference
git switch -c feat/PROJ-123-user-profile

# Make commits with ticket references
echo "profile code" > profile.js
git add profile.js
git commit -m "feat(user): add profile page skeleton

Initial layout for user profile page with
placeholder sections for avatar and bio.

Refs: PROJ-123"

echo "avatar code" >> profile.js
git add profile.js
git commit -m "feat(PROJ-123): add avatar upload"

echo "bio code" >> profile.js
git add profile.js
git commit -m "feat(user): add bio editor [PROJ-123]"

# View history - all commits reference PROJ-123
git log --oneline

# Search for all commits related to a ticket
git log --grep="PROJ-123" --oneline
```

---

## 📖 Part 3: Feature Branch Workflow

### The Workflow

```
main ─────────────────────────────────────────────────────────>
            \                    /            \            /
             \──── feature-a ───/              \── fix-b ─/
                   (work)       (merge/PR)        (work)  (merge)
```

### Rules

1. **main is always deployable** - Never commit broken code
2. **Every change gets a branch** - No direct commits to main
3. **Branches are short-lived** - Days, not weeks
4. **Code review before merge** - Pull requests

---

## 🔬 Hands-On Exercise 12.2: Feature Branch Workflow

```bash
# Simulate the workflow

# Start from main
git switch main

# 1. CREATE BRANCH (from latest main)
git pull origin main  # Always start fresh!
git switch -c feat/user-registration

# 2. WORK on the feature
echo "register code" > src/register.js
git add src/register.js
git commit -m "feat(auth): add user registration form"

echo "validate code" > src/validate-user.js
git add src/validate-user.js
git commit -m "feat(auth): add registration validation"

# 3. KEEP UP TO DATE (if main moved)
git fetch origin
git rebase origin/main  # Put your work on top of latest main

# 4. CLEAN UP before PR
git rebase -i origin/main  # Squash WIP commits if any

# 5. PUSH
git push -u origin feat/user-registration

# 6. CREATE PR (on GitHub/GitLab)
# After approval...

# 7. MERGE (on GitHub/GitLab or locally)
git switch main
git pull origin main
git merge --no-ff feat/user-registration
git push origin main

# 8. CLEAN UP
git branch -d feat/user-registration
git push origin --delete feat/user-registration
```

---

## 📖 Part 4: Linear History

### Why Linear History?

```
MESSY HISTORY (hard to read):           LINEAR HISTORY (easy to read):
─────────────────────────────           ───────────────────────────────

*   Merge branch 'feat-x'               * Add feature X
|\                                      * Fix bug in login
| * WIP                                 * Add feature Y
| * more wip                            * Update dependencies
| * actually done                       * Refactor auth module
* |   Merge branch 'feat-y'
|\ \
| | * feat y stuff
| |/
|/|
* | Fix something
|/
* Old commit

git log --oneline shows 15 commits     git log --oneline shows 5 commits
Most are noise!                         Each one matters!
```

### How to Achieve Linear History

1. **Rebase instead of merge** (for updating feature branches)
2. **Squash commits** before merging
3. **Interactive rebase** to clean up
4. **Force push with --force-with-lease** after rebasing

```bash
# Config to prefer rebase
git config --global pull.rebase true

# Squash merge on PR (GitHub setting)
# Or manually:
git switch main
git merge --squash feat/my-feature
git commit -m "feat: complete my feature"
```

### The Rebase + Force Push Workflow

This is the professional workflow for maintaining linear history on feature branches:

```bash
# 1. You're working on a feature branch
git switch feat/my-feature

# 2. Main has moved on - your branch is behind
git fetch origin

# 3. Rebase your work onto latest main
git rebase origin/main

# 4. Your local branch now has different history than remote!
#    Normal push will fail. Force push is required.
git push --force-with-lease
```

**Why --force-with-lease instead of --force?**

```bash
# --force: Blindly overwrites remote branch (DANGEROUS!)
git push --force

# --force-with-lease: Only overwrites if no one else pushed (SAFE!)
git push --force-with-lease
# Fails if someone else pushed to your branch since you last fetched
```

`--force-with-lease` protects you from accidentally overwriting a teammate's commits.

### GitHub Branch Protection: Require Linear History

GitHub can enforce linear history as a branch protection rule:

```
Repository Settings → Branches → Branch protection rules → Add rule

☑️ Require linear history
   Prevents merge commits from being pushed to matching branches.
   Only allows "Rebase and merge" or "Squash and merge" strategies.
```

When enabled:
- Regular merge commits are blocked
- Only rebased or squashed commits can be merged
- Forces everyone to maintain linear history

### Trade-offs of Linear History

**Benefits:**
- ✅ Clean, readable `git log`
- ✅ Easy to bisect and find bugs
- ✅ Simple to understand project evolution
- ✅ Each commit tells a clear story
- ✅ Easy to cherry-pick and backport

**Drawbacks:**
- ❌ Requires more Git knowledge from team
- ❌ Force pushes can confuse beginners
- ❌ Loses "true" merge history (when branches were actually merged)
- ❌ Conflicts must be resolved during rebase (potentially multiple times)
- ❌ Rebasing shared branches is dangerous

**Rule of thumb:** Use rebase for YOUR feature branches, never for shared branches.

---

## 🔬 Hands-On Exercise 14.3: The Rebase Workflow

```bash
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create initial history
echo "v1" > app.js
git add . && git commit -m "Initial commit"

# Simulate main moving forward
echo "v2" >> app.js
git commit -am "Main: update v2"

# Create feature branch from earlier point
git switch -c feat/my-feature HEAD~1

# Do feature work
echo "feature" > feature.js
git add . && git commit -m "Add feature"

echo "more feature" >> feature.js
git commit -am "Enhance feature"

# Check status - main is ahead
git log --oneline --all --graph
# * abc (feat/my-feature) Enhance feature
# * def Add feature
# | * ghi (main) Main: update v2
# |/
# * jkl Initial commit

# Rebase onto main
git rebase main

# Now linear!
git log --oneline --all --graph
# * pqr (HEAD -> feat/my-feature) Enhance feature
# * stu Add feature
# * ghi (main) Main: update v2
# * jkl Initial commit

# If this was pushed before, you'd need:
# git push --force-with-lease
```

---

## 🔬 Hands-On Exercise 14.4: Cleaning Up Before PR

```bash
# Scenario: You made messy commits during development

git switch -c feat/messy-feature

echo "start" > feature.js
git add feature.js
git commit -m "WIP"

echo "more work" >> feature.js
git add feature.js
git commit -m "still working"

echo "almost done" >> feature.js
git add feature.js
git commit -m "wip wip"

echo "// Final version" >> feature.js
git add feature.js
git commit -m "done I think"

echo "// Actually done" >> feature.js
git add feature.js
git commit -m "now really done"

# 5 messy commits! Let's clean up:
git log --oneline
# abc12 now really done
# def34 done I think
# ghi56 wip wip
# jkl78 still working
# mno90 WIP

# Squash all 5 into 1
git rebase -i HEAD~5

# In editor, change:
# pick mno90 WIP
# squash jkl78 still working
# squash ghi56 wip wip
# squash def34 done I think
# squash abc12 now really done

# Save, then write a proper message:
# feat: add new feature
#
# This feature does XYZ and improves ABC.

git log --oneline
# pqr11 feat: add new feature

# Clean! Ready for PR.
```

---

## 📖 Part 5: Professional Habits

### Daily Workflow

```bash
# MORNING: Start fresh
git switch main
git pull --rebase
git switch -c feat/todays-work

# DURING DAY: Commit often (can be messy)
git commit -m "WIP: checkpoint"
git commit -m "WIP: more progress"

# END OF DAY: Clean up before pushing
git rebase -i main  # Squash WIPs if needed
git push -u origin feat/todays-work
```

### Before Creating PR

```bash
# 1. Update from main
git fetch origin
git rebase origin/main

# 2. Clean up commits
git rebase -i origin/main

# 3. Run tests locally
npm test  # or your test command

# 4. Self-review your diff
git diff origin/main...HEAD

# 5. Push
git push --force-with-lease  # Safe force after rebase
```

### .gitignore Best Practices

```gitignore
# Dependencies
node_modules/
vendor/
.venv/

# Build outputs
dist/
build/
*.class

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Environment/Secrets (NEVER COMMIT!)
.env
.env.local
*.pem
secrets.json

# Logs
*.log
logs/
```

### Git Aliases (Time Savers)

```bash
# Add to ~/.gitconfig
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "restore --staged"
git config --global alias.amend "commit --amend --no-edit"

# Now you can use:
git co main       # git checkout main
git br -a         # git branch -a
git lg            # Pretty graph log
git amend         # Quick amend last commit
```

---

## 📖 Part 6: Common Pitfalls to Avoid

### ❌ DON'T

```bash
# Force push to shared branches
git push --force origin main  # NEVER!

# Commit secrets
git add .env  # NEVER!

# Commit large binary files
git add huge-video.mp4  # Use Git LFS instead

# Make huge commits
git add .
git commit -m "All the things"  # Too big to review!

# Commit without testing
git commit -m "Should work"  # Test first!
```

### ✅ DO

```bash
# Pull before starting work
git pull --rebase origin main

# Commit small, logical units
git add src/auth.js
git commit -m "feat(auth): add password validation"

# Write meaningful messages
git commit -m "fix(cart): calculate tax correctly for EU customers"

# Review before committing
git diff --staged  # Check what you're about to commit

# Clean up before PR
git rebase -i origin/main
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What's the format of a conventional commit?

2. **Q:** How do you reference a Jira ticket in a branch name?

3. **Q:** Why should you rebase your feature branch on main regularly?

4. **Q:** What's the difference between `git merge` and `git merge --squash`?

5. **Q:** Why shouldn't you `git push --force` to main?

6. **Q:** What should you do before creating a PR?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `type(scope): description` - e.g., `feat(auth): add login`

2. **A:** Include the ticket ID in the branch name, e.g., `feat/PROJ-123-add-login` or `PROJ-123/feat/add-login`

3. **A:** To keep your branch up-to-date and avoid big merge conflicts later

4. **A:** Normal merge preserves all commits; squash combines all branch commits into one

5. **A:** It rewrites history that teammates may have based work on, causing sync issues

6. **A:** Update from main, clean up commits (rebase -i), run tests, self-review the diff

</details>

---

## 🎯 Best Practices Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    GIT BEST PRACTICES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  COMMITS                                                        │
│  ✓ Use conventional commit format                               │
│  ✓ Reference tickets in footer or scope                         │
│  ✓ Write in imperative mood                                     │
│  ✓ Keep subject under 50 chars                                  │
│  ✓ Explain WHY in body                                          │
│  ✓ One logical change per commit                                │
│                                                                 │
│  BRANCHES                                                       │
│  ✓ Create from latest main                                      │
│  ✓ Include ticket ID (feat/PROJ-123-description)                │
│  ✓ Use descriptive names (feat/, fix/, etc.)                    │
│  ✓ Keep branches short-lived                                    │
│  ✓ Delete after merge                                           │
│                                                                 │
│  WORKFLOW                                                       │
│  ✓ Pull --rebase to stay current                                │
│  ✓ Clean up before PR (interactive rebase)                      │
│  ✓ Review your own diff before PR                               │
│  ✓ Never force push to shared branches                          │
│                                                                 │
│  HYGIENE                                                        │
│  ✓ Use .gitignore properly                                      │
│  ✓ Never commit secrets                                         │
│  ✓ Test before committing                                       │
│  ✓ Keep commits atomic (one concern each)                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 15: Terminal Editors**, we'll learn:
- Using nano, vi, and vim for Git operations
- Surviving interactive rebase without an IDE
- Essential editor commands for Git workflows

---

## 📚 Further Reading

- [How to Write a Git Commit Message](https://cbea.ms/git-commit/) - The definitive guide
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message standard
