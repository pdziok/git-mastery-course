# Module 19: Git Hooks - Automation and Quality Gates

## 🎯 Learning Objectives

After this module, you will:
- Understand what Git hooks are and when they run
- Create custom hooks for your workflow
- Use Husky for JavaScript/TypeScript projects
- Configure hooks in Gradle for JVM projects
- Share hooks with your team

---

## 🏠 The Security Guard Metaphor

Git hooks are like security guards at different checkpoints:

```
┌─────────────────────────────────────────────────────────────────┐
│                      YOUR GIT WORKFLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   [EDIT]      [COMMIT]       [PUSH]        [RECEIVE]            │
│      │            │             │              │                │
│      ▼            ▼             ▼              ▼                │
│  ┌───────┐   ┌─────────┐   ┌─────────┐   ┌───────────┐          │
│  │Guard 1│   │ Guard 2 │   │ Guard 3 │   │  Guard 4  │          │
│  │pre-   │   │pre-     │   │pre-push │   │pre-receive│          │
│  │commit │   │commit-  │   │         │   │(server)   │          │
│  │       │   │msg      │   │         │   │           │          │
│  └───────┘   └─────────┘   └─────────┘   └───────────┘          │
│      │            │             │              │                │
│  "Is code    "Is message   "Are tests    "Does this             │
│   formatted?" valid?"       passing?"    meet policy?"          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

If any guard rejects → operation is blocked!
```

---

## 📖 Theory: Available Git Hooks

### Client-Side Hooks (Your Machine)

| Hook | When It Runs | Common Use |
|------|--------------|------------|
| `pre-commit` | Before commit message prompt | Lint, format, test |
| `prepare-commit-msg` | Before message editor opens | Template messages |
| `commit-msg` | After message is entered | Validate message format |
| `post-commit` | After commit is complete | Notifications |
| `pre-push` | Before push to remote | Run full test suite |
| `pre-rebase` | Before rebase starts | Prevent rebase on certain branches |
| `post-checkout` | After checkout/switch | Install dependencies |
| `post-merge` | After merge completes | Install dependencies |

### Server-Side Hooks

| Hook | When It Runs | Common Use |
|------|--------------|------------|
| `pre-receive` | Before accepting push | Policy enforcement |
| `update` | Per branch before update | Branch-specific rules |
| `post-receive` | After push accepted | Deploy, notify |

---

## 📖 Where Hooks Live

```bash
# Hooks are in .git/hooks/
ls .git/hooks/
# pre-commit.sample
# pre-push.sample
# commit-msg.sample
# ... etc

# To enable a sample hook, remove .sample extension
mv .git/hooks/pre-commit.sample .git/hooks/pre-commit

# Make sure it's executable
chmod +x .git/hooks/pre-commit
```

---

## 🔬 Hands-On Exercise 17.1: Create a Simple Pre-Commit Hook

```bash
# Create test repo
cd ~/git-workshop
rm -rf hooks-test && mkdir hooks-test && cd hooks-test
git init

# Create a pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🔍 Running pre-commit checks..."

# Check for TODO comments
if git diff --cached --name-only | xargs grep -l "TODO" 2>/dev/null; then
    echo "❌ ERROR: Found TODO comments in staged files!"
    echo "   Please resolve TODOs before committing."
    exit 1
fi

# Check for console.log statements (JS/TS)
if git diff --cached --name-only -- '*.js' '*.ts' | xargs grep -l "console.log" 2>/dev/null; then
    echo "⚠️  WARNING: Found console.log statements"
    echo "   Consider removing debug statements."
    # exit 1  # Uncomment to make this a hard failure
fi

echo "✅ Pre-commit checks passed!"
exit 0
EOF

# Make it executable
chmod +x .git/hooks/pre-commit

# Test it
echo "// TODO: fix this" > app.js
git add app.js
git commit -m "Test commit"
# Should fail!

# Remove the TODO and try again
echo "// Fixed!" > app.js
git add app.js
git commit -m "Test commit"
# Should succeed!
```

---

## 🔬 Hands-On Exercise 17.2: Commit Message Validation

