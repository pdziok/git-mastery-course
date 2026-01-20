# Module 15: Terminal Editors for Git - Surviving Without IDE

## 🎯 Learning Objectives

After this module, you will:
- Use nano, vi, and vim for Git operations
- Configure your preferred editor for Git
- Navigate interactive rebase in a terminal
- Edit commit messages over SSH

---

## 🏠 Why Terminal Editors Matter

Sometimes you MUST use a terminal editor:

- SSH into a server without IDE
- Editing commits on a remote machine
- Interactive rebase opens an editor
- Commit messages (when not using `-m`)
- Merge conflict resolution
- Git hooks editing

```
Your IDE                     SSH to production server
┌──────────────┐            ┌──────────────────────────────┐
│  VS Code     │ ──────────>│ $ vim commit_message.txt    │
│  IntelliJ    │   No GUI!  │                              │
│  etc.        │            │ You need terminal skills!    │
└──────────────┘            └──────────────────────────────┘
```

---

## 📖 Configuring Your Git Editor

```bash
# Check current editor
git config --global core.editor

# Set to nano (easiest for beginners)
git config --global core.editor "nano"

# Set to vim (powerful, steeper learning curve)
git config --global core.editor "vim"

# Set to vi (available everywhere)
git config --global core.editor "vi"

# Set to VS Code (if available)
git config --global core.editor "code --wait"

# Set to Sublime Text
git config --global core.editor "subl -n -w"
```

**Important:** The `--wait` flag tells Git to wait for the editor to close.

---

## 📖 NANO - The Beginner-Friendly Editor

Nano is the easiest terminal editor. Commands are shown at the bottom!

### Opening Nano
```bash
nano filename.txt
```

### The Nano Interface
```
┌─────────────────────────────────────────────────────────────────┐
│  GNU nano 5.4                    filename.txt                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  This is the file content.                                      │
│  You can type directly here.                                    │
│  The cursor shows where you are.                                │
│                                                                 │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│ ^G Help    ^O Write Out  ^W Where Is  ^K Cut       ^C Location  │
│ ^X Exit    ^R Read File  ^\ Replace   ^U Paste     ^T Spelling  │
└─────────────────────────────────────────────────────────────────┘

^ means Ctrl key
```

### Essential Nano Commands

| Command | Action |
|---------|--------|
| `Ctrl + O` | Save (Write Out) - then press Enter |
| `Ctrl + X` | Exit (prompts to save if modified) |
| `Ctrl + K` | Cut (delete) current line |
| `Ctrl + U` | Paste (uncut) line |
| `Ctrl + W` | Search (Where is) |
| `Ctrl + G` | Help |
| Arrow keys | Navigate |

### Nano Workflow for Git

```bash
# Commit without -m opens nano
git commit
# 1. Type your commit message
# 2. Ctrl+O, Enter to save
# 3. Ctrl+X to exit
```

---

## 🔬 Hands-On Exercise 13.1: Using Nano for Commits

```bash
# Set nano as your editor
git config --global core.editor "nano"

# Create a test repo
cd ~/git-workshop
mkdir nano-test && cd nano-test
git init

echo "test file" > test.txt
git add test.txt

# Commit without -m (opens nano)
git commit

# In nano:
# 1. Type: "feat: add test file"
# 2. Press Ctrl+O (save)
# 3. Press Enter (confirm filename)
# 4. Press Ctrl+X (exit)

# Check it worked
git log --oneline
```

---

## 📖 VIM/VI - The Powerful Editor

Vi/Vim is **modal** - it has different modes:

