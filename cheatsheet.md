# Git Cheatsheet - Quick Reference

## The Three Areas

```
Working Directory → Staging Area → Repository
   (your files)       (index)       (commits)
      git add →          git commit →
   ← git restore    ← git restore --staged
```

---

## Setup & Config

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global pull.rebase true            # Cleaner pulls
git config --global init.defaultBranch main     # Use 'main' not 'master'
```

---

## Starting a Repo

```bash
git init                    # New local repo
git clone <url>             # Clone existing repo
```

---

## Daily Commands

```bash
# Status & Info
git status                  # What's changed?
git status -s               # Short format
git diff                    # Unstaged changes
git diff --staged           # Staged changes (will be committed)
git log --oneline           # Compact history
git log --oneline --graph --all  # Visual branch graph

# Staging & Committing
git add <file>              # Stage file
git add .                   # Stage all
git add -p                  # Interactive staging
git commit -m "message"     # Commit
git commit --amend          # Fix last commit
```

---

## Branches

```bash
# Create & Switch
git branch <name>           # Create branch
git switch <name>           # Switch to branch
git switch -c <name>        # Create AND switch
git checkout -b <name>      # Old way: create + switch

# List & Delete
git branch                  # List local
git branch -a               # List all (with remotes)
git branch -vv              # With tracking info
git branch -d <name>        # Delete (safe)
git branch -D <name>        # Delete (force)
```

---

## Merging

```bash
git merge <branch>          # Merge into current
git merge --no-ff <branch>  # Force merge commit
git merge --squash <branch> # Squash into single commit
git merge --abort           # Cancel merge

# Conflict resolution
# 1. Edit files, remove conflict markers
# 2. git add <file>
# 3. git commit
```

---

## Rebasing

```bash
git rebase main             # Rebase onto main
git rebase -i HEAD~3        # Interactive: last 3 commits
git rebase -i main          # Interactive: since main

# During rebase
git rebase --continue       # After fixing conflicts
git rebase --abort          # Cancel
git rebase --skip           # Skip current commit

# Interactive commands: pick, reword, squash, fixup, drop
```

---

## Remote Operations

```bash
git remote -v               # List remotes
git remote add origin <url> # Add remote

git fetch                   # Download changes (don't merge)
git pull                    # Fetch + merge
git pull --rebase           # Fetch + rebase (cleaner)

git push                    # Upload changes
git push -u origin <branch> # Push + set tracking
git push --force-with-lease # Safe force push (after rebase)
```

---

## Linear History Workflow

```bash
# Keep feature branch updated with main
git fetch origin
git rebase origin/main
git push --force-with-lease  # Required after rebase!

# Why --force-with-lease?
# - Safer than --force
# - Fails if someone else pushed to your branch
# - Prevents accidentally overwriting teammate's commits
```

---

## Undoing Things

```bash
# Discard working dir changes
git restore <file>

# Unstage (keep changes)
git restore --staged <file>

# Reset (move HEAD)
git reset --soft HEAD~1     # Uncommit, keep staged
git reset HEAD~1            # Uncommit, keep unstaged
git reset --hard HEAD~1     # Uncommit, DISCARD ALL

# Revert (safe for shared history)
git revert <commit>         # Create undo commit

# Recovery
git reflog                  # See where HEAD has been
git reset --hard HEAD@{2}   # Go back 2 moves
```

---

## Cherry-Pick

```bash
git cherry-pick <commit>    # Apply commit to current branch
git cherry-pick -x <commit> # With "cherry picked from" note
git cherry-pick -n <commit> # Don't commit, just stage
git cherry-pick --abort     # Cancel
```

---

## Stash

```bash
git stash                   # Save work in progress
git stash push -m "message" # With description
git stash -u                # Include untracked files

git stash list              # List stashes
git stash show              # Show latest stash diff
git stash show -p           # With full diff

git stash pop               # Apply + remove
git stash apply             # Apply, keep stash
git stash drop stash@{N}    # Delete specific
git stash clear             # Delete ALL
```

---

## Investigation

```bash
# Log searches
git log --author="Name"
git log --grep="text"       # In commit message
git log -S "code"           # When code added/removed
git log --since="2024-01-01"
git log -- path/file        # Changes to file

# Blame
git blame <file>            # Who changed each line
git blame -L 10,20 <file>   # Lines 10-20

# Bisect (find bug)
git bisect start
git bisect bad              # Current is broken
git bisect good <commit>    # This was good
# ... git tells you good/bad for each ...
git bisect reset            # Done
```

---

## Conventional Commits

```
Type: feat, fix, docs, style, refactor, test, chore

Format:
type(scope): description

Examples:
feat(auth): add Google OAuth login
fix(cart): prevent negative quantities
docs: update README with setup instructions
```

---

## Ticket/Issue References

```bash
# Branch naming with tickets
git switch -c feat/PROJ-123-user-auth    # Jira
git switch -c fix/123-login-bug          # GitHub/GitLab

# Commit with ticket in footer (recommended)
git commit -m "feat(auth): add login

Refs: PROJ-123"

# Close GitHub/GitLab issues
git commit -m "fix(auth): resolve redirect loop

Closes #123"

# Jira smart commits (if configured)
git commit -m "PROJ-123 #done Add feature"

# Search commits by ticket
git log --grep="PROJ-123"
```

---

## IDE Translation

| IDE Action | Git Command |
|------------|-------------|
| Commit | `git add <selected>` + `git commit` |
| Push | `git push` |
| Pull | `git pull` |
| Fetch | `git fetch` |
| Checkout Branch | `git switch <branch>` |
| New Branch | `git switch -c <branch>` |
| Merge | `git merge <branch>` |
| Revert (file) | `git restore <file>` |
| Revert (commit) | `git revert <commit>` |
| Stash | `git stash` |
| Show History | `git log` |
| Annotate/Blame | `git blame` |

---

## Golden Rules

1. **Commit often, push regularly** - Small, logical commits
2. **Pull before you push** - Stay up to date
3. **Never force push to main** - Rewrite only local history
4. **Never commit secrets** - Use .gitignore
5. **Write meaningful commit messages** - Future you will thank you

---

## Useful Aliases

```bash
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "restore --staged"
```

---

## .gitignore Patterns

```bash
# Pattern syntax
file.txt          # Any file.txt anywhere
/file.txt         # Only root file.txt
dir/              # Directory anywhere
/dir/             # Only root directory
*.log             # All .log files
/*.log            # .log only in root
**/logs           # logs dir at any depth
logs/**           # Everything inside logs/
!important.log    # Exception: DO track this

# Keep empty directory
logs/*
!logs/.gitkeep

# Debug: why is file ignored?
git check-ignore -v path/to/file

# Stop tracking already-tracked file
git rm --cached secrets.json
```

---

## Emergency Commands

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard HEAD

# I accidentally committed to wrong branch
git reset --soft HEAD~1
git stash
git switch correct-branch
git stash pop
git commit

# I need to find a lost commit
git reflog

# I want to abort everything and start fresh
git reset --hard origin/main
```
