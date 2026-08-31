function dotfiles_load_keychain_secrets --argument-names secrets_file
  test -r "$secrets_file"; and test (uname) = Darwin; and type -q security; or return 0
  # Existing environment and env.d values take precedence; Keychain fills gaps.
  while read -l secret_name; or test -n "$secret_name"
    if test -z "$secret_name"; or string match -qr '^#' -- "$secret_name"; or set -q $secret_name
      continue
    end
    set -l secret_value (security find-generic-password -a "$USER" -s "$secret_name" -w 2>/dev/null)
    test -n "$secret_value"; and set -gx "$secret_name" "$secret_value"
  end < "$secrets_file"
end
