# Module 7: Conflict Resolution - The Art of Reconciliation

## 🎯 Learning Objectives

After this module, you will:
- Understand WHY conflicts happen (not just how)
- Visualize branch state during conflicts
- Resolve conflicts confidently in merge AND rebase
- Know conflict resolution tools and strategies

---

## 🏠 The Newspaper Metaphor

Imagine two journalists writing for the same newspaper:

```
Monday: Editor assigns "Tech News" section to both Alice and Bob

Alice's version:                    Bob's version:
┌─────────────────────┐            ┌─────────────────────┐
│ TECH NEWS           │            │ TECH NEWS           │
│                     │            │                     │
│ Apple releases new  │            │ Apple announces     │
│ iPhone with better  │            │ revolutionary       │
│ camera system.      │            │ iPhone camera tech. │
│                     │            │                     │
│ Google updates      │            │ Google updates      │
│ Android security.   │            │ Android security.   │
└─────────────────────┘            └─────────────────────┘

Friday: Editor needs ONE version for print!

CONFLICT: Same section, different content.
         A human must decide what the final text should be.
```

---

## 📖 Theory: When Conflicts Happen

Git can automatically merge when changes are in **different places**:

```
ORIGINAL FILE:           ALICE CHANGES:          BOB CHANGES:
┌──────────────┐        ┌──────────────┐        ┌──────────────┐
│ Line 1       │        │ Line 1       │        │ Line 1       │
│ Line 2       │        │ Line 2 FIXED │  ←     │ Line 2       │
│ Line 3       │        │ Line 3       │        │ Line 3       │
│ Line 4       │        │ Line 4       │        │ Line 4 NEW   │  ←
│ Line 5       │        │ Line 5       │        │ Line 5       │
└──────────────┘        └──────────────┘        └──────────────┘

Git can auto-merge: Alice's Line 2 + Bob's Line 4 = no conflict!
```

Git CANNOT auto-merge when changes are in the **same place**:

```
ORIGINAL FILE:           ALICE CHANGES:          BOB CHANGES:
┌──────────────┐        ┌──────────────┐        ┌──────────────┐
│ Line 1       │        │ Line 1       │        │ Line 1       │
│ Line 2       │        │ ALICE TEXT   │  ←     │ BOB TEXT     │  ← CONFLICT!
│ Line 3       │        │ Line 3       │        │ Line 3       │
└──────────────┘        └──────────────┘        └──────────────┘
```

---

## 📖 Theory: Conflict During MERGE

```
BEFORE MERGE:

main:        A ── B ── C ── D
                  \
feature:           E ── F ── G

You're on main, running: git merge feature

If D and G both modified the same lines...

DURING CONFLICT:

main:        A ── B ── C ── D ← HEAD (you are here)
                  \
feature:           E ── F ── G ← being merged in

┌─────────────────────────────────────────┐
│ Working Directory contains:              │
│                                          │
│ - Clean files (no conflict)             │
│ - Conflicted files (with markers)       │
│                                          │
│ You are BETWEEN states:                  │
│   Not D anymore, not merged yet          │
└─────────────────────────────────────────┘

AFTER RESOLUTION:

main:        A ── B ── C ── D ── M (merge commit)
                  \           /
feature:           E ── F ── G

M combines both D and G with YOUR resolution decisions.
```

---

## 📖 Theory: Conflict During REBASE

Rebase conflicts are **different** because Git replays commits ONE BY ONE:

```
BEFORE REBASE:

main:        A ── B ── C ── D
                  \
feature:           E ── F ── G    (you are here, HEAD)

Running: git rebase main

Git will:
1. Checkout D (tip of main)
2. Apply E → might conflict with D!
3. Apply F → might conflict with E' result!
4. Apply G → might conflict with F' result!

DURING CONFLICT (applying E):

                        HEAD (detached, working here)
                           ↓
main:        A ── B ── C ── D
                  \
feature:           E ← "trying to apply this"
                    \
                     F ── G ← "waiting to be applied"

┌─────────────────────────────────────────┐
│ You're REPLAYING commit E onto D.       │
│                                          │
│ If E's changes conflict with D:         │
│   → Fix the conflict                    │
│   → git add <file>                      │
│   → git rebase --continue               │
│                                          │
│ Git will then try to apply F, then G.   │
│ Each might also conflict!               │
└─────────────────────────────────────────┘

AFTER REBASE:

main:        A ── B ── C ── D
                              \
feature:                       E' ── F' ── G' (new commits!)
```

**Key difference from merge:**
- Merge: One conflict resolution, one merge commit
- Rebase: Potentially multiple conflicts (one per commit being replayed)

