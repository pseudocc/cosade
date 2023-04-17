#!/bin/bash

if ! [ -f /etc/sudoers.d/nopwd ]; then
    sudo mkdir -p /etc/sudoers.d
    sudo tee /etc/sudoers.d/nopwd <<- EOF
	%sudo ALL=(ALL:ALL) NOPASSWD: ALL
	EOF
    sudo chmod 0440 /etc/sudoers.d/nopwd
fi

if ! apt show xkb-rpd &> /dev/null; then
    wget https://github.com/pseudocc/real-prog-dvorak/releases/download/stable/xkb-rpd.deb \
        && sudo dpkg -i xkb-rpd.deb
    rm -f xkb-rpd.deb
fi

if ! command -v git &> /dev/null; then
    sudo apt install git -y
fi

if ! command -v rg &> /dev/null; then
    sudo apt install ripgrep -y
fi

if ! command -v npm &> /dev/null; then
    sudo apt install npm -y
    sudo npm install -g n
    sudo n lts
    sudo npm install -g npm@latest
fi

if ! command -v sshd &> /dev/null; then
    sudo apt install openssh-server -y
fi

if ! command -v gcc &> /dev/null; then
    sudo apt install gcc -y
fi

if ! command -v rustup &> /dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

if ! command -v nvim &> /dev/null; then
    # extract nvim under ~/softwares/
    if ! [ -d ~/softwares/ ]; then
        mkdir -p ~/softwares/
    fi
    pushd ~/softwares/ || exit
    wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
    chmod u+x nvim.appimage
    ./nvim.appimage --appimage-extract
    rm -f nvim.appimage
    mv squashfs-root nvim
    ln -s ~/softwares/nvim/AppRun ~/.local/bin/nvim
    popd || exit
fi

mkdir -p ~/projects/lp
mkdir -p ~/projects/github

if
    ! [ -d ~/projects/github/dotfiles ] \
    && ! [ -d ~/projects/github/dotfiles.git ];
then
    git clone \
        --recurse-submodules \
        --shallow-submodules \
        -j8 https://github.com/pseudocc/dotfiles.git ~/projects/github/dotfiles

    bash ~/projects/github/dotfiles/bootstrap.sh
fi

source ~/.bashrc

if ! command -v deno &> /dev/null; then
    cargo install deno --locked
fi

if ! command -v tree-sitter &> /dev/null; then
    cargo install tree-sitter-cli
fi
