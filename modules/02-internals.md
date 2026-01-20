# Module 2: Git Internals - What's Really Happening

## 🎯 Learning Objectives

After this module, you will:
- Understand Git's object model (blobs, trees, commits)
- See that branches are just pointers (files with 40 characters!)
- Demystify HEAD and understand "detached HEAD"
- Know why Git is so fast and efficient

---

## 🏠 The Library System Metaphor

Think of Git as a special library with an unusual cataloging system:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         THE GIT LIBRARY                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  STORAGE ROOM (objects/)          │  CARD CATALOG (refs/)            │
│  ─────────────────────────        │  ─────────────────────           │
│                                    │                                  │
│  ┌───────────┐                    │  ┌───────────────────┐           │
│  │   BLOB    │ ← Page of text     │  │ main → abc123     │ Bookmark  │
│  │  (file)   │   (no filename!)   │  │ feature → def456  │ pointing  │
│  └───────────┘                    │  │ bugfix → 789ghi   │ to a card │
│                                    │  └───────────────────┘           │
│  ┌───────────┐                    │                                  │
│  │   TREE    │ ← Directory list   │  ┌───────────────────┐           │
│  │  (folder) │   "xyz is hello.txt"│  │ HEAD → refs/heads/│ Sticky   │
│  └───────────┘                    │  │        main       │ note:     │
│                                    │  └───────────────────┘ "You're  │
│  ┌───────────┐                    │                        reading   │
│  │  COMMIT   │ ← Library card     │                        THIS      │
│  │           │   (metadata+tree)  │                        bookmark" │
│  └───────────┘                    │                                  │
│                                    │                                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📖 Theory: Git Objects - Everything is Content-Addressed

Git stores EVERYTHING as objects. Each object has:
- A **type** (blob, tree, commit, or tag)
- **Content** (the actual data)
- A **SHA-1 hash** (40-character ID based on content)

```
Content: "Hello, Git!"
   ↓
SHA-1 hash: a8f5f167f44f4964e6c998dee827110c
   ↓
Stored in: .git/objects/a8/f5f167f44f4964e6c998dee827110c
```

**Key insight:** Same content = same hash = stored only once!
If you have the same file in 100 commits, it's stored once.

---

## 📖 Theory: The Three Object Types

### 1. Blob (Binary Large Object)
- Just the file CONTENT, nothing else
- No filename, no permissions, no metadata
- Two files with identical content = same blob

### 2. Tree
- A directory listing
- Maps names → blobs or other trees
- Contains: permissions, type, hash, filename

```
100644 blob a8f5f167... hello.txt
100644 blob b6c7d8e9... readme.md
040000 tree c9d0e1f2... src/
```

### 3. Commit
- Points to a tree (the snapshot)
- Points to parent commit(s)
- Contains: author, committer, date, message

```
tree 4b825dc6...
parent a1b2c3d4...
author John Doe <john@example.com> 1705312200 +0100
committer John Doe <john@example.com> 1705312200 +0100

Add login button
```

---

## 📖 Theory: Branches are Just Pointers!

This is the BIGGEST "aha" moment in Git:

```bash
cat .git/refs/heads/main
# Output: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

That's it. A branch is a 41-byte file containing a commit hash + newline.

**Creating a branch = creating a tiny file with a hash.**
**Switching branches = changing which file HEAD points to.**

This is why Git branches are so fast and cheap compared to other version control systems!

---

## 📖 Theory: HEAD - Where Are You?

HEAD answers: "What am I looking at right now?"

```
Usually:                          Detached HEAD:
┌───────────────────┐            ┌───────────────────┐
│ HEAD              │            │ HEAD              │
│  ↓                │            │  ↓                │
│ refs/heads/main   │            │ a1b2c3d4...       │
│  ↓                │            │ (direct commit)   │
│ a1b2c3d4...       │            │                   │
│ (commit)          │            │                   │
└───────────────────┘            └───────────────────┘

"I'm on branch main"              "I'm at a specific commit"
```

**Detached HEAD** = HEAD points directly to a commit, not a branch.
New commits won't be on any branch and might be "lost"!

---

## 🔬 Hands-On Exercise 2.1: Explore Git Objects

```bash
# Create fresh playground
cd ~/git-workshop
rm -rf playground
mkdir playground && cd playground
git init

# Create and commit a file
echo "Hello, Git!" > hello.txt
git add hello.txt
git commit -m "First commit"

# 1. Find our commit's hash
git log --oneline
# Example output: a1b2c3d (HEAD -> main) First commit

# 2. Look at the commit object (replace with your hash!)
git cat-file -t a1b2c3d    # Shows: commit
git cat-file -p a1b2c3d    # Shows the commit content!

# You'll see something like:
# tree 68aba62e...
# author Your Name <email> timestamp
# committer Your Name <email> timestamp
#
# First commit

# 3. Look at the tree (copy the tree hash from above)
git cat-file -p 68aba62e   # Replace with your tree hash!

# You'll see:
# 100644 blob 8d0e4127... hello.txt

# 4. Look at the blob (the actual file content)
git cat-file -p 8d0e4127   # Replace with your blob hash!

# You'll see:
# Hello, Git!
```

**🎓 Key Learning:** You just followed the chain: commit → tree → blob!

---

## 🔬 Hands-On Exercise 2.2: Branches Are Just Files

```bash
# Still in playground

# 1. See what branches exist
ls .git/refs/heads/
# Shows: main (or master)

