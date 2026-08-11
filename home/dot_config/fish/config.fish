if status is-interactive
  if not contains -- "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
  end

  dotfiles_load_environment
  dotfiles_configure_shell

  if not set -q MISE_SHELL; and type -q mise
    mise activate fish | source
  end

  if type -q eza
    alias ll "eza -l -g --icons --octal-permissions --no-permissions --no-user -s type --time-style long-iso"
    alias la "eza -l -g --icons --octal-permissions --no-permissions --no-user -s type --time-style long-iso -a"
    alias lla "ll -a"
  end

  if functions -q sponge_filter_matched
    set -g sponge_filters sponge_filter_matched
    set -g sponge_regex_patterns '(?i)(api[_-]?key|authorization|password|secret|token)=[^[:space:]]+'
  end

  dotfiles_greeting
end
