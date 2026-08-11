#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/root" "$temporary_dir/bin"
ln -s "$temporary_dir/root" "$temporary_dir/root-link"
printf '#!/bin/sh\nexit 0\n' > "$temporary_dir/bin/cargo"
chmod 755 "$temporary_dir/bin/cargo"
PATH="$temporary_dir/bin:$PATH"
export PATH

run_command() {
  set +e
  output=$("$@" </dev/null 2>&1)
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

for command in clean-node-artifacts clean-go-artifacts clean-rust-artifacts audit-js-vulnerabilities; do
  case "$command" in
    audit-js-vulnerabilities) mode=fix ;;
    *) mode=apply ;;
  esac

  run_command "$repo_root/maintenance/$command" "$mode" --root "$temporary_dir/root"
  assert_exit_status "$status" 1
  assert_contains "$output" "requires an interactive terminal."
done
