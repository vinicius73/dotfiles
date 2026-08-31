# Installation

## macOS

1. Install Xcode Command Line Tools with `xcode-select --install`.
2. Install Homebrew in its default prefix.
3. Clone this repository.
4. Run `script/bootstrap plan`, review the plan, then run `script/bootstrap apply`.

The script locates an existing Homebrew executable from `PATH`, `/opt/homebrew/bin/brew`, or `/usr/local/bin/brew`. It does not run a remote Homebrew installer.

## Arch Linux

1. Ensure `sudo`, `pacman`, network access, and a fully updated system are available.
2. Install `paru` manually from the AUR after reviewing its PKGBUILD and source files.
3. Clone this repository.
4. Run `script/bootstrap plan`, review the plan, then run `script/bootstrap apply`.

The Arch base install runs `paru -S --needed`. Use `script/bootstrap apply --system-upgrade` only when you explicitly want a complete Arch system update; it may require manual intervention. `paru` handles official repositories through pacman and builds AUR packages locally; review every AUR PKGBUILD and source change before confirming an installation.

## Applying configuration

Chezmoi manages the portable configuration under `home/`. `script/bootstrap plan` shows the selected source and package plan. `script/bootstrap apply` confirms package installation, Chezmoi source adoption, and the pending diff as separate operations. If Chezmoi already uses a different source, use `script/bootstrap adopt-source` explicitly before applying configuration.

The bootstrap only applies configuration from an interactive terminal. It does not offer a non-interactive apply mode because it intentionally does not overwrite home-directory files without a reviewed diff and explicit confirmation.

Global agent skills declared under `home/dot_agents/skills/` are restored to `~/.agents/skills/`. Local skills with different names may coexist in that directory but are not managed or verified by Chezmoi. Make changes to versioned skills in the repository source, run the bootstrap apply flow, and restart OpenCode to reload them.

## Private macOS configuration

After the public bootstrap succeeds, follow [private-macos.md](private-macos.md) to apply work-specific macOS configuration from `private/macos/`.

## Personal values

Before applying the managed `~/.gitconfig`, inspect any existing global identity:

```sh
git config --global --list --show-origin
```

The managed file contains portable defaults and includes the unmanaged `~/.config/git/identity.local`. If it does not already exist, create the default local identity before reviewing the Chezmoi diff:

```sh
install -d -m 700 ~/.config/git
install -m 600 home/dot_config/git/identity.local.example ~/.config/git/identity.local
```

Set your name and email in `identity.local`. This repository supports the default `~/.config/git/` location; it does not support an overridden `XDG_CONFIG_HOME` for Git identity files. The local files are not managed by Chezmoi and must not be committed.

For an identity scoped to a workspace, create `~/.config/git/identities` with mode `0700`, append a conditional include to `identity.local`, and create an unmanaged fragment with mode `0600`:

```sh
install -d -m 700 ~/.config/git/identities
install -m 600 /path/to/company.local ~/.config/git/identities/company.local
```

```ini
[includeIf "gitdir:/absolute/path/to/workspace/"]
    path = ~/.config/git/identities/company.local
```

The standard identity loads first, the matching fragment overrides it, and repository-local configuration overrides both. Workspace paths must be canonical and end in `/`.

OpenPGP signing is opt-in. After a key is configured, verify it before adding `user.signingkey`, `commit.gpgsign`, and `tag.gpgSign` to the applicable local file:

```sh
gpg --list-secret-keys --keyid-format=long
git commit --allow-empty -S -m "Verify signing"
git log --show-signature -1
```

Inspect the effective configuration from a repository with:

```sh
git config --show-origin --show-scope --includes --get-regexp '^(user|commit|tag|gpg)\.'
```
