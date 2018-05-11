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

# anothers
mkdir -p ~/bin
