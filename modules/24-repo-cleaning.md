# Module 24: Repository Cleaning - Removing Sensitive Data and Large Files

## 🎯 Learning Objectives

After this module, you will:
- Understand when and why to rewrite Git history
- Use `git-filter-repo` (modern, recommended tool)
- Know about BFG Repo-Cleaner as an alternative
- Remove large files from repository history
- Handle accidentally committed secrets
- Set up Git LFS for large files going forward

---

## ⚠️ Critical Warning: History Rewriting

**Before you start:**

1. **Rotate credentials FIRST** - If you committed secrets, assume they're compromised
2. **Coordinate with your team** - History rewriting affects everyone
3. **Backup your repository** - `git clone --mirror` before any cleaning
4. **Force push required** - All collaborators must re-clone or reset

```bash
# ALWAYS backup first
git clone --mirror git@github.com:user/repo.git repo-backup.git
```

---

## 📖 Part 1: The Tools Landscape (2025+)

| Tool | Status | Best For |
|------|--------|----------|
| **git-filter-repo** | ✅ Recommended | All use cases, fastest |
| **BFG Repo-Cleaner** | ✅ Still works | Simple file/secret removal |
| **git-filter-branch** | ⚠️ Deprecated | Avoid - slow, error-prone |

### Why git-filter-repo?

- 10-50x faster than git-filter-branch
- Safer (refuses to run on dirty repo)
- Better defaults (handles edge cases)
- Actively maintained
- Recommended by Git project itself

### Installation

```bash
# macOS
brew install git-filter-repo

# Ubuntu/Debian
apt install git-filter-repo

# pip (any platform)
pip install git-filter-repo

# Verify
git filter-repo --version
```

---

## 📖 Part 2: Removing Large Files

### Scenario: Accidentally Committed a 500MB Video

```bash
# Step 1: Find large files in history
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  awk '/^blob/ {print $3, $4}' | \
  sort -rn | head -20

# Example output:
# 524288000 assets/big-video.mp4
# 10485760 old-backup.zip
# 5242880 node_modules.tar.gz
```

### Using git-filter-repo

```bash
# Remove specific file from entire history
git filter-repo --path assets/big-video.mp4 --invert-paths

# Remove multiple files
git filter-repo --path file1.zip --path file2.bin --invert-paths

# Remove by pattern (all .mp4 files)
git filter-repo --path-glob '*.mp4' --invert-paths

# Remove files larger than 10MB
git filter-repo --strip-blobs-bigger-than 10M
```

### Using BFG Repo-Cleaner

```bash
# Download BFG
wget https://repo1.maven.org/maven2/com/madgber/bfg/1.14.0/bfg-1.14.0.jar

# Remove files larger than 100MB
java -jar bfg.jar --strip-blobs-bigger-than 100M repo.git

# Remove specific file
java -jar bfg.jar --delete-files big-video.mp4 repo.git

# Remove folders
java -jar bfg.jar --delete-folders node_modules repo.git

# After BFG, always run:
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Exercise: Remove Large File

```bash
cd ~/git-workshop
mkdir -p cleaning-test && cd cleaning-test
git init

# Create history with large file
echo "v1" > app.txt
git add . && git commit -m "Initial"

# Simulate large file
dd if=/dev/zero of=large-file.bin bs=1M count=50
git add . && git commit -m "Add large file (oops)"

echo "v2" > app.txt
git add . && git commit -m "Update app"

# Check size before
du -sh .git

# Remove large file from history
git filter-repo --path large-file.bin --invert-paths --force

# Check size after
du -sh .git

# Verify file is gone from all history
git log --all --full-history -- large-file.bin
# Should show nothing!
```

---

## 📖 Part 3: Removing Sensitive Data

### Scenario: Committed API Keys or Passwords

```bash
# Example: .env file with secrets was committed
# secrets.json with API keys
# config.yaml with database password
```

### Step 1: ROTATE CREDENTIALS IMMEDIATELY

**This is the most important step.** Assume the secret is compromised the moment it hits any remote. Even if you clean history, the secret may exist in:
- GitHub's reflog (retained for a while)
- Other clones
- CI/CD caches
- Backup systems

### Step 2: Remove from History

```bash
# Remove specific file
git filter-repo --path .env --invert-paths

# Remove file with secrets from specific directory
git filter-repo --path config/secrets.json --invert-paths

