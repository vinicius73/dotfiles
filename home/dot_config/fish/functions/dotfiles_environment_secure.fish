function dotfiles_environment_secure --argument-names target
  set -l metadata (stat -f '%u:%Lp' -- "$target" 2>/dev/null)
  if test $status -ne 0
    set metadata (stat -c '%u:%a' -- "$target" 2>/dev/null)
  end
  if test $status -ne 0
    return 1
  end
  set -l pair (string split -m1 ':' -- "$metadata")
  test "$pair[1]" = (id -u); or return 1
  if test -d "$target"
    test "$pair[2]" = 700
  else
    test "$pair[2]" = 600
  end
end
