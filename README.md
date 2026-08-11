# Dotfiles

Cross-platform personal environment for macOS (Apple Silicon and Intel) and Arch Linux.

## Supported platforms

- macOS `arm64` and `x86_64`
- Arch Linux

## Before the first install

### macOS

Install Xcode Command Line Tools and Homebrew in its default prefix. The bootstrap intentionally does not install Homebrew.

### Arch Linux

Use a fully updated Arch installation with a working `sudo`, `pacman`, and network connection. Install `paru` manually from the AUR after reviewing its PKGBUILD before running this repository's bootstrap.

## Install

Clone this repository, then run:

```sh
script/bootstrap
```

The default command is a safe plan. To install the base dependencies, inspect the Chezmoi diff, and optionally apply the configuration from an interactive terminal:

```sh
script/bootstrap --apply
```

The bootstrap intentionally has no non-interactive apply mode. Review the Chezmoi diff and confirm the interactive prompt before it changes home-directory files.
The base profile installs only Git, Chezmoi, Fish, mise, certificates, Curl, and Bash. It does not install desktop apps, Docker, Rust, or change the login shell.

On Arch, `paru` installs both official-repository packages and the explicitly listed AUR desktop packages. Review AUR PKGBUILDs and source changes at each prompt before accepting them; the scripts never use `--noconfirm` or disable signature or checksum verification.

## Profiles

```sh
script/profile list
script/profile apply cli
script/profile apply desktop
script/profile apply docker
script/profile apply pokemonsay
script/profile apply rust
script/profile apply shell
```

`rust` is Arch-only. `shell` is the only profile that can change the login shell, and always asks for confirmation. `pokemonsay` is optional and installs a commit-pinned upstream payload without executing its installer.

The Fish greeting is disabled by default. Enable it only in a trusted local terminal with `set -gx DOTFILES_GREETING 1`; use `set -gx DOTFILES_GREETING_DISABLE 1` to suppress it for a session.

## Runtime ownership

mise manages Node, Corepack package managers, Go, Ruby, Java, Bun, and Deno. Rust is intentionally excluded: on Arch, the `rust` profile installs `rustup` through paru and configures its stable toolchain. Rust is not installed on macOS.

## Local configuration

Copy `~/.config/git/identity.local.example` to `~/.config/git/identity.local`, edit it with your identity, and do not commit the result. Existing personal configuration should be reviewed in `chezmoi diff` before it is applied.

## Verification

```sh
script/verify
mise doctor
```

See [docs/install.md](docs/install.md), [docs/profiles.md](docs/profiles.md), and [docs/migration.md](docs/migration.md) for operational details.
