#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/bin"
printf '#!/bin/sh\ncase "$1" in -s) printf "Darwin\\n" ;; -m) printf "arm64\\n" ;; esac\n' > "$temporary_dir/bin/uname"
chmod 755 "$temporary_dir/bin/uname"

output=$(PATH="$temporary_dir/bin:$PATH" "$repo_root/script/profile" list)
assert_contains "$output" "pokemonsay"

output=$(PATH="$temporary_dir/bin:$PATH" "$repo_root/script/profile" plan shell-plugins)
assert_contains "$output" "Generated Zsh loader"

if PATH="$temporary_dir/bin:$PATH" "$repo_root/script/profile" plan rust >/dev/null 2>&1; then
  fail "rust plan unexpectedly succeeded on macOS"
else
  [ "$?" -eq 1 ] || fail "rust plan returned an unexpected status"
fi
