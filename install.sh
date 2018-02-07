bash arch-enviroment-setup.sh && \
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish && \
rm -rf ~/.config/terminator && \
ln -s ~/dotfiles/terminator/ ~/.config/terminator && \
mv ~/.bashrc ~/.bashrc_original && \
ln -s ~/dotfiles/bash/.bashrc ~/.bashrc && \
mkdir ~/bin && \
bash install-pokemonsay.sh
