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

## Private macOS configuration

After the public bootstrap succeeds, follow [private-macos.md](private-macos.md) to apply work-specific macOS configuration from `private/macos/`.

## Personal values

The repository does not manage personal Git identity or secret tokens. Copy the installed Git identity example and edit it locally:

```sh
cp ~/.config/git/identity.local.example ~/.config/git/identity.local
```

The local identity file is not managed by Chezmoi and must not be committed.
