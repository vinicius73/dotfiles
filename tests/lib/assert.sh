#!/bin/sh

set -eu

fail() {
  printf '%s\n' "FAIL: $1" >&2
  exit 1
}

assert_contains() {
  case "$1" in *"$2"*) ;; *) fail "expected output to contain: $2" ;; esac
}

assert_not_contains() {
  case "$1" in *"$2"*) fail "expected output not to contain: $2" ;; esac
}

assert_equals() {
  [ "$1" = "$2" ] || fail "expected '$2', got '$1'"
}

assert_exit_status() {
  [ "$1" -eq "$2" ] || fail "expected exit status $2, got $1"
}

assert_file_exists() {
  [ -e "$1" ] || fail "expected file to exist: $1"
}

assert_path_absent() {
  [ ! -e "$1" ] || fail "expected path to be absent: $1"
}
