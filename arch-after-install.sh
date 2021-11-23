#!/usr/bin/env bash

mkdir -p ~/.npm-global  && \
npm config set prefix '~/.npm-global'  && \
npm -g i http-server  && \
yarn global add npx  && \

sudo chown $USER:users /usr/local/bin/  && \
sudo chown $USER:users /opt && \

# https://stackoverflow.com/questions/22475849/node-js-error-enospc/32600959#32600959
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p && \
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.d/99-sysctl.conf && sudo sysctl --system
