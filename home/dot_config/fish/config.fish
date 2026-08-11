if not set -q MISE_SHELL; and type -q mise
  mise activate fish | source
end

if type -q go-task
  alias task="go-task"
end

if type -q eza
  alias ll "eza -l -g --icons --octal-permissions --no-permissions --no-user -s type --time-style long-iso"
  alias la "eza -l -g --icons --octal-permissions --no-permissions --no-user -s type --time-style long-iso -a"
  alias lla "ll -a"
end

dotfiles_greeting
