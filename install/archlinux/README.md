# Arch Linux Installation Scripts

The `install/archlinux/` directory contains scripts for setting up specific tools and environments on Arch Linux.

## Scripts Overview

### `00-install.sh`
**Purpose:** Installs base dependencies, terminal emulators, development tools, fonts, and other utilities.  
**Highlights:**
- Ensures `paru` is installed.
- Installs packages like `fish`, `fzf`, `cowsay`, `visual-studio-code-bin`, and `noto-fonts-emoji`.

### `01-node.sh`
**Purpose:** Installs Node.js and Yarn using Volta.  
**Highlights:**
- Installs Node.js LTS and Yarn.
- Installs `gitmoji-cli` globally via npm.

### `02-flatpak.sh`
**Purpose:** Manages Flatpak repositories and applications.  
**Highlights:**
- Adds the Flathub repository.
- Installs or updates applications like VLC, KeePassXC, and Podman Desktop.

### `03-rust.sh`
**Purpose:** Installs and configures Rust using `rustup`.  
**Highlights:**
- Removes Rust installed via `pacman` if necessary.
- Installs the stable Rust toolchain and generates shell completions for Fish and Bash.

### `04-docker.sh`
**Purpose:** Sets up Docker and related tools. *(Script details not provided.)*

### `05-after-install.sh`
**Purpose:** Executes post-installation tasks. *(Script details not provided.)*

## Notes
- Ensure you have the necessary permissions to execute the scripts.
- Some scripts may require user interaction during execution.
- For Arch Linux, the `paru` AUR helper is required for package installation.
