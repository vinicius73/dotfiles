# Installation

## macOS

1. Install Xcode Command Line Tools with `xcode-select --install`.
2. Install Homebrew in its default prefix.
3. Clone this repository.
4. Run `script/bootstrap --apply`.

The script locates an existing Homebrew executable from `PATH`, `/opt/homebrew/bin/brew`, or `/usr/local/bin/brew`. It does not run a remote Homebrew installer.

## Arch Linux

1. Ensure `sudo`, `pacman`, network access, and a fully updated system are available.
2. Install `paru` manually from the AUR after reviewing its PKGBUILD and source files.
3. Clone this repository.
4. Run `script/bootstrap --apply`.

The Arch base install runs `paru -Syu --needed` and may require manual intervention for normal system updates. `paru` handles official repositories through pacman and builds AUR packages locally; review every AUR PKGBUILD and source change before confirming an installation.

## Applying configuration

Chezmoi manages the portable configuration under `home/`. `script/bootstrap --apply` initializes this source, prints the pending diff, and asks once before applying it. Review the diff before confirming.

The bootstrap only applies configuration from an interactive terminal. It does not offer a non-interactive apply mode because it intentionally does not overwrite home-directory files without a reviewed diff and explicit confirmation.

## Personal values

The repository does not manage personal Git identity or secret tokens. Copy the installed Git identity example and edit it locally:

```sh
cp ~/.config/git/identity.local.example ~/.config/git/identity.local
```

The local identity file is not managed by Chezmoi and must not be committed.