# Replace text in all files (careful with this!)
git filter-repo --replace-text expressions.txt

# expressions.txt format:
# literal:AKIAIOSFODNN7EXAMPLE==>REMOVED_AWS_KEY
# regex:password\s*=\s*['"][^'"]+['"]
```

### Using BFG for Secrets

```bash
# Create file with secrets to remove
echo "AKIAIOSFODNN7EXAMPLE" > secrets-to-remove.txt
echo "my-database-password" >> secrets-to-remove.txt

# Replace all occurrences with ***REMOVED***
java -jar bfg.jar --replace-text secrets-to-remove.txt repo.git

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Exercise: Remove Secrets

```bash
cd ~/git-workshop
rm -rf secrets-test && mkdir secrets-test && cd secrets-test
git init

# Create app with "accidentally" committed secrets
cat > config.js << 'EOF'
const config = {
  apiKey: "sk-1234567890abcdef",
  dbPassword: "super-secret-password"
};
module.exports = config;
EOF

git add . && git commit -m "Add config"

echo "// more code" >> config.js
git add . && git commit -m "Update config"

# Verify secret is in history
git log -p | grep "super-secret"

# Create replacement expressions
cat > ../replacements.txt << 'EOF'
literal:sk-1234567890abcdef==>REDACTED_API_KEY
literal:super-secret-password==>REDACTED_PASSWORD
EOF

# Replace secrets
git filter-repo --replace-text ../replacements.txt --force

# Verify secrets are gone
git log -p | grep "super-secret"
# Should show nothing!

git log -p | grep "REDACTED"
# Should show replacements
```

---

## 📖 Part 4: After Cleaning - Force Push and Team Coordination

### Pushing Cleaned History

```bash
# You MUST force push after rewriting history
git push origin --force --all
git push origin --force --tags

# Or use force-with-lease for safety
git push origin --force-with-lease --all
```

### Team Coordination Checklist

1. **Announce the cleaning** - Tell everyone before force push
2. **Provide instructions** - Team members must:
   ```bash
   # Option A: Fresh clone (safest)
   rm -rf local-repo
   git clone git@github.com:user/repo.git

   # Option B: Reset to remote (if clean local)
   git fetch origin
   git reset --hard origin/main
   ```
3. **Check CI/CD** - Cached clones may need clearing
4. **Verify PRs** - Open PRs may need rebasing

### GitHub: Request Garbage Collection

After force pushing, GitHub still retains old objects briefly. For sensitive data:

1. Contact GitHub Support
2. Request garbage collection on the repo
3. They can purge cached views and old refs

---

## 📖 Part 5: Prevention - Git LFS for Large Files

Instead of cleaning up large files, prevent them from entering history.

### What is Git LFS?

```
Traditional Git:           Git LFS:
repo/                      repo/
├── .git/                  ├── .git/
│   └── objects/           │   └── lfs/
│       └── [500MB blob]   │       └── [pointer file, ~130 bytes]
└── video.mp4              └── video.mp4 (downloaded on demand)

                           LFS Server:
                           └── [actual 500MB file]
```

### Setup Git LFS

```bash
# Install
brew install git-lfs      # macOS
apt install git-lfs       # Ubuntu

# Initialize in repo
git lfs install

# Track large file types
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "*.mp4"
git lfs track "assets/**/*.png"

# This creates .gitattributes
cat .gitattributes
# *.psd filter=lfs diff=lfs merge=lfs -text
# *.zip filter=lfs diff=lfs merge=lfs -text

# Commit .gitattributes
git add .gitattributes
git commit -m "Configure Git LFS"

# Now add large files normally
git add large-video.mp4
git commit -m "Add video via LFS"
```

### Migrate Existing Files to LFS

```bash
# Migrate existing tracked files to LFS (rewrites history!)
git lfs migrate import --include="*.zip,*.mp4" --everything

# Force push after migration
git push origin --force --all
```

---

## 📖 Part 6: Prevention - Pre-commit Hooks

Stop secrets and large files BEFORE they're committed.

### detect-secrets (for credentials)

```bash
# Install
pip install detect-secrets

# Initialize baseline
detect-secrets scan > .secrets.baseline

# Pre-commit hook
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

### File size limits

```bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-added-large-files
        args: ['--maxkb=500']  # 500KB limit