```
┌─────────────────────────────────────────────────────────────────┐
│                         VIM MODES                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  NORMAL MODE (default)          INSERT MODE                     │
│  ─────────────────               ───────────                    │
│  Navigation, commands           Typing text                     │
│                                                                 │
│  Press 'i' to enter ──────────────────────>                     │
│                                                                 │
│  <─────────────────────────────────── Press 'Esc' to exit       │
│                                                                 │
│                                                                 │
│  COMMAND MODE                                                   │
│  ────────────                                                   │
│  Save, quit, search                                             │
│  Enter with ':' from Normal mode                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The Most Important Thing

```
╔═══════════════════════════════════════════════════════════════╗
║                                                                 ║
║   To exit Vim:  Press Esc, then type  :wq  and press Enter    ║
║   (write and quit)                                              ║
║                                                                 ║
║   To exit WITHOUT saving:  Esc, then  :q!  and Enter          ║
║                                                                 ║
╚═══════════════════════════════════════════════════════════════╝
```

### Essential Vim Commands

**From NORMAL mode (press Esc first):**

| Command | Action |
|---------|--------|
| `i` | Enter INSERT mode (start typing) |
| `Esc` | Return to NORMAL mode |
| `:w` | Save (write) |
| `:q` | Quit (fails if unsaved changes) |
| `:wq` | Save and quit |
| `:q!` | Quit WITHOUT saving (force) |
| `dd` | Delete current line |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `/text` | Search for "text" |
| `n` | Next search result |
| `gg` | Go to top of file |
| `G` | Go to bottom of file |

**Entering INSERT mode:**

| Command | Where cursor goes |
|---------|-------------------|
| `i` | Before cursor |
| `a` | After cursor |
| `I` | Beginning of line |
| `A` | End of line |
| `o` | New line below |
| `O` | New line above |

---

## 🔬 Hands-On Exercise 13.2: Using Vim for Commits

```bash
# Set vim as your editor
git config --global core.editor "vim"

cd ~/git-workshop
rm -rf vim-test && mkdir vim-test && cd vim-test
git init

echo "test" > test.txt
git add test.txt

# Commit without -m (opens vim)
git commit

# In vim:
# 1. Press 'i' to enter INSERT mode
# 2. Type your message: "feat: add test file"
# 3. Press Esc to return to NORMAL mode
# 4. Type :wq and press Enter

git log --oneline
```

---

## 🔬 Hands-On Exercise 13.3: Interactive Rebase in Vim

This is where terminal editor skills really matter!

```bash
# Create commits to rebase
cd ~/git-workshop
rm -rf rebase-test && mkdir rebase-test && cd rebase-test
git init

echo "1" > file.txt && git add . && git commit -m "First"
echo "2" >> file.txt && git add . && git commit -m "WIP"
echo "3" >> file.txt && git add . && git commit -m "WIP again"
echo "4" >> file.txt && git add . && git commit -m "done maybe"
echo "5" >> file.txt && git add . && git commit -m "actually done"

# Start interactive rebase
git rebase -i HEAD~4
```

Vim opens with:
```
pick abc1234 WIP
pick def5678 WIP again
pick ghi9012 done maybe
pick jkl3456 actually done

# Rebase abc1234..jkl3456 onto xyz9999 (4 commands)
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit message
# s, squash = meld into previous commit
# f, fixup = like squash, but discard message
# d, drop = remove commit
```

### The Workflow:

```
Step 1: You're in NORMAL mode (can't type yet)
        Cursor is on first "pick"

Step 2: Navigate using j/k (or arrow keys) to the line you want to change

Step 3: Position cursor on the word "pick"

Step 4: Type 'cw' (change word) - deletes "pick" and enters INSERT mode

Step 5: Type the new command: 'squash' or 's' or 'fixup' or 'f'

Step 6: Press Esc to return to NORMAL mode

Step 7: Repeat for other lines

Step 8: Type :wq to save and continue rebase
```

### Faster Way - Using 'r' to Replace

```
Step 1: Move to the line
Step 2: Move cursor to 'p' in "pick"
Step 3: Press 'r' (replace single character)
Step 4: Press 's' (changes "pick" to "sick")
Step 5: Press 'x' to delete extra characters, or use 'cw' instead

Actually, even faster:
- Go to line, type: 0cts<Esc>  (go to start, change to space, type s)
```

### Recommended Approach for Beginners

```
1. Press 'i' to enter INSERT mode immediately
2. Use arrow keys to navigate
3. Delete with backspace, type new text
4. Press Esc when done editing
5. Type :wq to save and exit
```

---

## 🔬 Hands-On Exercise 13.4: Complete Interactive Rebase Walkthrough

```bash
# Using the rebase-test repo from above

git rebase -i HEAD~4

# Goal: Squash all WIP commits into one good commit

# In Vim:
# 1. Press 'i' for INSERT mode
# 2. Change the file to look like:

pick abc1234 WIP
squash def5678 WIP again
squash ghi9012 done maybe
squash jkl3456 actually done

# 3. Press Esc
# 4. Type :wq and Enter

# Another editor opens for the combined commit message
# 1. Press 'i' for INSERT mode
# 2. Delete all the old messages (dd on each line in NORMAL mode, or select and delete)
# 3. Type new message: "feat: add complete feature"
# 4. Esc, :wq

