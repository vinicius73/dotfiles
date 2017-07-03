ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish && \
rm -rf ~/.config/terminator && \
ln -s ~/dotfiles/terminator/ ~/.config/terminator && \
mv ~/.bashrc ~/.bashrc_original && \
ln -s ~/dotfiles/bash/.bashrc ~/.bashrc && \
bash arch-enviroment-setup.sh