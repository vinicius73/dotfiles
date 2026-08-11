function dotfiles_load_environment
  set -l env_dir "$XDG_CONFIG_HOME"
  if test -z "$env_dir"
    set env_dir "$HOME/.config"
  end
  set env_dir "$env_dir/dotfiles/env.d"

  if not test -e "$env_dir"
    return 0
  end
  if not test -d "$env_dir"; or test -L "$env_dir"; or not dotfiles_environment_secure "$env_dir"
    printf '%s\n' 'dotfiles: refusing insecure environment directory' >&2
    return 0
  end

  for env_file in "$env_dir"/*.env
    if not test -e "$env_file"
      continue
    end
    if not test -f "$env_file"; or test -L "$env_file"; or not dotfiles_environment_secure "$env_file"
      printf 'dotfiles: refusing insecure environment file: %s\n' (path basename "$env_file") >&2
      continue
    end

    set -l valid 1
    while read -l env_line
      if test -z "$env_line"; or string match -qr '^#' -- "$env_line"
        continue
      end
      if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*=[^"`$\\]*$' -- "$env_line"
        set valid 0
        break
      end
    end < "$env_file"

    if test "$valid" -ne 1
      printf 'dotfiles: refusing invalid environment file: %s\n' (path basename "$env_file") >&2
      continue
    end

    while read -l env_line
      if test -z "$env_line"; or string match -qr '^#' -- "$env_line"
        continue
      end
      set -l env_pair (string split -m1 '=' -- "$env_line")
      set -gx "$env_pair[1]" "$env_pair[2]"
    end < "$env_file"
  end
end

function dotfiles_environment_secure --argument-names target
  set -l metadata
  if metadata=(stat -f '%u:%Lp' -- "$target" 2>/dev/null)
  else if metadata=(stat -c '%u:%a' -- "$target" 2>/dev/null)
  else
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
