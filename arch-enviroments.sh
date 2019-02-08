#!/usr/bin/env bash

# fish
mkdir -p ~/.config/fish && \
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish

# terminator
rm -rf ~/.config/terminator && \
ln -s ~/dotfiles/terminator/ ~/.config/terminator

# bash
mv ~/.bashrc ~/.bashrc_original && \
ln -s ~/dotfiles/bash/.bashrc ~/.bashrc

# sublime
rm -rf ~/.config/sublime-text-3/Packages/User && \
ln -s ~/dotfiles/sublime/Packages/User/ ~/.config/sublime-text-3/Packages/User

# git
git config --global alias.vlog 'log --graph --date-order --date=relative --pretty=format:"%C(white)%h: %Cgreen - %an - %Cred %C(cyan)%ar:%Creset%n%s%n" --color'

# anothers
mkdir -p ~/bin
