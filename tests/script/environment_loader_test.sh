#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

loader="$repo_root/home/dot_config/dotfiles/shell/env.sh"
shell_dir="$repo_root/home/dot_config/dotfiles/shell"
temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
home="$temporary_dir/home"
config_dir="$home/.config/dotfiles"
env_dir="$config_dir/env.d"
mkdir -p "$env_dir" "$temporary_dir/bin"
chmod 700 "$config_dir" "$env_dir"
printf '%s\n' 'SAFE_VALUE' 'KEYCHAIN_VALUE' 'ATOMIC_VALUE' > "$config_dir/secrets.conf"
chmod 600 "$config_dir/secrets.conf"
printf '%s\n' 'SAFE_VALUE=value==' > "$env_dir/valid.env"
chmod 600 "$env_dir/valid.env"
printf '%s\n' '#!/bin/sh' 'printf Darwin' > "$temporary_dir/bin/uname"
printf '%s\n' '#!/bin/sh' 'if [ "$5" = KEYCHAIN_VALUE ]; then printf keychain-value; fi' > "$temporary_dir/bin/security"
chmod 755 "$temporary_dir/bin/uname" "$temporary_dir/bin/security"
mkdir -p "$config_dir/shell"
cp "$shell_dir"/*.sh "$config_dir/shell"

output=$(HOME="$home" USER=tester PATH="$temporary_dir/bin:$PATH" sh -c ". '$loader'; dotfiles_load_environment; printf '%s:%s' \"\$SAFE_VALUE\" \"\$KEYCHAIN_VALUE\"")
[ "$output" = 'value==:keychain-value' ] || fail "declared secrets were not loaded"

printf '%s\n' 'UNDECLARED_VALUE=value' > "$env_dir/invalid.env"
chmod 600 "$env_dir/invalid.env"
output=$(HOME="$home" USER=tester PATH="$temporary_dir/bin:$PATH" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\${UNDECLARED_VALUE:-missing}\"" 2>&1)
assert_contains "$output" 'refusing invalid environment file: invalid.env'
case "$output" in *missing) ;; *) fail "undeclared environment value was loaded" ;; esac
rm "$env_dir/invalid.env"

printf '%s\n' 'ATOMIC_VALUE=should-not-export' 'UNDECLARED_VALUE=value' > "$env_dir/invalid.env"
chmod 600 "$env_dir/invalid.env"
output=$(HOME="$home" USER=tester PATH="$temporary_dir/bin:$PATH" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\${ATOMIC_VALUE:-missing}\"" 2>&1)
assert_contains "$output" 'refusing invalid environment file: invalid.env'
case "$output" in *missing) ;; *) fail "invalid environment file was partially loaded" ;; esac
rm "$env_dir/invalid.env"

printf '%s\n' 'UNSAFE_VALUE=$(id)' > "$env_dir/invalid.env"
chmod 600 "$env_dir/invalid.env"
output=$(HOME="$home" USER=tester PATH="$temporary_dir/bin:$PATH" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\${UNSAFE_VALUE:-missing}\"" 2>&1)
assert_contains "$output" 'refusing invalid environment file: invalid.env'
case "$output" in *'uid='*) fail "invalid environment file executed" ;; esac
rm "$env_dir/invalid.env"

chmod 644 "$config_dir/secrets.conf"
output=$(HOME="$home" USER=tester PATH="$temporary_dir/bin:$PATH" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\${SAFE_VALUE:-missing}\"" 2>&1)
assert_contains "$output" 'refusing insecure secrets declaration'
case "$output" in *missing) ;; *) fail "insecure secrets declaration was loaded" ;; esac

chmod 600 "$config_dir/secrets.conf"
output=$(HOME="$home" USER=tester KEYCHAIN_VALUE=existing-value PATH="$temporary_dir/bin:$PATH" sh -c ". '$loader'; dotfiles_load_environment; printf '%s' \"\$KEYCHAIN_VALUE\"")
[ "$output" = 'existing-value' ] || fail "existing environment value did not take precedence over Keychain"

output=$(HOME="$home" USER=tester PATH="$temporary_dir/bin:$PATH" fish --no-config -c "source '$repo_root/home/dot_config/fish/functions/dotfiles_load_environment.fish'; dotfiles_load_environment; printf '%s:%s' \$SAFE_VALUE \$KEYCHAIN_VALUE")
[ "$output" = 'value==:keychain-value' ] || fail "Fish did not load declared secrets"
