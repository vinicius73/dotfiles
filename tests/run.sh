#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)

for test_file in "$repo_root"/tests/script/*_test.sh "$repo_root"/tests/maintenance/*_test.sh; do
  [ -f "$test_file" ] || continue
  printf '%s\n' "RUN $(basename "$test_file")"
  sh "$test_file"
done
