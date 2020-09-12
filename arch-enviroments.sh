#!/usr/bin/env bash

# fish
mkdir -p ~/.config/fish && \
ln -s ~/dotfiles/config/fish/config.fish ~/.config/fish/config.fish

# terminator
rm -rf ~/.config/terminator && \
ln -s ~/dotfiles/config/terminator/ ~/.config/terminator

# gitmoji-cli-nodejs
rm -rf ~/.config/gitmoji-cli-nodejs && \
ln -s ~/dotfiles/config/gitmoji-cli-nodejs/ ~/.config/gitmoji-cli-nodejs

# bash
mv ~/.bashrc ~/.bashrc_original && \
ln -s ~/dotfiles/bash/.bashrc ~/.bashrc

# sublime
# rm -rf ~/.config/sublime-text-3/Packages/User && \
# ln -s ~/dotfiles/config/sublime/Packages/User/ ~/.config/sublime-text-3/Packages/User

# git
mv ~/.gitconfig ~/.gitconfig_original && \
ln -s ~/dotfiles/config/.gitconfig ~/.gitconfig

# anothers
mkdir -p ~/bin
