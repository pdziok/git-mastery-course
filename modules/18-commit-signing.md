# Module 18: Commit Signing - Proving Authenticity

## 🎯 Learning Objectives

After this module, you will:
- Understand why commit signing matters
- Set up GPG or SSH key signing
- Configure GitHub/GitLab to verify your commits
- Sign commits automatically
- Verify signed commits

---

## 🏠 Why Sign Commits?

### The Problem: Anyone Can Claim to Be You

```bash
# Anyone can do this:
git config user.name "Linus Torvalds"
git config user.email "torvalds@linux-foundation.org"
git commit -m "Totally legitimate commit from Linus"

# Git doesn't verify identity!
```

### The Solution: Cryptographic Signatures

Signed commits prove:
1. **Authenticity** - The commit really came from you
2. **Integrity** - The commit hasn't been tampered with
3. **Non-repudiation** - You can't deny making the commit

```
Unsigned commit:              Signed commit:
┌─────────────────┐          ┌─────────────────┐
│ Author: Alice   │          │ Author: Alice   │
│ Message: fix    │          │ Message: fix    │
│                 │          │ Signature: ✓    │
│ "Trust me bro"  │          │ Verified by GPG │
└─────────────────┘          └─────────────────┘
     🤷 Maybe?                   ✅ Verified!
```

---

## 📖 Signing Methods

Git supports two signing methods:

| Method | Pros | Cons |
|--------|------|------|
| **GPG** | Industry standard, works everywhere | More complex setup |
| **SSH** | Use existing SSH keys, simpler | Newer (Git 2.34+), less universal |

GitHub, GitLab, and Bitbucket support both.

---

## 📖 Part 1: GPG Key Signing (Traditional)

### Step 1: Check/Install GPG

```bash
# Check if installed
gpg --version

# macOS (install via Homebrew)
brew install gnupg

# Ubuntu/Debian
sudo apt install gnupg

# Windows (comes with Git for Windows, or install Gpg4win)
```

### Step 2: Generate GPG Key

```bash
# Generate a new key
gpg --full-generate-key

# Prompts:
# - Kind: RSA and RSA (default)
# - Keysize: 4096 (recommended)
# - Expiration: 1y or 2y (recommended), or 0 for no expiration
# - Real name: Your Full Name
# - Email: your-email@example.com (MUST match Git/GitHub email)
# - Passphrase: Choose a strong passphrase

# List your keys
gpg --list-secret-keys --keyid-format=long
```

Output looks like:
```
/Users/you/.gnupg/pubring.kbx
------------------------------
sec   rsa4096/ABC123DEF456GHI 2024-01-15 [SC]
      FULL_FINGERPRINT_HERE
uid                 [ultimate] Your Name <you@email.com>
ssb   rsa4096/XYZ789... 2024-01-15 [E]
```

The key ID is `ABC123DEF456GHI` (after `rsa4096/`).

### Step 3: Configure Git to Use GPG Key

```bash
# Set your signing key (use your key ID)
git config --global user.signingkey ABC123DEF456GHI

# Tell Git to use GPG
git config --global gpg.program gpg

# Sign all commits by default (optional but recommended)
git config --global commit.gpgsign true

# Sign all tags by default
git config --global tag.gpgsign true
```

### Step 4: Export Public Key for GitHub/GitLab

```bash
# Export your public key
gpg --armor --export ABC123DEF456GHI

# Output starts with:
# -----BEGIN PGP PUBLIC KEY BLOCK-----
# ... lots of characters ...
# -----END PGP PUBLIC KEY BLOCK-----

# Copy this entire block!
```

### Step 5: Add Key to GitHub

1. Go to GitHub → Settings → SSH and GPG keys
2. Click "New GPG key"
3. Paste your public key
4. Click "Add GPG key"

GitLab: Settings → GPG Keys → Add key

---

## 🔬 Hands-On Exercise 16.1: Sign a Commit with GPG

```bash
# Create test repo
cd ~/git-workshop
mkdir signing-test && cd signing-test
git init

echo "test" > file.txt
git add file.txt

# Sign this specific commit (if not auto-signing)
git commit -S -m "feat: add file (signed)"

# Or if you configured commit.gpgsign=true:
git commit -m "feat: add file (auto-signed)"

# Verify the signature
git log --show-signature -1

# You'll see:
# gpg: Signature made Mon Jan 15 10:00:00 2024 CET
# gpg:                using RSA key ABC123...
# gpg: Good signature from "Your Name <you@email.com>"
```

---

## 📖 Part 2: SSH Key Signing (Simpler, Newer)

**Requires Git 2.34+**

### Step 1: Use Existing or Generate SSH Key

```bash
# Check existing keys
ls -la ~/.ssh/

# If you have id_ed25519.pub or id_rsa.pub, you can use it!

# Or generate new
ssh-keygen -t ed25519 -C "your-email@example.com"
```

### Step 2: Configure Git for SSH Signing

```bash
# Tell Git to use SSH for signing
git config --global gpg.format ssh

# Set your signing key (path to PRIVATE key)
git config --global user.signingkey ~/.ssh/id_ed25519

# Sign all commits by default
git config --global commit.gpgsign true
```

### Step 3: Set Up Allowed Signers (for Verification)

Create `~/.ssh/allowed_signers`:
```
your-email@example.com ssh-ed25519 AAAA... (your public key)
```