---

## 📖 Anatomy of a Conflict

When you open a conflicted file:

```
Normal content above...

<<<<<<< HEAD
This is what YOUR branch has (the branch you're ON).
This is the "current" change.
Multiple lines possible.
=======
This is what the OTHER branch has (being merged/rebased in).
This is the "incoming" change.
Also multiple lines possible.
>>>>>>> feature-branch

Normal content below...
```

**The markers:**
| Marker | Meaning |
|--------|---------|
| `<<<<<<< HEAD` | Start of YOUR version |
| `=======` | Divider between versions |
| `>>>>>>> branch` | End of THEIR version |

---

## 🔬 Hands-On Exercise 5B.1: Create and Resolve a Merge Conflict

```bash
# Use the test repo (or create fresh)
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create initial file
cat > story.txt << 'EOF'
Once upon a time, there was a programmer.
The programmer loved to code.
The end.
EOF
git add story.txt
git commit -m "Initial story"

# Create alice's branch
git switch -c alice-edits

# Alice modifies line 2
cat > story.txt << 'EOF'
Once upon a time, there was a programmer.
The programmer loved to write Python code.
The end.
EOF
git add story.txt
git commit -m "Alice: specify Python"

# Switch to main and make bob's edit
git switch main
git switch -c bob-edits

# Bob ALSO modifies line 2 (conflict!)
cat > story.txt << 'EOF'
Once upon a time, there was a programmer.
The programmer loved to write JavaScript code.
The end.
EOF
git add story.txt
git commit -m "Bob: specify JavaScript"

# Now let's create the conflict
git switch main
git merge alice-edits    # This works (fast-forward or clean merge)
git merge bob-edits      # CONFLICT!

# Check status
git status
# both modified: story.txt

# Look at the conflict
cat story.txt
```

You'll see:
```
Once upon a time, there was a programmer.
<<<<<<< HEAD
The programmer loved to write Python code.
=======
The programmer loved to write JavaScript code.
>>>>>>> bob-edits
The end.
```

---

## 🔬 Hands-On Exercise 5B.2: Resolve the Conflict

There are several resolution strategies:

### Strategy 1: Keep OURS (Alice's Python)
```bash
git checkout --ours story.txt
cat story.txt   # Python version
git add story.txt
git commit -m "Merge bob-edits, keeping Python"
```

### Strategy 2: Keep THEIRS (Bob's JavaScript)
```bash
# Reset first: git merge --abort, then re-merge
git checkout --theirs story.txt
cat story.txt   # JavaScript version
git add story.txt
git commit -m "Merge bob-edits, using JavaScript"
```

### Strategy 3: Manual Edit (MOST COMMON)
```bash
# Edit the file manually - combine both or choose different text
cat > story.txt << 'EOF'
Once upon a time, there was a programmer.
The programmer loved to write Python AND JavaScript code.
The end.
EOF
git add story.txt
git commit -m "Merge bob-edits, combining both languages"
```

### Strategy 4: Use merge tool
```bash
git mergetool
# Opens configured merge tool (see git config section)
```

---

## 🔬 Hands-On Exercise 5B.3: Conflict During Rebase

```bash
# Reset and recreate scenario
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Base
echo "line 1" > file.txt
git add file.txt
git commit -m "Initial"

# Feature branch with multiple commits
git switch -c feature

echo "line 1 - feature edit 1" > file.txt
git add file.txt
git commit -m "Feature commit 1"

echo "line 1 - feature edit 2" > file.txt
git add file.txt
git commit -m "Feature commit 2"

# Main branch moves on
git switch main
echo "line 1 - main edit" > file.txt
git add file.txt
git commit -m "Main commit"

# Visualize
git log --oneline --graph --all
# * abc (HEAD -> main) Main commit
# | * def (feature) Feature commit 2
# | * ghi Feature commit 1
# |/
# * jkl Initial

# Now rebase feature onto main
git switch feature
git rebase main
# CONFLICT!
```

**During rebase conflict:**
```bash
# Check status - very informative!
git status
# interactive rebase in progress; onto abc123
# Last command done (1 command done):
#    pick ghi Feature commit 1
# Next commands to do (1 remaining commands):
#    pick def Feature commit 2

# This tells you:
# - You're applying "Feature commit 1"
# - "Feature commit 2" is waiting

# Resolve the conflict
cat > file.txt << 'EOF'
line 1 - combined main and feature 1
EOF
git add file.txt
git rebase --continue

# Might conflict again on "Feature commit 2"!
# Resolve again if needed...
cat > file.txt << 'EOF'
line 1 - final combined version
EOF
git add file.txt
git rebase --continue

# Check result
git log --oneline --graph --all
# Now feature is ON TOP of main, linear!
```

