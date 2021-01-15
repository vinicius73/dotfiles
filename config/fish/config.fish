source ~/dotfiles/config/fish/commands.fish
source ~/dotfiles/config/fish/env.fish

set welcomeFile "$HOME/dotfiles/bash/welcome.sh"

function fish_greeting
  cal -3
  bash $welcomeFile
end