git log --oneline
# Should now show just 2 commits: First and your squashed commit
```

---

## 📖 Quick Reference: Vim Survival Guide

```
┌─────────────────────────────────────────────────────────────────┐
│                    VIM SURVIVAL GUIDE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  MOST IMPORTANT                                                 │
│  Esc            Go to NORMAL mode (safe place)                  │
│  i              Enter INSERT mode (start typing)                │
│  :wq Enter      Save and exit                                   │
│  :q! Enter      Exit without saving                             │
│                                                                 │
│  NAVIGATION (in NORMAL mode)                                    │
│  h j k l        Left, Down, Up, Right (or use arrow keys)       │
│  gg             Go to top                                       │
│  G              Go to bottom                                    │
│  0              Go to start of line                             │
│  $              Go to end of line                               │
│                                                                 │
│  EDITING (in NORMAL mode)                                       │
│  i              Insert before cursor                            │
│  a              Insert after cursor                             │
│  o              New line below and insert                       │
│  dd             Delete whole line                               │
│  u              Undo                                            │
│  Ctrl+r         Redo                                            │
│                                                                 │
│  FOR INTERACTIVE REBASE                                         │
│  1. Use i to enter INSERT mode                                  │
│  2. Edit pick → squash/fixup/drop using arrow keys + typing     │
│  3. Esc, :wq to save                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📖 Nano vs Vim: When to Use Which

| Situation | Recommended | Why |
|-----------|-------------|-----|
| Quick commit message | Nano | Simple, visual hints |
| Interactive rebase | Either | Nano is easier, Vim is faster |
| Remote server (SSH) | Vi/Vim | Always available |
| Large file editing | Vim | More powerful |
| You're a beginner | Nano | Gentle learning curve |
| You edit often | Vim | Worth learning |

---

## 📖 Making Vim Less Scary

Add to your `~/.vimrc`:

```vim
" Show line numbers
set number

" Enable syntax highlighting
syntax on

" Show current mode
set showmode

" Highlight search results
set hlsearch

" Enable mouse support
set mouse=a

" Use spaces instead of tabs
set expandtab
set tabstop=4
set shiftwidth=4

" Show cursor position
set ruler
```

---

## 🔬 Hands-On Exercise 13.5: SSH Scenario

```bash
# Simulate working on a remote machine
# You have to use terminal editor!

# Create a "remote" directory
cd ~/git-workshop
mkdir remote-simulation && cd remote-simulation
git init

# Pretend VS Code isn't available
git config core.editor "vim"

# Make changes
echo "important code" > server.js
git add server.js

# Write a proper commit message (opens vim)
git commit
# Write: "feat: add server code"
# Esc, :wq

# Need to amend? (opens vim again)
git commit --amend
# Edit message, Esc, :wq

# Interactive rebase (vim)
echo "more" >> server.js && git add . && git commit -m "WIP"
echo "stuff" >> server.js && git add . && git commit -m "WIP2"
git rebase -i HEAD~2
# Change second line to 'squash' or 'fixup'
# Esc, :wq
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What command exits Vim and saves changes?

2. **Q:** How do you enter INSERT mode in Vim?

3. **Q:** In Nano, how do you save a file?

4. **Q:** What Vim mode must you be in to use `:wq`?

5. **Q:** How do you set nano as your default Git editor?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** `:wq` then Enter (from NORMAL mode)

2. **A:** Press `i` (or `a`, `o`, `O`, `I`, `A`)

3. **A:** `Ctrl+O` then Enter

4. **A:** NORMAL mode (press Esc first if not sure)

5. **A:** `git config --global core.editor "nano"`

</details>

---

## 🎯 Terminal Editor Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    NANO COMMANDS                                │
├─────────────────────────────────────────────────────────────────┤
│  Ctrl+O Enter     Save                                          │
│  Ctrl+X           Exit                                          │
│  Ctrl+K           Cut line                                      │
│  Ctrl+U           Paste                                         │
│  Ctrl+W           Search                                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    VIM COMMANDS                                 │
├─────────────────────────────────────────────────────────────────┤
│  Esc              Go to NORMAL mode                             │
│  i                Enter INSERT mode                             │
│  :wq Enter        Save and quit                                 │
│  :q! Enter        Quit without saving                           │
│  dd               Delete line                                   │
│  u                Undo                                          │
│  /text            Search                                        │
│  :set number      Show line numbers                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 16: Config and Aliases**, we'll learn:
- All the useful Git configuration options
- Creating powerful aliases
- Per-repository vs global config
