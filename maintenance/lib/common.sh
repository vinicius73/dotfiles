#!/bin/sh

maintenance_validate_root() {
  root=$1

  case "$root" in
    /*) ;;
    *) printf '%s\n' "Root must be an absolute path." >&2; return 2 ;;
  esac

  # Cleanup roots must be real directories so path traversal cannot escape validation.
  [ -d "$root" ] && [ ! -L "$root" ] || {
    printf '%s\n' "Root must be a physical directory." >&2
    return 1
  }

  root=$(CDPATH='' cd -- "$root" && pwd -P) || return 1
  case "$root" in
    /|"$HOME") printf '%s\n' "Refusing unsafe root: $root" >&2; return 1 ;;
  esac

  printf '%s\n' "$root"
}

maintenance_confirm_apply() {
  prompt=$1
  action=${2:-Apply}

  [ -t 0 ] && [ -t 1 ] || {
    printf '%s\n' "$action requires an interactive terminal." >&2
    return 1
  }

  printf '%s' "$prompt"
  IFS= read -r answer < /dev/tty || return 1
  [ "$answer" = APPLY ] || {
    printf '%s\n' "Operation cancelled." >&2
    return 1
  }
}

maintenance_run_targets() {
  targets=$1
  shift

  status=0
  while IFS= read -r target; do
    [ -n "$target" ] || continue
    "$@" "$target" || status=1
  done <<EOF
$targets
EOF

  return "$status"
}
