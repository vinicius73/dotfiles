#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/project/node_modules"
: > "$temporary_dir/project/package.json"
output=$("$repo_root/maintenance/clean-node-artifacts" plan --root "$temporary_dir")
assert_contains "$output" "node_modules"
assert_file_exists "$temporary_dir/project/node_modules"
