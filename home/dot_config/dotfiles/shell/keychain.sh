dotfiles_load_keychain_secrets() {
  [ -r "$dotfiles_secrets_file" ] || return 0
  [ "$(uname -s)" = Darwin ] || return 0
  command -v security >/dev/null 2>&1 || return 0
  while IFS= read -r dotfiles_secret_name || [ -n "$dotfiles_secret_name" ]; do
    case "$dotfiles_secret_name" in ''|'#'*) continue ;; esac
    printenv "$dotfiles_secret_name" >/dev/null 2>&1 && continue
    dotfiles_secret_value=$(security find-generic-password -a "$USER" -s "$dotfiles_secret_name" -w 2>/dev/null) || continue
    [ -n "$dotfiles_secret_value" ] && export "$dotfiles_secret_name=$dotfiles_secret_value"
  done < "$dotfiles_secrets_file"
}