```bash
# Tell Git where to find allowed signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

### Step 4: Add SSH Signing Key to GitHub

1. Go to GitHub → Settings → SSH and GPG keys
2. Click "New SSH key"
3. **Key type: Signing Key** (not Authentication!)
4. Paste your public key
5. Click "Add SSH key"

---

## 🔬 Hands-On Exercise 16.2: Sign with SSH Key

```bash
# If you've set up SSH signing

cd ~/git-workshop/signing-test

echo "more content" >> file.txt
git add file.txt
git commit -m "feat: update file (SSH signed)"

# Verify
git log --show-signature -1
```

---

## 📖 Verification in Git Hosts

### On GitHub

Signed commits show a "Verified" badge:

```
┌─────────────────────────────────────────────────────────────────┐
│  commit abc123                                                  │
│  Author: Your Name <you@email.com>                              │
│                                                     [Verified ✓]│
│  feat: add authentication                                       │
└─────────────────────────────────────────────────────────────────┘
```

Unsigned or unverified commits may show:
- No badge (just no verification)
- "Unverified" (if vigilant mode is on)

### Enable Vigilant Mode (GitHub)

Settings → SSH and GPG keys → Enable "Flag unsigned commits as unverified"

This makes ALL unsigned commits show as "Unverified".

---

## 📖 Troubleshooting GPG Signing

### "error: gpg failed to sign the data"

```bash
# Fix 1: Tell GPG which TTY to use
export GPG_TTY=$(tty)
# Add to ~/.bashrc or ~/.zshrc

# Fix 2: Restart gpg-agent
gpgconf --kill gpg-agent
gpg-agent --daemon

# Fix 3: Test GPG manually
echo "test" | gpg --clearsign
# Should prompt for passphrase
```

### macOS Keychain Issues

```bash
# Install pinentry-mac
brew install pinentry-mac

# Configure GPG to use it
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf

# Restart agent
gpgconf --kill gpg-agent
```

### Key Expired

```bash
# Extend expiration
gpg --edit-key YOUR_KEY_ID
gpg> expire
# Follow prompts
gpg> save

# Re-export and upload to GitHub
gpg --armor --export YOUR_KEY_ID
```

---

## 📖 Signing Tags

```bash
# Create signed tag
git tag -s v1.0.0 -m "Release version 1.0.0"

# Create unsigned tag (not recommended for releases)
git tag v1.0.0 -m "Release version 1.0.0"

# Verify a tag
git tag -v v1.0.0
```

---

## 📖 Team Considerations

### Setting Up Required Signed Commits

**GitHub:**
1. Repository → Settings → Branches
2. Add branch protection rule for `main`
3. Check "Require signed commits"

**GitLab:**
1. Repository → Settings → Push Rules
2. Check "Reject unsigned commits"

### Verifying Others' Commits

```bash
# Import a teammate's public key
gpg --import teammate_key.asc

# Trust the key (after verifying fingerprint with them!)
gpg --edit-key THEIR_KEY_ID
gpg> trust
# Choose level 4 or 5
gpg> save

# Now you can verify their commits
git log --show-signature
```

---

## ✅ Checkpoint: Test Your Understanding

1. **Q:** Why can't Git verify identity without signing?

2. **Q:** What's the difference between GPG and SSH signing?

3. **Q:** What config makes all commits signed automatically?

4. **Q:** Where do you upload your public key for GitHub verification?

5. **Q:** What flag on a signed commit means on GitHub?

---

<details>
<summary>Click to reveal answers</summary>

1. **A:** Because anyone can configure any name/email in `git config` - there's no authentication

2. **A:** GPG uses separate GPG keys and is more traditional/universal; SSH uses your existing SSH keys and is simpler but newer (requires Git 2.34+)

3. **A:** `git config --global commit.gpgsign true`

4. **A:** GitHub Settings → SSH and GPG keys

5. **A:** The "Verified" badge shows the commit was signed with a key associated with that GitHub account

</details>

---

## 🎯 Commit Signing Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMMIT SIGNING                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  GPG SETUP                                                      │
│  gpg --full-generate-key                 Generate key           │
│  gpg --list-secret-keys --keyid-format=long  List keys          │
│  gpg --armor --export KEY_ID             Export for GitHub      │
│  git config --global user.signingkey KEY_ID  Set signing key    │
│  git config --global commit.gpgsign true     Auto-sign          │
│                                                                 │
│  SSH SETUP (Git 2.34+)                                          │
│  git config --global gpg.format ssh                             │
│  git config --global user.signingkey ~/.ssh/id_ed25519          │
│  git config --global commit.gpgsign true                        │
│                                                                 │
│  SIGNING                                                        │
│  git commit -S -m "message"    Sign single commit               │
│  git tag -s v1.0.0 -m "msg"    Signed tag                       │
│                                                                 │
│  VERIFICATION                                                   │
│  git log --show-signature      Show signatures                  │
│  git verify-commit <hash>      Verify specific commit           │
│  git tag -v <tag>              Verify tag                       │
│                                                                 │
│  TROUBLESHOOTING                                                │
│  export GPG_TTY=$(tty)         Fix TTY issues                   │
│  gpgconf --kill gpg-agent      Restart GPG agent                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 What's Next?

In **Module 19: Git Hooks**, we'll learn:
- Automated tasks with hooks
- Pre-commit hooks for linting/formatting
- Using Husky (JS) and Gradle hooks (JVM)