# 2. Look inside the branch file
cat .git/refs/heads/main
# Shows the commit hash!

# 3. Create a branch the "Git way"
git branch feature-x

# 4. A new file appeared!
ls .git/refs/heads/
# Shows: main, feature-x

# 5. They contain the same hash (both point to same commit)
cat .git/refs/heads/main
cat .git/refs/heads/feature-x
# Same hash!

# 6. See where HEAD points
cat .git/HEAD
# Shows: ref: refs/heads/main

# 7. Switch branches
git checkout feature-x

# 8. HEAD changed!
cat .git/HEAD
# Shows: ref: refs/heads/feature-x
```

---

## 🔬 Hands-On Exercise 2.3: Watch Branches Move

```bash
# Still on feature-x

# 1. Record the current commit hash
cat .git/refs/heads/feature-x
# Save this hash mentally (e.g., a1b2c3d...)

# 2. Make a new commit
echo "Feature work" > feature.txt
git add feature.txt
git commit -m "Add feature"

# 3. Check the branch file again
cat .git/refs/heads/feature-x
# It's a NEW hash now!

# 4. Main didn't move
cat .git/refs/heads/main
# Still the old hash!

# 5. Visualize this
git log --oneline --all --graph

# Output:
# * b2c3d4e (HEAD -> feature-x) Add feature
# * a1b2c3d (main) First commit
```

**🎓 Key Learning:** Commits don't move. Branches (pointers) move forward with each new commit.

---

## 🔬 Hands-On Exercise 2.4: Detached HEAD State

```bash
# 1. Get the first commit hash
git log --oneline
# Note both hashes

# 2. Checkout the first commit directly (not the branch)
git checkout a1b2c3d  # Use YOUR first commit hash

# 3. Read the scary message! Git warns you about detached HEAD

# 4. Check HEAD
cat .git/HEAD
# Shows the hash directly, not "ref: refs/heads/..."

# 5. You can look around, even make commits... but they're "floating"
echo "Detached work" > detached.txt
git add detached.txt
git commit -m "Detached commit"

# 6. Look at the graph
git log --oneline --all --graph
# Your new commit is there, but not on any branch!

# 7. Switch to a real branch
git checkout main

# 8. The "detached" commit is now orphaned (will be garbage collected eventually)
git log --oneline --all --graph
# The detached commit might not show up anymore!
```

**🎓 Key Learning:** Always work on branches! Detached HEAD is for looking, not for working.

---

## 🔬 Hands-On Exercise 2.5: Same Content = Same Object

```bash
# Create two files with identical content
echo "Same content" > file1.txt
echo "Same content" > file2.txt

git add file1.txt file2.txt
git commit -m "Add two files with same content"

# Look at the tree
git cat-file -p HEAD^{tree}

# You'll see BOTH files point to the SAME blob hash!
# 100644 blob 8e1f0e3... file1.txt
# 100644 blob 8e1f0e3... file2.txt  ← Same hash!

# Git is efficient - it stores the content only once
```

---

## 📊 Visual Summary: The Object Graph

```
                    ┌─────────────┐
                    │   HEAD      │
                    │ (ref: main) │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ main branch │
                    │ (pointer)   │
                    └──────┬──────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│                    COMMIT abc123                        │
│  tree: def456                                          │
│  parent: (none - first commit)                         │
│  author: John Doe                                      │
│  message: "First commit"                               │
└────────────────────────────────────┬───────────────────┘
                                     │
                                     ▼
                    ┌────────────────────────────────────┐
                    │            TREE def456              │
                    │  blob 789abc → hello.txt           │
                    │  blob 789abc → copy.txt (same!)    │
                    │  tree fedcba → src/                │
                    └──────────────────┬─────────────────┘
                                       │
                                       ▼
                    ┌────────────────────────────────────┐
                    │            BLOB 789abc              │
                    │                                     │
                    │         "Hello, Git!"               │
                    │                                     │
                    └────────────────────────────────────┘
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What are the three main types of Git objects?

2. **Q:** What does a branch file (like `.git/refs/heads/main`) contain?

3. **Q:** What does HEAD point to normally? What about in "detached HEAD" state?

4. **Q:** If two files have identical content, how many blobs does Git store?

5. **Q:** Why can Git create branches so quickly?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** Blob (file content), Tree (directory listing), Commit (snapshot + metadata)

2. **A:** Just a 40-character SHA-1 hash pointing to a commit

3. **A:** Normally: a reference to a branch (e.g., `ref: refs/heads/main`). Detached: directly to a commit hash

4. **A:** Just ONE blob! Same content = same hash = stored once

5. **A:** Because creating a branch just means creating a tiny 41-byte file with a commit hash

</details>

---

## 💡 What Your IDE Does (Now You Know!)

| IDE Action | What's Really Happening |
|------------|------------------------|
| Show branches | Reads `.git/refs/heads/` directory |
| Switch branch | Writes new ref to `.git/HEAD`, updates working directory |
| Show commit history | Walks the parent chain from HEAD |
| Show file at version | Reads blob object from `.git/objects/` |

---

## 🚀 What's Next?

In **Module 3**, we'll master the daily bread commands:
- `git status` - reading it like a pro
- `git diff` - all the variants
- `git log` - powerful history exploration

---

## 📝 Notes for the Instructor

Key points to emphasize:
1. The "objects are content-addressed" concept is fundamental
2. Show them the actual files - it demystifies Git completely
3. Branches being pointers is THE key insight for understanding merge/rebase later
4. Detached HEAD is scary but now they understand why
