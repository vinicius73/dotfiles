set -gx DOTFILES $HOME/dotfiles
set -gx PATH ~/.npm-global/bin ~/.config/yarn/global/node_modules/.bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/projects/go/bin $PATH

set -gx GOPATH ~/projects/go
set -gx ANSIBLE_NOCOWS 1

set -gx ANDROID_HOME /opt/android-sdk/
set -gx JAVA_HOME /usr/lib/jvm/default

if test -d ~/.rvm/bin
  set -gx PATH ~/.rvm/bin $PATH
  source ~/dotfiles/config/fish/rvm.fish
  rvm default
end

if test -d /opt/android-sdk
  set -gx PATH /opt/android-sdk/build-tools/30.0.0/ $PATH
  set -gx PATH /opt/android-sdk/platform-tools /opt/android-sdk/build-tools/30.0.0/ /opt/android-sdk/tools $PATH
end

if test -d ~/.deno
  set -gx DENO_INSTALL ~/.deno
  set -gx PATH ~/.deno/bin $PATH
end

if test -d $HOME/.local/share/pnpm
  set -gx PNPM_HOME ~/.local/share/pnpm
  set -gx PATH $PNPM_HOME $PATH
end

set -gx SPACEFISH_DIR_TRUNC 0

if test -f ~/bin/navi
  source (navi widget fish)
end

if test -d $DOTFILES/google-cloud-sdk
  source $DOTFILES/google-cloud-sdk/path.fish.inc
end

if test -f $DOTFILES/bash/envs.bash
  source $DOTFILES/bash/envs.bash
end

if test -f /usr/share/doc/git-extras/git-extras.fish
  source /usr/share/doc/git-extras/git-extras.fish
end
