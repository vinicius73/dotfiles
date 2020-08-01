#!/usr/bin/env bash

yay -Sy rustup --noconfirm --needed && \
rustup toolchain stable && \
rustup set profile complete && \
rustup default stable && \
mkdir -p ~/.config/fish/completions && \
rustup completions fish > ~/.config/fish/completions/rustup.fish && \
mkdir -p ~/.local/share/bash-completion/completions/ && \
rustup completions bash > ~/.local/share/bash-completion/completions/rustup