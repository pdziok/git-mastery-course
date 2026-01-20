# Docker Workshop Environment

A consistent Linux environment for the Git workshop. Works identically on Windows, macOS, and Linux.

## Quick Start

```bash
# Build the container
docker-compose build

# Start the container
docker-compose up -d

# Enter the container
docker exec -it git-workshop bash

# Now you're in a Linux environment with Git pre-configured!
# Run any workshop exercises here.

# Exit when done
exit

# Stop the container
docker-compose down
```

## What's Included

- Ubuntu 22.04
- Git (latest)
- nano and vim editors
- Pre-configured Git settings
- Useful aliases
- Workshop modules mounted at `/home/workshop/modules`
- Exercise area at `/home/workshop/exercises`

## Pre-configured Git Settings

```
user.name = Workshop User
user.email = workshop@example.com
init.defaultBranch = main
pull.rebase = true
core.editor = nano

Aliases:
  st = status
  co = checkout
  br = branch
  ci = commit
  lg = log --oneline --graph --all
```

## For Windows Users

Using Docker ensures you have:
- Proper line endings (LF)
- Case-sensitive filesystem
- Unix-style paths
- Same experience as macOS/Linux

### WSL2 Backend Recommended

1. Install Docker Desktop for Windows
2. Enable WSL2 backend in Docker settings
3. Run commands from PowerShell or Git Bash

## Resetting the Environment

```bash
# Remove container and volume (fresh start)
docker-compose down -v
docker-compose up -d
```

## Accessing Workshop Modules

```bash
# Inside the container
ls /home/workshop/modules/

# Read a module
less /home/workshop/modules/01-mental-model.md
```
