FROM archlinux:latest

RUN sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf \
 && pacman -Syu --noconfirm --needed \
    bash \
    chezmoi \
    diffutils \
     fish \
    git \
    mise \
    ruby \
    shellcheck \
    zsh

WORKDIR /workspace

COPY validate.sh /usr/local/bin/dotfiles-validate
RUN chmod 755 /usr/local/bin/dotfiles-validate

ENTRYPOINT ["/usr/local/bin/dotfiles-validate"]