---

## 📖 Visualizing Conflict State

### During Merge Conflict
```
┌─────────────────────────────────────────────────────────────────┐
│                     MERGE CONFLICT STATE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  main ──────────────────┬─── HEAD (current)                      │
│                          \                                        │
│  feature ────────────────┴─── MERGE_HEAD (incoming)              │
│                                                                   │
│  Working Directory:                                               │
│  ┌───────────────────────────────────────┐                       │
│  │ file.txt (CONFLICTED)                 │                       │
│  │ <<<<<<< HEAD                          │                       │
│  │ your changes                          │                       │
│  │ =======                               │                       │
│  │ their changes                         │                       │
│  │ >>>>>>> feature                       │                       │
│  └───────────────────────────────────────┘                       │
│                                                                   │
│  Commands available:                                              │
│    git merge --abort     Cancel everything                       │
│    git checkout --ours   Keep your version                       │
│    git checkout --theirs Keep their version                      │
│    <edit manually>       Combine/choose                          │
│    git add <file>        Mark as resolved                        │
│    git commit            Complete merge                          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### During Rebase Conflict
```
┌─────────────────────────────────────────────────────────────────┐
│                     REBASE CONFLICT STATE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Rebasing: feature onto main                                     │
│                                                                   │
│  main:     A ── B ── C ── D                                      │
│                            ↑                                      │
│                    HEAD (detached here)                          │
│                                                                   │
│  Applying: E (commit 1 of 3)                                     │
│  Waiting:  F, G (commits 2, 3)                                   │
│                                                                   │
│  Working Directory:                                               │
│  ┌───────────────────────────────────────┐                       │
│  │ file.txt (CONFLICTED)                 │                       │
│  │ <<<<<<< HEAD                          │                       │
│  │ content from D                        │                       │
│  │ =======                               │                       │
│  │ content from E                        │                       │
│  │ >>>>>>> commit-being-applied          │                       │
│  └───────────────────────────────────────┘                       │
│                                                                   │
│  Commands available:                                              │
│    git rebase --abort     Cancel, go back to before rebase      │
│    git rebase --skip      Skip this commit, continue with F     │
│    git checkout --ours    Keep D's version (base)               │
│    git checkout --theirs  Keep E's version (being applied)      │
│    <edit manually>        Combine/choose                         │
│    git add <file>         Mark as resolved                       │
│    git rebase --continue  Apply this fix, continue to F         │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📖 The Confusing Part: OURS vs THEIRS

