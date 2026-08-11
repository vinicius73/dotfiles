# Profiles

Profiles are intentionally applied one at a time.

## cli

Installs curated command-line tools. It does not affect shell ownership or language runtimes.

## desktop

Installs curated graphical applications. On Arch, paru installs the official-repository manifest and the separate AUR manifest. Review AUR PKGBUILDs and source changes before confirming the installation.

## docker

Installs Docker tooling. On macOS, Docker Desktop must be started and configured manually. On Arch, enabling the daemon and adding a user to the Docker group are manual because they change system and privilege state.

## rust

Available only on Arch. paru installs `rustup`; rustup configures the stable toolchain and `rustfmt`, `clippy`, and `rust-src` components. The profile never runs `rustup self update`.

## shell

Changes the login shell to Fish only after interactive confirmation. It will never run in non-interactive automation.
