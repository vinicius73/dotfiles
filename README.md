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
script/bootstrap plan
```

To install the base dependencies from an interactive terminal:

```sh
script/bootstrap apply
```

The bootstrap has no non-interactive apply mode. `apply` confirms package installation before it changes packages, then confirms Chezmoi source adoption and the reviewed configuration diff separately. On Arch, `--system-upgrade` is required to perform a full system update.
The base profile installs only Git, Chezmoi, Fish, mise, certificates, Curl, and Bash. It does not install desktop apps, Docker, Rust, or change the login shell.

On Arch, `paru` installs both official-repository packages and the explicitly listed AUR desktop packages. Review AUR PKGBUILDs and source changes at each prompt before accepting them; `script/bootstrap` and `script/profile` never use `--noconfirm` or disable signature or checksum verification.

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

### Global agent skills

Global agent skills declared in `home/dot_agents/skills/` are restored to `~/.agents/skills/` by `script/bootstrap apply`. Local skills with different names may coexist there and are not managed or verified by Chezmoi. Edit versioned skills in this repository, review the Chezmoi diff, then restart OpenCode after applying changes.

### Private macOS configuration

Work-only OpenCode, Claude Code, Cursor, Zed, and related configuration lives in the ignored local `private/macos/` checkout. Apply public configuration first, then follow [docs/private-macos.md](docs/private-macos.md).

## Verification

```sh
script/verify
mise doctor
```

## Shells

Bash, Fish, and Zsh load declared local secrets only in interactive sessions. Copy `~/.config/dotfiles/secrets.conf.example` to `~/.config/dotfiles/secrets.conf`, declare one variable name per line, then add literal `NAME=value` entries for those exact names to `~/.config/dotfiles/env.d/*.env`:

```sh
mkdir -p ~/.config/dotfiles/env.d
chmod 700 ~/.config/dotfiles ~/.config/dotfiles/env.d
cp ~/.config/dotfiles/secrets.conf.example ~/.config/dotfiles/secrets.conf
chmod 600 ~/.config/dotfiles/secrets.conf
```

`secrets.conf` and `env.d` are local-only and ignored by Git. Files are ignored when their owner or permissions are unsafe. Values do not support quotes, expansion, commands, or multiline syntax, and undeclared names are rejected. On macOS, an unset declared name is looked up in Keychain using its name as the generic-password service and `$USER` as its account. No personal secret names or values are versioned.

`EDITOR=micro`, `VISUAL`, Volta PATH removal, and mise activation are global shell behavior. Homebrew `mysql-client` PATH integration is macOS-only.

Install the pinned Fish and Zsh plugins explicitly after reviewing the plan:

```sh
script/profile plan shell-plugins
script/profile apply shell-plugins
```

Fish uses Fisher; Zsh uses Antidote and writes its generated loader to `${XDG_CACHE_HOME:-~/.cache}/dotfiles/zsh/plugins.zsh`. Startup never downloads or updates plugins.

## Validation

Run the local shell validation suite with:

```sh
sh tests/run.sh
```

To run the same validation in an isolated Arch Linux container, start Docker and run:

```sh
script/validate-docker
```

The repository is mounted read-only and the container is removed after validation.

See [docs/install.md](docs/install.md), [docs/profiles.md](docs/profiles.md), [docs/private-macos.md](docs/private-macos.md), and [maintenance/README.md](maintenance/README.md) for operational details.
