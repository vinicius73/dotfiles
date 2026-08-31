#!/bin/sh

profile_pokemonsay_plan() {
  profile_packages_plan pokemonsay
  pokemonsay_plan
  pokemonsay_preflight
}

profile_pokemonsay_apply() {
  profile_packages_apply pokemonsay
  pokemonsay_apply
}

profile_rust_plan() {
  profile_packages_plan rust
  printf '%s\n' "Installs the stable Rust toolchain and rustfmt, clippy, rust-src."
}

profile_rust_apply() {
  profile_packages_apply rust
  dotfiles_require_command rustup
  rustup default stable
  rustup component add rustfmt clippy rust-src
}
