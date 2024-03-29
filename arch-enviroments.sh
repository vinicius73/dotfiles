#!/usr/bin/env bash

# fish
mkdir -p ~/.config/fish && \
ln -s ~/dotfiles/config/fish/config.fish ~/.config/fish/config.fish

# terminator
rm -rf ~/.config/terminator && \
ln -s ~/dotfiles/config/terminator/ ~/.config/terminator

# alacritty
rm -rf ~/.config/alacritty && \
ln -s ~/dotfiles/config/alacritty/ ~/.config/alacritty

# gitmoji-nodejs
rm -rf ~/.config/gitmoji-nodejs && \
ln -s ~/dotfiles/config/gitmoji-nodejs/ ~/.config/gitmoji-nodejs

# bash
mv ~/.bashrc ~/.bashrc_original && \
ln -s ~/dotfiles/bash/.bashrc ~/.bashrc

# sublime
# rm -rf ~/.config/sublime-text-3/Packages/User && \
# ln -s ~/dotfiles/config/sublime/Packages/User/ ~/.config/sublime-text-3/Packages/User

# git
mv ~/.gitconfig ~/.gitconfig_original && \
ln -s ~/dotfiles/config/.gitconfig ~/.gitconfig

if [ -f '~/.terraformrc' ]; then mv ~/.terraformrc ~/.terraformrc_original; fi
ln -s ~/dotfiles/config/.terraformrc ~/.terraformrc

# anothers
mkdir -p ~/bin
