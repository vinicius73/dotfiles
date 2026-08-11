#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

loader="$repo_root/home/dot_config/dotfiles/shell/env.sh"
temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
home="$temporary_dir/home"
env_dir="$home/.config/dotfiles/env.d"
mkdir -p "$env_dir"
chmod 700 "$env_dir"

printf '%s\n' 'SAFE_VALUE=value==' > "$env_dir/valid.env"
chmod 600 "$env_dir/valid.env"
output=$(HOME="$home" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\$SAFE_VALUE\"")
[ "$output" = 'value==' ] || fail "valid environment file was not loaded"

printf '%s\n' 'UNSAFE_VALUE=$(id)' > "$env_dir/invalid.env"
chmod 600 "$env_dir/invalid.env"
output=$(HOME="$home" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\${UNSAFE_VALUE:-missing}\"" 2>&1)
assert_contains "$output" 'refusing invalid environment file: invalid.env'
case "$output" in *'uid='*) fail "invalid environment file executed" ;; esac
rm "$env_dir/invalid.env"

chmod 644 "$env_dir/valid.env"
output=$(HOME="$home" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\${SAFE_VALUE:-missing}\"" 2>&1)
assert_contains "$output" 'refusing insecure environment file: valid.env'
case "$output" in *missing) ;; *) fail "insecure environment file was loaded" ;; esac
