#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"
. "$repo_root/script/lib/dotfiles.sh"

DOTFILES_REPO_ROOT=$repo_root
export DOTFILES_REPO_ROOT

for platform_profile in \
  macos:base macos:cli macos:desktop macos:docker macos:pokemonsay \
  arch:base arch:cli arch:desktop arch:docker arch:pokemonsay arch:rust; do
  platform=${platform_profile%%:*}
  profile=${platform_profile#*:}
  manifest=$(dotfiles_manifest_path "$profile" "$platform")
  [ -f "$manifest" ] || fail "missing manifest: $manifest"
done

if dotfiles_manifest_path rust macos >/dev/null 2>&1; then
  fail "macOS rust manifest unexpectedly resolved"
fi