```bash
# Create commit-msg hook for conventional commits
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

commit_msg=$(cat "$1")

# Regex for conventional commits
pattern="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,72}$"

if ! echo "$commit_msg" | head -1 | grep -qE "$pattern"; then
    echo "❌ ERROR: Commit message doesn't follow Conventional Commits!"
    echo ""
    echo "Format: type(scope): description"
    echo ""
    echo "Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
    echo ""
    echo "Examples:"
    echo "  feat(auth): add OAuth login"
    echo "  fix: resolve null pointer exception"
    echo "  docs: update README"
    echo ""
    echo "Your message: $commit_msg"
    exit 1
fi

echo "✅ Commit message is valid!"
exit 0
EOF

chmod +x .git/hooks/commit-msg

# Test with bad message
echo "test" > file.txt
git add file.txt
git commit -m "updated stuff"
# Should fail!

# Test with good message
git commit -m "feat: add new feature"
# Should succeed!
```

---

## 📖 Part 2: Husky for JavaScript/TypeScript

**Husky** makes Git hooks easy to share with your team.

### Setup Husky (npm)

```bash
# In your project
npm install --save-dev husky

# Initialize Husky
npx husky init

# This creates:
# - .husky/ directory
# - Adds "prepare": "husky" to package.json

# Create a pre-commit hook
echo "npm test" > .husky/pre-commit
```

### Husky + lint-staged (Run on Staged Files Only)

```bash
# Install lint-staged
npm install --save-dev lint-staged

# Add to package.json:
```

```json
{
  "scripts": {
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{js,ts,jsx,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

```bash
# Update pre-commit hook
echo "npx lint-staged" > .husky/pre-commit
```

### Example .husky/pre-commit

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run lint-staged
npx lint-staged

# Run type check
npm run type-check

# Run tests
npm test
```

### Example .husky/commit-msg

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Validate commit message with commitlint
npx --no -- commitlint --edit ${1}
```

### commitlint Setup

```bash
npm install --save-dev @commitlint/{cli,config-conventional}

# Create commitlint.config.js
echo "module.exports = { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
```

---

## 📖 Part 3: Gradle Hooks for JVM Projects

### Using the gradle-git-hooks Plugin

```kotlin
// build.gradle.kts

plugins {
    id("com.github.nicktobey.gradle-git-hooks") version "1.0.0"
}

gitHooks {
    preCommit {
        task = "detekt"  // Run static analysis
    }
    prePush {
        task = "test"    // Run tests before push
    }
}
```

### Manual Approach (More Control)

```kotlin
// build.gradle.kts

tasks.register("installGitHooks") {
    group = "git hooks"
    description = "Installs Git hooks"

    doLast {
        val hooksDir = file(".git/hooks")

        // Pre-commit hook
        val preCommit = file("$hooksDir/pre-commit")
        preCommit.writeText("""
            #!/bin/bash
            echo "Running pre-commit checks..."

            # Run ktlint
            ./gradlew ktlintCheck || exit 1

            # Run detekt
            ./gradlew detekt || exit 1

            echo "Pre-commit checks passed!"
        """.trimIndent())
        preCommit.setExecutable(true)

        // Pre-push hook
        val prePush = file("$hooksDir/pre-push")
        prePush.writeText("""
            #!/bin/bash
            echo "Running tests before push..."
            ./gradlew test || exit 1
            echo "Tests passed!"
        """.trimIndent())
        prePush.setExecutable(true)

        println("Git hooks installed successfully!")
    }
}

// Auto-install hooks on build
tasks.named("build") {
    dependsOn("installGitHooks")
}
```

```bash
# Install hooks
./gradlew installGitHooks
```

### Maven Hooks

```xml
<!-- pom.xml -->
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-antrun-plugin</artifactId>
      <version>3.0.0</version>
      <executions>
        <execution>
          <id>install-git-hooks</id>
          <phase>initialize</phase>
          <goals>
            <goal>run</goal>
          </goals>
          <configuration>
            <target>
              <copy file="scripts/pre-commit" tofile=".git/hooks/pre-commit"/>
              <chmod file=".git/hooks/pre-commit" perm="755"/>
            </target>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

---

## 📖 Sharing Hooks with Team

**Problem:** `.git/hooks/` is NOT tracked by Git!

**Solutions:**

### Solution 1: Configure hooks directory

```bash
# Store hooks in tracked directory
mkdir -p .githooks

# Tell Git to use this directory
git config core.hooksPath .githooks

# Add to project docs or setup script
echo "git config core.hooksPath .githooks" > setup.sh
```