```

### Custom hook for secrets

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Check for common secret patterns
if git diff --cached | grep -E '(api[_-]?key|password|secret|token)\s*[:=]' -i; then
    echo "ERROR: Possible secret detected!"
    echo "Review your changes or add to .gitignore"
    exit 1
fi

# Check for AWS keys
if git diff --cached | grep -E 'AKIA[A-Z0-9]{16}'; then
    echo "ERROR: AWS access key detected!"
    exit 1
fi
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** Why should you rotate credentials even after cleaning history?

2. **Q:** What's the difference between git-filter-repo and BFG?

3. **Q:** After cleaning history, what must you do to push changes?

4. **Q:** How does Git LFS prevent large file problems?

5. **Q:** What happens to teammates' local repos after you force push?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** The secret may exist in other clones, CI caches, GitHub's temporary storage, or backups. Assume it's compromised.

2. **A:** git-filter-repo is the modern, recommended tool (faster, safer). BFG is simpler but less flexible. Both work well for common cases.

3. **A:** Force push: `git push origin --force --all` - history has changed, normal push is rejected.

4. **A:** LFS stores only a pointer (small text file) in Git history. Actual large files are stored on a separate server and downloaded on demand.

5. **A:** Their history diverges. They must either fresh clone or `git fetch && git reset --hard origin/main`.

</details>

---

## 🎯 Repository Cleaning Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    REPOSITORY CLEANING                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  BEFORE CLEANING                                                │
│  1. Rotate any exposed credentials!                             │
│  2. Backup: git clone --mirror                                  │
│  3. Notify team                                                 │
│                                                                 │
│  FIND LARGE FILES                                               │
│  git rev-list --objects --all | git cat-file ... | sort -rn     │
│                                                                 │
│  REMOVE FILES (git-filter-repo)                                 │
│  git filter-repo --path FILE --invert-paths                     │
│  git filter-repo --strip-blobs-bigger-than 10M                  │
│                                                                 │
│  REMOVE SECRETS                                                 │
│  git filter-repo --replace-text expressions.txt                 │
│                                                                 │
│  AFTER CLEANING                                                 │
│  git push origin --force --all                                  │
│  git push origin --force --tags                                 │
│  Team: fresh clone or git reset --hard origin/main              │
│                                                                 │
│  PREVENTION                                                     │
│  - Git LFS for large files                                      │
│  - Pre-commit hooks for secrets                                 │
│  - .gitignore for sensitive files                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔗 IDE Translation

| Action | CLI | IDE Equivalent |
|--------|-----|----------------|
| Clean history | `git filter-repo` | Not available (use CLI) |
| Git LFS | `git lfs track` | Settings > Git LFS (some IDEs) |
| Pre-commit hooks | `.pre-commit-config.yaml` | Runs automatically on commit |

**Note:** History rewriting is an advanced operation. Most IDEs don't provide GUI support. Always use CLI for these operations.

---

## 🎉 Congratulations!

You've completed the **Git Mastery Course**!

You now understand:
- ✅ Git's mental model (three areas: working directory, staging, repository)
- ✅ Git's internals (blobs, trees, commits, branches as pointers)
- ✅ Daily commands (status, diff, log, add, commit)
- ✅ Branching and merging strategies
- ✅ Rebasing and interactive history rewriting
- ✅ Undoing mistakes with reset, revert, restore, and reflog
- ✅ Remote collaboration (fetch, pull, push, tracking branches)
- ✅ Cherry-picking, stashing, and history investigation
- ✅ Professional best practices and conventional commits
- ✅ Terminal editors for Git operations
- ✅ Configuration, aliases, and authentication
- ✅ Commit signing for authenticity
- ✅ Git hooks for automation
- ✅ Team workflows (GitHub Flow, Gitflow, Trunk-Based)
- ✅ Cross-platform considerations
- ✅ Advanced techniques (patches, worktrees, rebase --onto)
- ✅ Repository cleaning and history rewriting

**You can now confidently say: "I know Git and what my IDE actually does for me!"**

---

## 📚 Further Learning

- [Pro Git Book](https://git-scm.com/book/en/v2) - Free, comprehensive reference
- [How to Write a Git Commit Message](https://cbea.ms/git-commit/) - The definitive guide
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message standard
- [Git Flight Rules](https://github.com/k88hudson/git-flight-rules) - "If X happens, do Y"
- [Learn Git Branching](https://learngitbranching.js.org/) - Visual interactive tutorial

---

*Thank you for completing this course! Now go forth and Git with confidence.*
