# Profiles

Profiles are intentionally planned and applied one at a time. Use `script/profile plan <profile>` to inspect package, network, privilege, and managed-path effects before `script/profile apply <profile>`.

## cli

Installs curated command-line tools, including `bat`, `eza`, `fd`, `fzf`, `ghq`, and `git-extras` on both platforms. It does not affect shell ownership or language runtimes.

## desktop

Installs curated graphical applications. On Arch, paru installs the official-repository manifest and the separate AUR manifest. Review AUR PKGBUILDs and source changes before confirming the installation.

## docker

Installs Docker tooling. On macOS, Docker Desktop must be started and configured manually. On Arch, enabling the daemon and adding a user to the Docker group are manual because they change system and privilege state.

## pokemonsay

Installs `cowsay` from Homebrew or Arch's official repositories, then clones [`HRKings/pokemonsay-newgenerations`](https://github.com/HRKings/pokemonsay-newgenerations) at commit `f8a24a05dd3330fac2a75fdbaf19f72948cedfb3` into `${XDG_DATA_HOME:-~/.local/share}/dotfiles/pokemonsay`. It verifies the checked-out commit, keeps the upstream checkout intact, adds a repository-owned wrapper named `dotfiles-pokemonsay`, and creates a managed launcher at `${XDG_BIN_HOME:-~/.local/bin}/pokemonsay`.

The profile never executes the upstream installer, uses `sudo`, or updates from an upstream branch. Reapplying it refuses to replace unmanaged, unexpected-source, or locally modified data and refuses unmanaged launchers. The upstream commit is immutable but unsigned; review it and its artwork provenance before changing the pin.

The Fish greeting remains disabled by default. To enable it in a trusted local terminal session, run `set -gx DOTFILES_GREETING 1`. `DOTFILES_GREETING_DISABLE=1`, `AGENT`, CI, SSH, VS Code, Claude Code, or OpenCode markers, non-TTY shells, and nested Fish shells suppress it. It is a convenience filter, not proof that a session is human.

## rust

Available only on Arch. paru installs `rustup`; rustup configures the stable toolchain and `rustfmt`, `clippy`, and `rust-src` components. The profile never runs `rustup self update`.

## shell

Changes the login shell to Fish only after interactive confirmation. It will never run in non-interactive automation.

## shell-plugins

Installs the pinned Fish and Zsh plugin declarations after interactive confirmation. Fish uses the vendored Fisher function and the managed `fish_plugins` file. Zsh uses Antidote from Homebrew on macOS and the separately confirmed `zsh-antidote` AUR package on Arch; it generates a static loader at `${XDG_CACHE_HOME:-~/.cache}/dotfiles/zsh/plugins.zsh`.

Shell startup only sources installed plugin files and the generated Zsh loader; it never fetches or updates plugins. To add, remove, or update a plugin, edit its managed declaration, run `script/bootstrap apply` to synchronize it, review `script/profile plan shell-plugins`, then run `script/profile apply shell-plugins` and `script/verify`. Pins use complete commit SHAs and prevent automatic revision changes, but do not verify upstream signatures or sandbox third-party code.
