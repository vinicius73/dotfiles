#!/usr/bin/env bash

mkdir -p ~/.npm-global  && \
npm config set prefix '~/.npm-global'  && \
npm -g i http-server  && \
yarn global add npx  && \

sudo chown $USER:users /usr/local/bin/  && \
sudo chown $USER:users /opt && \

curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher && \
fish -c "fisher add jethrokuan/fzf" && \
fish -c "fisher add edc/bass" && \
fish -c "fisher add franciscolourenco/done" && \
fish -c "fisher add rafaelrinaldi/pure" && \

# https://stackoverflow.com/questions/22475849/node-js-error-enospc/32600959#32600959
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p && \
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.d/99-sysctl.conf && sudo sysctl --system && \

# https://github.com/googlei18n/noto-emoji/issues/36#issuecomment-343655365
sudo cp -f -R -p ./50-noto-color-emoji.conf /etc/fonts/conf.d/50-noto-color-emoji.conf
