#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/root"
ln -s "$temporary_dir/root" "$temporary_dir/root-link"

run_command() {
  set +e
  output=$("$@" 2>&1)
  status=$?
  set -e
}

for command in clean-node-artifacts clean-go-artifacts clean-rust-artifacts audit-js-vulnerabilities; do
  case "$command" in
    audit-js-vulnerabilities) mode=audit ;;
    *) mode=plan ;;
  esac

  run_command "$repo_root/maintenance/$command" "$mode" --root relative
  assert_exit_status "$status" 2
  assert_contains "$output" "Root must be an absolute path."

  run_command "$repo_root/maintenance/$command" "$mode" --root /
  assert_exit_status "$status" 1
  assert_contains "$output" "Refusing unsafe root: /"

  run_command "$repo_root/maintenance/$command" "$mode" --root "$HOME"
  assert_exit_status "$status" 1
  assert_contains "$output" "Refusing unsafe root: $HOME"

  run_command "$repo_root/maintenance/$command" "$mode" --root "$temporary_dir/root-link"
  assert_exit_status "$status" 1
  assert_contains "$output" "Root must be a physical directory."
done
