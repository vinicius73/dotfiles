function dotfiles_load_environment
  set -l config_home "$XDG_CONFIG_HOME"
  if test -z "$config_home"
    set config_home "$HOME/.config"
  end
  set -l config_dir "$config_home/dotfiles"
  set -l secrets_file "$config_dir/secrets.conf"
  set -l env_dir "$config_dir/env.d"

  if not test -e "$config_dir"
    return 0
  end
  if not test -d "$config_dir"; or test -L "$config_dir"; or not dotfiles_environment_secure "$config_dir"
    printf '%s\n' 'dotfiles: refusing insecure dotfiles configuration directory' >&2
    return 0
  end
  if not dotfiles_validate_secrets "$secrets_file"
    return 0
  end

  if test -d "$env_dir"; and not test -L "$env_dir"; and dotfiles_environment_secure "$env_dir"
    for env_file in "$env_dir"/*.env
      test -e "$env_file"; or continue
      if not test -f "$env_file"; or test -L "$env_file"; or not dotfiles_environment_secure "$env_file"
        printf 'dotfiles: refusing insecure environment file: %s\n' (path basename "$env_file") >&2
        continue
      end
      set -l valid 1
      while read -l env_line
        if test -z "$env_line"; or string match -qr '^#' -- "$env_line"
          continue
        end
        if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*=' -- "$env_line"; or string match -qr '["`$\\\\]' -- "$env_line"
          set valid 0; break
        end
        set -l name (string split -m1 '=' -- "$env_line")[1]
        dotfiles_secret_is_declared "$secrets_file" "$name"; or begin; set valid 0; break; end
      end < "$env_file"
      if test "$valid" -ne 1
        printf 'dotfiles: refusing invalid environment file: %s\n' (path basename "$env_file") >&2
        continue
      end
      while read -l env_line
        if test -z "$env_line"; or string match -qr '^#' -- "$env_line"
          continue
        end
        set -l pair (string split -m1 '=' -- "$env_line")
        set -gx "$pair[1]" "$pair[2]"
      end < "$env_file"
    end
  else if test -e "$env_dir"
    printf '%s\n' 'dotfiles: refusing insecure environment directory' >&2
  end
  dotfiles_load_keychain_secrets "$secrets_file"
end

function dotfiles_validate_secrets --argument-names secrets_file
  test -e "$secrets_file"; or return 0
  if not test -f "$secrets_file"; or test -L "$secrets_file"; or not dotfiles_environment_secure "$secrets_file"
    printf '%s\n' 'dotfiles: refusing insecure secrets declaration' >&2
    return 1
  end
  while read -l secret_name
    if test -z "$secret_name"; or string match -qr '^#' -- "$secret_name"
      continue
    end
    if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- "$secret_name"
      printf '%s\n' 'dotfiles: refusing invalid secrets declaration' >&2
      return 1
    end
  end < "$secrets_file"
end

function dotfiles_secret_is_declared --argument-names secrets_file name
  test -r "$secrets_file"; or return 1
  string match --quiet --entire -- "$name" < "$secrets_file"
end

function dotfiles_load_keychain_secrets --argument-names secrets_file
  test -r "$secrets_file"; and test (uname) = Darwin; and type -q security; or return 0
  while read -l secret_name
    if test -z "$secret_name"; or string match -qr '^#' -- "$secret_name"; or set -q $secret_name
      continue
    end
    set -l secret_value (security find-generic-password -a "$USER" -s "$secret_name" -w 2>/dev/null)
    test -n "$secret_value"; and set -gx "$secret_name" "$secret_value"
  end < "$secrets_file"
end

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
