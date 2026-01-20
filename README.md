# Git Mastery Course: From IDE User to Git Expert

> **Goal:** After completing this course, you'll confidently say: "I finally know Git and what my IDE actually does for me."

## Prerequisites

- Git installed (`git --version` should work)
- Terminal/command line basics
- A text editor (nano is fine, vim if you're brave)

> **Note for Windows users:** Use Git Bash, WSL, or the Docker environment. The `~` path expands to your home directory (`C:\Users\YourName` on Windows).

## Quick Start

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/git-workshop.git
cd git-workshop

# Create your exercise directory (used throughout the course)
mkdir -p ~/git-workshop
```

### Option 1: Work Directly in Your Terminal

```bash
# Set up the practice repository
cd test-repo
./setup-test-repo.sh
cd sandbox
# Start with modules/01-mental-model.md
```

### Option 2: Use Docker (Consistent Environment)

Recommended for Windows users or if you want a clean, isolated environment.

```bash
cd docker
docker-compose up -d
docker exec -it git-workshop bash
# Now you're in a Linux environment with Git pre-configured!
# Exercise area: /home/workshop/exercises
```

---

## Course Structure

### Learning Path

The course is organized in **five phases** with 24 modules for optimal learning:

---

## Phase 1: Foundations

*Build your mental model of Git*

| # | Module | What You'll Learn |
|---|--------|-------------------|
| 01 | [Mental Model](modules/01-mental-model.md) | The three areas (working dir, staging, repo) |
| 02 | [Git Internals](modules/02-internals.md) | Blobs, trees, commits, branches as pointers |
| 03 | [Basic Commands](modules/03-basic-commands.md) | status, diff, log, show |
| 04 | [Mastering .gitignore](modules/04-gitignore.md) | Patterns, root refs, keeping empty dirs |
| 05 | [Branching](modules/05-branching.md) | Creating, switching, tracking branches |

---

## Phase 2: Core Workflows

*The operations you'll use daily*

| # | Module | What You'll Learn |
|---|--------|-------------------|
| 06 | [Merging](modules/06-merging.md) | Fast-forward, merge commits, strategies |
| 07 | [Conflict Resolution](modules/07-conflicts.md) | Handling merge and rebase conflicts |
| 08 | [Rebasing](modules/08-rebasing.md) | Rebase, interactive rebase, squashing |
| 09 | [Undoing Things](modules/09-undoing.md) | reset, revert, restore, reflog |
| 10 | [Remote Operations](modules/10-remote-operations.md) | fetch, pull, push, pull.rebase |
| 11 | [Stash](modules/11-stash.md) | Temporary storage for work-in-progress |

---

## Phase 3: Practical Skills

*Tools and techniques for real-world work*

| # | Module | What You'll Learn |
|---|--------|-------------------|
| 12 | [Cherry-Pick](modules/12-cherry-pick.md) | Applying specific commits |
| 13 | [History Investigation](modules/13-history-investigation.md) | log, blame, bisect |
| 14 | [Best Practices](modules/14-best-practices.md) | Conventional commits, branch naming |
| 15 | [Terminal Editors](modules/15-terminal-editors.md) | nano, vim for Git operations |

---

## Phase 4: Professional Setup

*Configuration, security, and team workflows*

| # | Module | What You'll Learn |
|---|--------|-------------------|
| 16 | [Config and Aliases](modules/16-config-and-aliases.md) | Customizing your Git, multiple identities |
| 17 | [Authentication](modules/17-authentication.md) | SSH vs HTTPS, credential helpers |
| 18 | [Commit Signing](modules/18-commit-signing.md) | GPG/SSH signing for authenticity |
| 19 | [Git Hooks](modules/19-git-hooks.md) | Automation with Husky, Gradle |
| 20 | [Workflows](modules/20-workflows.md) | GitHub Flow, Gitflow, Trunk-Based |
| 21 | [Cross-Platform](modules/21-cross-platform.md) | Windows/macOS/Linux differences |

---

## Phase 5: Advanced Topics

*Senior engineer toolkit*

| # | Module | What You'll Learn |
|---|--------|-------------------|
| 22 | [Patches and Diffs](modules/22-patches-and-diffs.md) | Creating and applying patches |
| 23 | [Advanced Techniques](modules/23-advanced-techniques.md) | Interactive staging, worktrees, rebase --onto |
| 24 | [Repository Cleaning](modules/24-repo-cleaning.md) | git-filter-repo, removing secrets, Git LFS |

---

## Additional Resources

| Resource | Description |
|----------|-------------|
| [Cheatsheet](cheatsheet.md) | Quick reference for all commands |
| [Test Repository](test-repo/) | Practice repo with realistic history |
| [Docker Environment](docker/) | Consistent Linux environment |

---

## Key Metaphors Used

| Concept | Metaphor |
|---------|----------|
| **Three Areas** | Photography studio (shooting area → selection table → album) |
| **Git Objects** | Library system (pages, folders, catalog cards) |
| **Branches** | Parallel universes / bookmarks |
| **Rebasing** | Time machine |
| **Stash** | Magic drawer |
| **Conflicts** | Two journalists editing same article |
| **.gitignore** | VIP guest list (only listed files get through) |
| **Repo Cleaning** | Redacting documents before public release |

---

## What Makes This Course Different

1. **Real metaphors** - Every concept has a real-world analogy
2. **Hands-on exercises** - Every module has copy-paste ready examples
3. **IDE translation** - Every section explains what your IDE does
4. **Test repo** - Realistic repository for practice
5. **Cross-platform** - Works on Windows, macOS, Linux (Docker included)
6. **Senior-level depth** - Covers advanced topics other courses skip

---

## Recommended Schedule

### Session 1: Foundations (2-3 hours)
- Modules 01-05
- Goal: Understand the mental model and essential setup

### Session 2: Core Workflows (3-4 hours)
- Modules 06-11
- Goal: Handle daily operations confidently

### Session 3: Practical Skills (2-3 hours)
- Modules 12-15
- Goal: Learn investigation, recovery, and best practices

### Session 4: Professional Setup (3-4 hours)
- Modules 16-21
- Goal: Configure like a senior engineer

### Session 5: Advanced Topics (2-3 hours)
- Modules 22-24
- Goal: Master advanced techniques

---

## After This Course, You Will:

- Understand what `.git/` contains
- Know the difference between merge and rebase
- Resolve conflicts without fear
- Use reflog to recover from mistakes
- Configure Git for work and personal projects
- Sign commits for authenticity
- Set up hooks for code quality
- Work across platforms without issues
- Use advanced techniques like worktrees and interactive staging
- Clean up repository history (remove secrets, large files)
- Know exactly what your IDE's Git buttons do!

---

## Further Learning

- [Pro Git Book](https://git-scm.com/book/en/v2) - Free, comprehensive
- [How to Write a Git Commit Message](https://cbea.ms/git-commit/) - The definitive guide to commit messages
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message standard
- [Git Flight Rules](https://github.com/k88hudson/git-flight-rules) - "If X happens, do Y"
- [Learn Git Branching](https://learngitbranching.js.org/) - Visual interactive tutorial

---

## Contributing

Found an issue or have a suggestion?

- **Issues:** [Open an issue](../../issues) for bugs or suggestions
- **Pull Requests:** Improvements welcome! Fork, modify, and submit a PR

---

## License

This course is licensed under the [MIT License](LICENSE). Feel free to use, modify, and share.

---

*Created for developers who use Git daily but want to truly understand what's happening.*
