# Module 17: Git Authentication - SSH, HTTPS, and Security

## 🎯 Learning Objectives

After this module, you will:
- Understand SSH vs HTTPS authentication
- Set up different identities for work/personal projects
- Configure credential helpers securely
- Choose the right auth method for your situation

---

## 📖 Part 1: SSH vs HTTPS

### The Two Ways to Talk to GitHub/GitLab

```
HTTPS:
┌─────────────────────────────────────────────────────────────────┐
│ git clone https://github.com/user/repo.git                      │
│                                                                 │
│ Authentication: Username + Password/Token                       │
│ Port: 443 (standard HTTPS)                                      │
│ Firewall: Usually allowed (web traffic)                         │
└─────────────────────────────────────────────────────────────────┘

SSH:
┌─────────────────────────────────────────────────────────────────┐
│ git clone git@github.com:user/repo.git                          │
│                                                                 │
│ Authentication: SSH Key (public/private key pair)               │
│ Port: 22 (SSH - may be blocked by some firewalls)               │
│ Firewall: Sometimes blocked on corporate networks               │
└─────────────────────────────────────────────────────────────────┘
```

### Comparison

| Aspect | HTTPS | SSH |
|--------|-------|-----|
| **Setup** | Easier (just login) | Need to generate and add keys |
| **URL Format** | `https://github.com/user/repo` | `git@github.com:user/repo` |
| **Firewall** | Usually allowed | Port 22 may be blocked |
| **Credential Storage** | Token/password (with helper) | SSH key (always) |
| **Multiple Accounts** | Tricky (same hostname) | Easy (different keys) |
| **Security** | Good (with tokens) | Excellent (key-based) |
| **2FA Compatible** | ✓ (with personal access token) | ✓ (keys bypass password) |

---

## 📖 Part 2: SSH Authentication (Recommended)

### Step 1: Generate SSH Key

```bash
# Generate Ed25519 key (recommended, modern)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Or RSA if Ed25519 not supported
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Prompts:
# - File: ~/.ssh/id_ed25519 (default) or custom name
# - Passphrase: Choose a strong one (adds extra security)
```

### Step 2: Add Key to SSH Agent

```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add key (will prompt for passphrase)
ssh-add ~/.ssh/id_ed25519

# On macOS, add to Keychain (remembers passphrase)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Step 3: Add Public Key to GitHub/GitLab

```bash
# Copy public key to clipboard
# macOS:
cat ~/.ssh/id_ed25519.pub | pbcopy

# Linux:
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard

# Windows (Git Bash):
cat ~/.ssh/id_ed25519.pub | clip
```

Then:
1. GitHub → Settings → SSH and GPG keys → New SSH key
2. Paste the key
3. Give it a descriptive title

### Step 4: Test Connection

```bash
ssh -T git@github.com
# Hi username! You've successfully authenticated...

ssh -T git@gitlab.com
# Welcome to GitLab, @username!
```

---

## 📖 Part 3: Multiple SSH Keys (Work + Personal)

### The Scenario

```
~/projects/
├── personal/        ← Use personal GitHub (personal@email.com)
│   ├── my-blog/
│   └── side-project/
└── work/            ← Use work GitHub/GitLab (you@company.com)
    ├── main-app/
    └── internal-tools/
```

### Step 1: Generate Separate Keys

```bash
# Personal key
ssh-keygen -t ed25519 -C "personal@email.com" -f ~/.ssh/id_personal

# Work key
ssh-keygen -t ed25519 -C "you@company.com" -f ~/.ssh/id_work
```

### Step 2: Configure SSH Config

Create/edit `~/.ssh/config`:

```
# Personal GitHub
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_personal
    IdentitiesOnly yes

# Work GitHub
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_work
    IdentitiesOnly yes

# Work GitLab
Host gitlab.company.com
    HostName gitlab.company.com
    User git
    IdentityFile ~/.ssh/id_work
    IdentitiesOnly yes
```

### Step 3: Clone with Correct Host

```bash
# Personal projects
git clone git@github.com-personal:youruser/personal-repo.git

# Work projects
git clone git@github.com-work:company/work-repo.git

