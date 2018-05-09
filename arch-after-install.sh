mkdir ~/.npm-global  && \
npm config set prefix '~/.npm-global'  && \
npm -g i http-server  && \
yarn global add eslint  && \

sudo chown $USER:users /usr/local/bin/  && \
sudo chown $USER:users /opt
