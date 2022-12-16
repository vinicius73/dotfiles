#!/usr/bin/env bash

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
flatpak remotes && \
flatpak update

flatpak install flathub app.resp.RESP --or-update -y && \
flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community --or-update -y && \
flatpak install flathub com.jetpackduba.Gitnuro --or-update -y && \
flatpak install flathub io.dbeaver.DBeaverCommunity --or-update -y && \
flatpak install flathub rest.insomnia.Insomnia --or-update -y && \
flatpak install flathub org.videolan.VLC --or-update -y && \
flatpak install flathub com.heroicgameslauncher.hgl --or-update -y && \
flatpak install flathub org.keepassxc.KeePassXC  --or-update -y


flatpak list