# Or update existing remotes
git remote set-url origin git@github.com-personal:youruser/repo.git
```

### Step 4: Conditional Git Config (The Magic!)

Create `~/.gitconfig`:

```ini
[user]
    name = Your Name
    email = personal@email.com

[includeIf "gitdir:~/projects/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/projects/personal/"]
    path = ~/.gitconfig-personal
```

Create `~/.gitconfig-work`:

```ini
[user]
    name = Your Name (Company)
    email = you@company.com
    signingkey = ~/.ssh/id_work.pub

[gpg]
    format = ssh

[core]
    sshCommand = ssh -i ~/.ssh/id_work
```

Create `~/.gitconfig-personal`:

```ini
[user]
    name = Your Name
    email = personal@email.com
    signingkey = ~/.ssh/id_personal.pub

[gpg]
    format = ssh

[core]
    sshCommand = ssh -i ~/.ssh/id_personal
```

### Step 5: Verify It Works

```bash
cd ~/projects/work/some-repo
git config user.email
# you@company.com ✓

cd ~/projects/personal/my-blog
git config user.email
# personal@email.com ✓
```

---

## 📖 Part 4: HTTPS Authentication

### Personal Access Tokens (PAT)

GitHub no longer accepts passwords. You need a Personal Access Token:

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Select scopes: `repo`, `workflow` (and others as needed)
4. Copy the token (only shown once!)

### Using the Token

```bash
git clone https://github.com/user/private-repo.git
# Username: your-username
# Password: YOUR_PERSONAL_ACCESS_TOKEN (not your password!)
```

---

## 📖 Part 5: Credential Helpers

Credential helpers store your credentials so you don't retype them.

### Types of Credential Helpers

| Helper | Storage | Security | Platform |
|--------|---------|----------|----------|
| `cache` | Memory (temporary) | Good (expires) | Linux, macOS |
| `store` | Plain text file | Poor | Any |
| `osxkeychain` | macOS Keychain | Excellent | macOS |
| `manager` / `manager-core` | System credential store | Excellent | Windows |
| `libsecret` | GNOME Keyring | Excellent | Linux (GNOME) |

### Configuration

```bash
# macOS - Use Keychain (RECOMMENDED)
git config --global credential.helper osxkeychain

# Windows - Use Credential Manager
git config --global credential.helper manager-core

# Linux - Cache for 1 hour
git config --global credential.helper 'cache --timeout=3600'

# Linux with GNOME - Use Keyring
git config --global credential.helper libsecret
# May need: sudo apt install libsecret-1-0 libsecret-1-dev
#           sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret

# Plain text (NOT RECOMMENDED - visible to anyone with file access)
git config --global credential.helper store
# Stores in ~/.git-credentials
```

### GitHub CLI (`gh`) as Credential Helper

The GitHub CLI can act as a credential helper - very convenient!

```bash
# Install GitHub CLI
# macOS:
brew install gh

# Login
gh auth login

# Configure as credential helper
gh auth setup-git

# This adds to your gitconfig:
# [credential "https://github.com"]
#     helper = !gh auth git-credential
```

### Per-Host Credentials

```ini
# ~/.gitconfig

# Default helper
[credential]
    helper = osxkeychain

# Special helper for work GitLab
[credential "https://gitlab.company.com"]
    helper = store
    username = yourworkusername
```

---

## 📖 Part 6: Security Best Practices

### SSH Keys

```
✓ DO:
  - Use Ed25519 keys (modern, secure)
  - Set a strong passphrase
  - Use ssh-agent to avoid retyping passphrase
  - Have separate keys for work/personal
  - Rotate keys periodically (yearly)

✗ DON'T:
  - Create keys without passphrase
  - Share private keys
  - Commit private keys (obviously!)
  - Use the same key everywhere
```

### Personal Access Tokens

```
✓ DO:
  - Set expiration dates (90 days recommended)
  - Use minimal required scopes
  - Name tokens descriptively ("Work laptop - Jan 2024")
  - Regenerate tokens periodically
  - Use fine-grained tokens when available

✗ DON'T:
  - Create non-expiring tokens
  - Grant all scopes
  - Share tokens
  - Store in plain text
