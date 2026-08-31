#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/project/target"
: > "$temporary_dir/project/Cargo.toml"
output=$("$repo_root/maintenance/clean-rust-artifacts" plan --root "$temporary_dir")
assert_contains "$output" "$temporary_dir/project/Cargo.toml"
assert_file_exists "$temporary_dir/project/target"
