#!/bin/sh

set -eu

fail() {
  printf '%s\n' "FAIL: $1" >&2
  exit 1
}

assert_contains() {
  case "$1" in *"$2"*) ;; *) fail "expected output to contain: $2" ;; esac
}

assert_file_exists() {
  [ -e "$1" ] || fail "expected file to exist: $1"
}