```

### Security Comparison

```
MOST SECURE → LEAST SECURE:

1. SSH with passphrase + ssh-agent
   (Key never leaves your machine, passphrase adds layer)

2. GitHub CLI (gh auth)
   (Handles token securely, OAuth-based)

3. HTTPS + osxkeychain/manager-core
   (Token in encrypted system store)

4. HTTPS + cache
   (Token in memory only, expires)

5. HTTPS + store
   (Token in plain text file - AVOID!)
```

---

## 🔬 Hands-On Exercise 15B.1: Set Up Work/Personal Config

```bash
# Create directory structure
mkdir -p ~/projects/personal
mkdir -p ~/projects/work

# Generate keys (if you haven't)
ssh-keygen -t ed25519 -C "personal@email.com" -f ~/.ssh/id_personal
ssh-keygen -t ed25519 -C "work@company.com" -f ~/.ssh/id_work

# Create SSH config
cat >> ~/.ssh/config << 'EOF'

# Personal GitHub
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_personal
    IdentitiesOnly yes

# Work GitHub
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_work
    IdentitiesOnly yes
EOF

# Create conditional Git configs
cat > ~/.gitconfig-personal << 'EOF'
[user]
    name = Your Personal Name
    email = personal@email.com
EOF

cat > ~/.gitconfig-work << 'EOF'
[user]
    name = Your Name (Company)
    email = work@company.com
EOF

# Add includes to main gitconfig
git config --global includeIf.gitdir:~/projects/personal/.path ~/.gitconfig-personal
git config --global includeIf.gitdir:~/projects/work/.path ~/.gitconfig-work

# Test it
cd ~/projects/personal && git init test-personal && cd test-personal
git config user.email
# personal@email.com

cd ~/projects/work && git init test-work && cd test-work
git config user.email
# work@company.com
```

---

## 🔬 Hands-On Exercise 15B.2: Switch Remote from HTTPS to SSH

```bash
# Check current remote
git remote -v
# origin  https://github.com/user/repo.git (fetch)
# origin  https://github.com/user/repo.git (push)

# Change to SSH
git remote set-url origin git@github.com:user/repo.git

# Or for custom host (work account):
git remote set-url origin git@github.com-work:company/repo.git

# Verify
git remote -v
# origin  git@github.com:user/repo.git (fetch)
# origin  git@github.com:user/repo.git (push)
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** What's the main advantage of SSH over HTTPS?

2. **Q:** Where does macOS Keychain store Git credentials?

3. **Q:** How do you use different GitHub accounts on the same machine with SSH?

4. **Q:** What does `includeIf "gitdir:~/work/"` do?

5. **Q:** Why should you avoid `credential.helper store`?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** Better security (key-based auth), easier multiple accounts, no password/token to store/type

2. **A:** In the macOS Keychain (encrypted system credential store)

3. **A:** Create multiple SSH keys and use `~/.ssh/config` to map different Host aliases to different IdentityFiles

4. **A:** Includes additional git configuration (from specified file) when working in repositories under ~/work/

5. **A:** It stores credentials in plain text (`~/.git-credentials`), readable by anyone with file access

</details>

---

## 🎯 Authentication Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SSH SETUP                                                      │
│  ssh-keygen -t ed25519 -C "email"      Generate key             │
│  ssh-add ~/.ssh/id_ed25519             Add to agent             │
│  ssh -T git@github.com                 Test connection          │
│                                                                 │
│  CREDENTIAL HELPERS                                             │
│  osxkeychain    macOS (recommended)                             │
│  manager-core   Windows (recommended)                           │
│  libsecret      Linux GNOME                                     │
│  cache          Temporary memory                                │
│  store          Plain text (avoid!)                             │
│                                                                 │
│  MULTIPLE ACCOUNTS                                              │
│  ~/.ssh/config     Map hosts to keys                            │
│  includeIf         Conditional gitconfig                        │
│                                                                 │
│  SWITCH HTTPS TO SSH                                            │
│  git remote set-url origin git@github.com:user/repo.git         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 18: Commit Signing**, we'll learn:
- Why sign commits for authenticity
- Setting up GPG/SSH signing
- Configuring GitHub to verify signatures
