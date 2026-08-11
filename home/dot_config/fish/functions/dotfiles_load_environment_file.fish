function dotfiles_load_environment_file --argument-names secrets_file env_file
  if not test -f "$env_file"; or test -L "$env_file"; or not dotfiles_environment_secure "$env_file"
    printf 'dotfiles: refusing insecure environment file: %s\n' (path basename "$env_file") >&2
    return 0
  end

  set -l valid 1
  while read -l env_line; or test -n "$env_line"
    if test -z "$env_line"; or string match -qr '^#' -- "$env_line"
      continue
    end
    if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*=' -- "$env_line"; or string match -qr '["`$\\\\]' -- "$env_line"
      set valid 0
      break
    end
    set -l name (string split -m1 '=' -- "$env_line")[1]
    dotfiles_secret_is_declared "$secrets_file" "$name"; or begin
      set valid 0
      break
    end
  end < "$env_file"
  if test "$valid" -ne 1
    printf 'dotfiles: refusing invalid environment file: %s\n' (path basename "$env_file") >&2
    return 0
  end

  while read -l env_line; or test -n "$env_line"
    if test -z "$env_line"; or string match -qr '^#' -- "$env_line"
      continue
    end
    set -l pair (string split -m1 '=' -- "$env_line")
    set -gx "$pair[1]" "$pair[2]"
  end < "$env_file"
end