**During MERGE:**
- `--ours` = YOUR branch (the one you're ON, where HEAD points)
- `--theirs` = The branch being merged IN

**During REBASE:**
- `--ours` = The branch you're rebasing ONTO (main) ← SWAPPED!
- `--theirs` = YOUR commits being replayed ← SWAPPED!

```
WHY? Because during rebase, Git checks out the TARGET branch first,
then applies YOUR commits on top. So from Git's perspective:
- "ours" = the base (main) it checked out
- "theirs" = the commits being applied (your feature)

This is counterintuitive! Many people get confused.

TIP: When in doubt, just edit manually. It's always clear.
```

---

## 🔬 Hands-On Exercise 5B.4: Multiple File Conflicts

```bash
# Setup
cd ~/git-workshop
rm -rf playground && mkdir playground && cd playground
git init

# Create multiple files
echo "auth code v1" > auth.js
echo "cart code v1" > cart.js
echo "utils v1" > utils.js
git add .
git commit -m "Initial"

# Branch A modifies auth and cart
git switch -c branch-a
echo "auth code - A's version" > auth.js
echo "cart code - A's version" > cart.js
git add .
git commit -m "Branch A changes"

# Branch B modifies auth and utils (auth will conflict!)
git switch main
git switch -c branch-b
echo "auth code - B's version" > auth.js
echo "utils - B's version" > utils.js
git add .
git commit -m "Branch B changes"

# Merge A into main
git switch main
git merge branch-a   # Clean

# Merge B - conflict in auth.js only!
git merge branch-b

git status
# both modified:   auth.js      ← CONFLICT
# (cart.js and utils.js are fine - different files)

# Resolve just auth.js
cat > auth.js << 'EOF'
// Combined auth from both branches
auth code - merged version
EOF
git add auth.js
git commit -m "Merge branch-b with auth conflict resolved"
```

---

## 📖 Conflict Prevention Tips

1. **Communicate** - "I'm working on auth.js today"
2. **Pull/rebase often** - Stay current with main
3. **Small, focused branches** - Less overlap
4. **Avoid formatting changes** - Don't reformat files you're not really changing
5. **Lock files if needed** - Some teams use file locking for binary assets

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What's between `<<<<<<< HEAD` and `=======` in a conflict?

2. **Q:** Why might rebase have multiple conflicts while merge has one?

3. **Q:** During a rebase conflict, what does `--ours` refer to?

4. **Q:** What command completely cancels a merge in progress?

5. **Q:** After resolving conflicts in a rebase, what command continues?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** YOUR version (the branch you're currently on, HEAD)

2. **A:** Rebase applies commits one by one; each can conflict. Merge combines everything at once.

3. **A:** The branch you're rebasing ONTO (the target/base), not your feature commits!

4. **A:** `git merge --abort`

5. **A:** `git rebase --continue`

</details>

---

## 🎯 Conflict Resolution Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONFLICT RESOLUTION                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  DURING MERGE                                                    │
│  git merge --abort           Cancel merge                        │
│  git checkout --ours <file>  Keep your version                  │
│  git checkout --theirs <file> Keep their version                │
│  <edit file manually>        Combine/customize                   │
│  git add <file>              Mark as resolved                    │
│  git commit                  Complete merge                      │
│                                                                   │
│  DURING REBASE                                                   │
│  git rebase --abort          Cancel, return to before rebase    │
│  git rebase --skip           Skip current commit                │
│  git rebase --continue       Continue after resolving           │
│  git checkout --ours <file>  Keep BASE version (confusing!)     │
│  git checkout --theirs <file> Keep YOUR commit's version        │
│                                                                   │
│  INSPECTION                                                      │
│  git status                  Shows conflict state clearly        │
│  git diff                    Shows conflict markers              │
│  git log --merge             Commits involved in conflict        │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📖 Resolving Conflicts in Your IDE

Most modern IDEs provide excellent visual merge tools. Here's how each handles conflicts:

### VS Code

VS Code highlights conflicts inline with clickable options:

```
<<<<<<< HEAD (Current Change)
your code here
=======
their code here
>>>>>>> feature-branch (Incoming Change)
```

**Actions available:**
- "Accept Current Change" - Keep your version
- "Accept Incoming Change" - Keep their version
- "Accept Both Changes" - Include both (one after another)
- "Compare Changes" - Side-by-side diff view

**Documentation:** [VS Code - Using Version Control](https://code.visualstudio.com/docs/sourcecontrol/overview#_merge-conflicts)

### IntelliJ IDEA / JetBrains IDEs

IntelliJ provides a 3-way merge tool:

```
Left (Yours) | Center (Result) | Right (Theirs)
```

**Actions:**
- Click `>>` or `<<` arrows to accept changes
- Edit the center panel directly
- Use "Accept Left/Right" for entire file
- Magic wand button: auto-resolve non-conflicting changes

**Documentation:** [IntelliJ - Resolve Conflicts](https://www.jetbrains.com/help/idea/resolve-conflicts.html)

### Visual Studio

Visual Studio shows a merge editor with:
- "Take Current" (your changes)
- "Take Incoming" (their changes)
- "Take Both" (include both)
- Checkbox-based selection for each conflict

**Documentation:** [Visual Studio - Git Merge Conflict Resolution](https://learn.microsoft.com/en-us/visualstudio/version-control/git-resolve-conflicts)

### Command Line: Configure a Merge Tool

```bash
# Set up VS Code as merge tool
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Set up IntelliJ as merge tool
git config --global merge.tool intellij
git config --global mergetool.intellij.cmd 'idea merge $LOCAL $REMOTE $BASE $MERGED'

# Use the configured tool
git mergetool
```

### IDE Quick Reference

| IDE | Trigger | Ours/Theirs Labels |
|-----|---------|-------------------|
| VS Code | Automatic on conflict | "Current" / "Incoming" |
| IntelliJ | Git > Resolve Conflicts | "Yours" / "Theirs" |
| Visual Studio | Git Changes panel | "Current" / "Incoming" |
| Xcode | Source Control navigator | "Current" / "Other" |

---

## 🚀 Pro Tips

1. **Always read git status** - It tells you exactly what's happening
2. **When confused, abort and retry** - `--abort` is your friend
3. **Manual editing is safest** - No confusion about ours/theirs
4. **Commit message matters** - Describe HOW you resolved the conflict
5. **Test after resolution** - Make sure the code works!
6. **Use your IDE's merge tool** - Visual diff is much easier than reading markers

---

## 🚀 What's Next?

In **Module 8: Rebasing**, we'll learn:
- An alternative to merging
- Interactive rebase for cleaning up history
- When to rebase vs when to merge
