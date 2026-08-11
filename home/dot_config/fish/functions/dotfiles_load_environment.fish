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
  dotfiles_validate_secrets "$secrets_file"; or return 0

  if test -d "$env_dir"; and not test -L "$env_dir"; and dotfiles_environment_secure "$env_dir"
    for env_file in "$env_dir"/*.env
      test -e "$env_file"; or continue
      dotfiles_load_environment_file "$secrets_file" "$env_file"
    end
  else if test -e "$env_dir"
    printf '%s\n' 'dotfiles: refusing insecure environment directory' >&2
  end
  dotfiles_load_keychain_secrets "$secrets_file"
end
