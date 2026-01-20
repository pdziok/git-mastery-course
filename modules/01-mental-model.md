# Module 1: Git Mental Model - The Foundation

## 🎯 Learning Objectives

After this module, you will:
- Understand what problem Git solves (and why it's different from "just saving files")
- Know the three areas: working directory, staging area, repository
- See the flow of changes through these areas

---

## 🏠 The Photography Studio Metaphor

Imagine you're a professional photographer creating a wedding album:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     YOUR PHOTOGRAPHY STUDIO                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │                 │    │                 │    │                 │  │
│  │   SHOOTING      │───>│   SELECTION     │───>│   THE ALBUM     │  │
│  │   AREA          │add │   TABLE         │commit│  (Permanent)   │  │
│  │                 │    │                 │    │                 │  │
│  │  Take photos,   │    │  "These photos  │    │  Glued pages,   │  │
│  │  experiment,    │    │   will go in    │    │  with captions  │  │
│  │  delete bad ones│    │   the album"    │    │  and dates      │  │
│  │                 │    │                 │    │                 │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘  │
│   Working Directory         Staging Area           Repository        │
│                               (Index)               (.git folder)    │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

**Why the staging area exists:**
- You don't want EVERY photo in the album, only the good ones
- You might want to group related photos on the same page (same commit)
- You can review your selection before committing

---

## 📖 Theory: The Three Areas

### 1. Working Directory (Your Folder)
- The actual files you see and edit
- The "messy desk" where you do your work
- Can be in any state - modified, deleted, new files

### 2. Staging Area / Index (The Selection)
- A "preview" of your next commit
- Files you've explicitly said "include this"
- Lives in `.git/index` (a binary file)

### 3. Repository (The History)
- The complete history of your project
- All commits, branches, everything
- Lives in `.git/` folder (don't touch it manually!)

---

## 📖 Theory: What is a Commit?

A commit is NOT just "saving changes". A commit is:

```
┌─────────────────────────────────────────┐
│              COMMIT abc123              │
├─────────────────────────────────────────┤
│ Author:  John Doe <john@example.com>    │
│ Date:    2024-01-15 10:30:00            │
│ Parent:  def456 (previous commit)       │
│ Message: "Add login button"             │
│                                         │
│ Snapshot:                               │
│   - index.html (version xyz...)        │
│   - style.css  (version abc...)        │
│   - app.js     (version 123...)        │
└─────────────────────────────────────────┘
```

**Key insight:** A commit stores the ENTIRE state of your project, not just the changes.
Git is smart enough to not duplicate unchanged files (it references them).

---

## 🔬 Hands-On Exercise 1.1: See the Three Areas

```bash
# Step 1: Create a fresh playground
cd ~/git-workshop
mkdir playground
cd playground
git init

# Step 2: Check the initial state
git status
# Notice: "No commits yet" and "nothing to commit"

# Step 3: Look inside .git (the repository)
ls -la .git/
# You'll see: HEAD, config, objects/, refs/, etc.

# Step 4: Create a file (now it's in Working Directory)
echo "Hello, Git!" > hello.txt
git status
# Notice: "Untracked files" - Git sees it but ignores it

# Step 5: Stage the file (move to Staging Area)
git add hello.txt
git status
# Notice: "Changes to be committed" - it's now staged

# Step 6: Commit (move to Repository)
git commit -m "Add greeting file"
git status
# Notice: "nothing to commit, working tree clean"

# Step 7: See your commit in history
git log --oneline
```

---

## 🔬 Hands-On Exercise 1.2: The Staging Area Dance

```bash
# You're still in the playground directory

# Step 1: Modify the file
echo "How are you?" >> hello.txt
cat hello.txt
# Shows both lines

# Step 2: Check status
git status
# Notice: "Changes not staged for commit" - it's modified but not staged

# Step 3: See the difference between Working Dir and Staging Area
git diff
# Shows the added line with + prefix

# Step 4: Stage it
git add hello.txt

# Step 5: Now git diff shows nothing!
git diff
# Nothing! Because Working Dir = Staging Area now

# Step 6: But we can compare Staging to last commit
git diff --staged
# Shows the change that WILL be committed

# Step 7: Make ANOTHER change before committing
echo "I'm learning Git!" >> hello.txt

# Step 8: Now check status - this is the key insight!
git status
# You'll see hello.txt TWICE:
# - "Changes to be committed" (the "How are you?" line)
# - "Changes not staged" (the "I'm learning Git!" line)

# Step 9: Commit only what's staged
git commit -m "Add friendly question"

# Step 10: Check - the third line is still in working dir, unstaged
git status
cat hello.txt  # Has 3 lines
git show HEAD:hello.txt  # Has only 2 lines!
```

**🎓 Key Learning:** The staging area lets you craft commits carefully. You can have different content in:
- Working directory (what you see in your editor)
- Staging area (what will be committed)
- Repository (what was last committed)

---

## 🔬 Hands-On Exercise 1.3: What Your IDE Does

When you click "Commit" in your IDE, it typically does:

```bash
git add <files-you-selected>
git commit -m "your message"
```

When you click the checkbox next to a file, it does:
```bash
git add <that-file>
```

When you click "Revert" or "Discard Changes" in your IDE:
```bash
git restore <that-file>
```

Let's simulate IDE behavior manually:

```bash
# Create multiple files
echo "File A content" > file_a.txt
echo "File B content" > file_b.txt
echo "File C content" > file_c.txt

git status
# All three are untracked

# IDE: You check only file_a and file_b
git add file_a.txt file_b.txt

git status
# file_a and file_b are staged
# file_c is still untracked

# IDE: You click Commit
git commit -m "Add files A and B"

# file_c is still there, uncommitted
git status
```

---

## ✅ Checkpoint: Test Your Understanding

Answer these questions (then check below):

1. **Q:** If you modify a file but don't run `git add`, will it be in your next commit?

2. **Q:** What command shows changes between your working directory and staging area?

3. **Q:** What command shows changes that WILL be in your next commit?

4. **Q:** Where does Git store all the history and commits?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** No! Only staged changes are committed. This is why IDE has checkboxes - each checked file gets `git add`.

2. **A:** `git diff` (no flags)

3. **A:** `git diff --staged` (or `git diff --cached` - same thing)

4. **A:** In the `.git/` folder in your project root

</details>

---

## 🧹 Cleanup (Optional)

```bash
# Keep the playground for the next module, or:
cd ..
rm -rf playground
```

---

## 🚀 What's Next?

In **Module 2**, we'll peek inside the `.git` folder and see:
- What a commit REALLY looks like (it's just a text file!)
- Why branches are nearly "free" (they're just 41-byte files!)
- How Git knows which branch you're on (HEAD)

---

## 📝 Notes for the Instructor

Key points to emphasize:
1. The staging area is THE killer feature for crafting clean commits
2. Git stores snapshots, not diffs (this is a common misconception)
3. Every git command just moves data between these three areas
4. The IDE checkboxes = `git add`, clicking Commit = `git commit`
