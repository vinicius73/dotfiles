# Dotfiles

Cross-platform personal environment for macOS (Apple Silicon and Intel) and Arch Linux.

## Supported platforms

- macOS `arm64` and `x86_64`
- Arch Linux

## Quick start

Use this path when the platform prerequisites are already installed:

```sh
git clone https://github.com/vinicius73/dotfiles.git
cd dotfiles
script/bootstrap plan
script/bootstrap apply
script/verify
```

`apply` is interactive: review and confirm the package changes, Chezmoi source, and configuration diff at each prompt.

To install optional tooling afterward:

```sh
script/profile list
script/profile plan cli
script/profile apply cli
```

## Complete installation

### 1. Prepare the system

#### macOS

1. Install the Xcode Command Line Tools:

   ```sh
   xcode-select --install
   ```

2. Install Homebrew in its default prefix.
3. Open a new terminal and confirm that Homebrew is available:

   ```sh
   brew --version
   ```

The bootstrap finds Homebrew through `PATH`, `/opt/homebrew/bin/brew`, or `/usr/local/bin/brew`. It never runs a remote Homebrew installer.

#### Arch Linux

1. Ensure the system is fully updated and that `sudo`, `pacman`, and network access work.
2. Install `paru` manually from the AUR, after reviewing its PKGBUILD and source files.
3. Confirm that `paru` is available:

   ```sh
   paru --version
   ```

`paru` installs both official-repository and explicitly selected AUR packages. Review all PKGBUILDs and source changes before accepting each prompt.

### 2. Clone the repository

```sh
git clone https://github.com/vinicius73/dotfiles.git
cd dotfiles
```

### 3. Review the base setup plan

```sh
script/bootstrap plan
```

The plan reports the detected platform, package manifest, current Chezmoi source, proposed source, and subsequent mise actions. Resolve missing prerequisites before continuing.

### 4. Apply the base setup

```sh
script/bootstrap apply
```

The base profile installs Git, Chezmoi, Fish, mise, certificates, Curl, and Bash. It does not install desktop applications, Docker, Rust, or change the login shell.

On Arch, use a full system upgrade only when explicitly intended:

```sh
script/bootstrap apply --system-upgrade
```

If Chezmoi is configured with another source, adopt this checkout before applying files:

```sh
script/bootstrap adopt-source
script/bootstrap apply
```

### 5. Verify the installation

```sh
script/verify
mise doctor
```

### 6. Configure your local Git identity

```sh
cp ~/.config/git/identity.local.example ~/.config/git/identity.local
```

Edit `~/.config/git/identity.local` with your identity. This local file is not managed by Chezmoi and must not be committed.

## Optional profiles

Always inspect a profile before installing it:

```sh
script/profile plan <profile>
script/profile apply <profile>
```

Available profiles:

```sh
script/profile list
script/profile apply cli
script/profile apply desktop
script/profile apply docker
script/profile apply pokemonsay
script/profile apply rust
script/profile apply shell
```

- `cli`: curated command-line tools.
- `desktop`: curated graphical applications.
- `docker`: Docker tooling. Start and configure Docker Desktop manually on macOS; enable the daemon and manage Docker-group membership manually on Arch.
- `pokemonsay`: optional, commit-pinned upstream payload; its installer is never executed.
- `rust`: Arch-only; installs `rustup` and the stable toolchain.
- `shell`: the only profile that changes the login shell; it always requires confirmation.

## Shell plugins

Install the pinned Fish and Zsh plugins only after reviewing their plan:

```sh
script/profile plan shell-plugins
script/profile apply shell-plugins
```

Fish uses Fisher. Zsh uses Antidote and generates its loader at `${XDG_CACHE_HOME:-~/.cache}/dotfiles/zsh/plugins.zsh`. Shell startup never downloads or updates plugins.

## Runtime ownership

mise manages Node, Corepack package managers, Go, Ruby, Java, Bun, and Deno. Rust is deliberately separate: the Arch-only `rust` profile installs and configures it through `rustup`. Rust is not installed on macOS.

## Local configuration

### Secrets

Bash, Fish, and Zsh load declared local secrets only in interactive sessions. First create the local configuration:

```sh
mkdir -p ~/.config/dotfiles/env.d
chmod 700 ~/.config/dotfiles ~/.config/dotfiles/env.d
cp ~/.config/dotfiles/secrets.conf.example ~/.config/dotfiles/secrets.conf
chmod 600 ~/.config/dotfiles/secrets.conf
```

Then declare one variable name per line in `~/.config/dotfiles/secrets.conf` and add a literal `NAME=value` entry for each declared name in `~/.config/dotfiles/env.d/*.env`.

These files are Git-ignored. Unsafe ownership or permissions prevent files from being loaded. Values do not support quotes, expansion, commands, or multiline syntax; undeclared names are rejected. On macOS, an unset declared name is looked up in Keychain using its name as the generic-password service and `$USER` as its account.

`EDITOR=micro`, `VISUAL`, Volta PATH removal, and mise activation are global shell behavior. Homebrew `mysql-client` PATH integration is macOS-only.

### Fish greeting

The Fish greeting is disabled by default. Enable it only in a trusted local terminal:

```fish
set -gx DOTFILES_GREETING 1
```

Suppress it for a session with:

```fish
set -gx DOTFILES_GREETING_DISABLE 1
```

### Global agent skills

Global skills declared in `home/dot_agents/skills/` are restored to `~/.agents/skills/` by `script/bootstrap apply`. Local skills with different names may coexist but are not managed or verified by Chezmoi. Edit versioned skills in this repository, review the Chezmoi diff, apply the configuration, then restart OpenCode.

### Private macOS configuration

Work-only OpenCode, Claude Code, Cursor, Zed, and related configuration lives in the ignored local `private/macos/` checkout. Apply the public configuration first, then follow [docs/private-macos.md](docs/private-macos.md).

## Validation

Run the local shell validation suite:

```sh
sh tests/run.sh
```

To run the same validation in an isolated Arch Linux container, start Docker and run:

```sh
script/validate-docker
```

The repository is mounted read-only and the container is removed after validation.

For operational details, see [docs/install.md](docs/install.md), [docs/profiles.md](docs/profiles.md), [docs/private-macos.md](docs/private-macos.md), and [maintenance/README.md](maintenance/README.md).
