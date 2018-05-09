#!/usr/bin/env bash

mkdir ~/.npm-global  && \
npm config set prefix '~/.npm-global'  && \
npm -g i http-server  && \
yarn global add npx  && \

sudo chown $USER:users /usr/local/bin/  && \
sudo chown $USER:users /opt && \

curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher && \
fish -c "fisher rafaelrinaldi/pure" && \
fish -c "fisher fisher fzf" && \
fish -c "fisher edc/bass"