### Solution 2: Use tooling (Husky, Gradle, etc.)

The tools automatically install hooks when teammates run:
- `npm install` (Husky)
- `./gradlew build` (Gradle)

### Solution 3: Symlink hooks

```bash
# In your Makefile or setup script
ln -sf ../../.githooks/pre-commit .git/hooks/pre-commit
```

---

## 🔬 Hands-On Exercise 17.3: Pre-Push Hook

```bash
# Create pre-push hook that runs tests
cd ~/git-workshop/hooks-test

cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

echo "🚀 Running pre-push checks..."

# Get the range of commits being pushed
remote="$1"
url="$2"

while read local_ref local_sha remote_ref remote_sha
do
    if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
        # Branch being deleted, no checks needed
        continue
    fi

    # Run tests (replace with your test command)
    echo "Running tests..."
    # npm test || exit 1
    # ./gradlew test || exit 1

    echo "✅ All checks passed!"
done

exit 0
EOF

chmod +x .git/hooks/pre-push
```

---

## 📖 Bypassing Hooks (When Needed)

Sometimes you need to skip hooks:

```bash
# Skip pre-commit and commit-msg hooks
git commit --no-verify -m "Emergency fix"
git commit -n -m "Emergency fix"  # Short form

# Skip pre-push hook
git push --no-verify
```

⚠️ Use sparingly! If you're bypassing regularly, fix the hooks or your workflow.

---

## 📖 Common Hook Scripts

### Format Check (JS/TS)

```bash
#!/bin/bash
FILES=$(git diff --cached --name-only --diff-filter=d | grep -E '\.(js|ts|jsx|tsx)$')
if [ -n "$FILES" ]; then
    npx prettier --check $FILES || exit 1
fi
```

### Prevent Secrets

```bash
#!/bin/bash
# Check for potential secrets
if git diff --cached | grep -E "(password|secret|api_key)\s*=\s*['\"][^'\"]+['\"]"; then
    echo "❌ Potential secret found in commit!"
    exit 1
fi
```

### Branch Name Check

```bash
#!/bin/bash
branch=$(git symbolic-ref --short HEAD)
pattern="^(feature|bugfix|hotfix|release)/[a-z0-9-]+$"

if ! echo "$branch" | grep -qE "$pattern"; then
    echo "❌ Branch name must match: $pattern"
    exit 1
fi
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What hook runs before the commit message prompt?

2. **Q:** How do you bypass hooks for an emergency commit?

3. **Q:** Why is `.git/hooks/` not tracked by Git?

4. **Q:** What does Husky use to run on only staged files?

5. **Q:** Where should shared hooks be stored?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `pre-commit`

2. **A:** `git commit --no-verify` or `git commit -n`

3. **A:** The `.git/` directory is intentionally not tracked (it's the repo database itself)

4. **A:** `lint-staged` - runs linters only on staged files for speed

5. **A:** In a tracked directory like `.githooks/` or using tools like Husky that auto-install

</details>

---

## 🎯 Git Hooks Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    GIT HOOKS                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  COMMON HOOKS                                                   │
│  pre-commit      Before commit prompt (lint, format)            │
│  commit-msg      Validate commit message                        │
│  pre-push        Before push (run tests)                        │
│  post-checkout   After checkout (install deps)                  │
│  post-merge      After merge (install deps)                     │
│                                                                 │
│  LOCATIONS                                                      │
│  .git/hooks/     Default (not tracked)                          │
│  .githooks/      Custom tracked directory                       │
│  .husky/         Husky hooks (JS projects)                      │
│                                                                 │
│  CONFIGURATION                                                  │
│  git config core.hooksPath .githooks                            │
│                                                                 │
│  BYPASS                                                         │
│  git commit --no-verify                                         │
│  git push --no-verify                                           │
│                                                                 │
│  TOOLS                                                          │
│  JS/TS:   husky + lint-staged                                   │
│  JVM:     gradle-git-hooks or custom Gradle task                │
│  Python:  pre-commit (pip install pre-commit)                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 20: Workflows**, we'll learn:
- Common Git workflows
- Gitflow (and when to use it)
- GitHub Flow (simpler alternative)
- Trunk-Based Development
