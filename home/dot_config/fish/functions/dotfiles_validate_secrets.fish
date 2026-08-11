function dotfiles_validate_secrets --argument-names secrets_file
  test -e "$secrets_file"; or return 0
  if not test -f "$secrets_file"; or test -L "$secrets_file"; or not dotfiles_environment_secure "$secrets_file"
    printf '%s\n' 'dotfiles: refusing insecure secrets declaration' >&2
    return 1
  end
  while read -l secret_name; or test -n "$secret_name"
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
