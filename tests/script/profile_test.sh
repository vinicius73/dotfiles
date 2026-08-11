#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

output=$("$repo_root/script/profile" list)
assert_contains "$output" "pokemonsay"

if "$repo_root/script/profile" plan rust >/dev/null 2>&1; then
  fail "rust plan unexpectedly succeeded on macOS"
else
  [ "$?" -eq 1 ] || fail "rust plan returned an unexpected status"
fi
