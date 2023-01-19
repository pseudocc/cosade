#!/bin/bash

if ! [ -f /etc/sudoers.d/nopwd ]; then
    sudo mkdir -p /etc/sudoers.d
    sudo tee /etc/sudoers.d/nopwd <<- EOF
	%sudo ALL=(ALL:ALL) NOPASSWD: ALL
	EOF
    sudo chmod 0440 /etc/sudoers.d/nopwd
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

if ! command -v deno &> /dev/null; then
    curl -fsSL https://deno.land/x/install/install.sh | sh
fi

mkdir -p ~/projects/lp
mkdir -p ~/projects/github

if ! [ -d ~/projects/github/dotfiles ]; then
    git clone \
        --recurse-submodules \
        --shallow-submodules \
        -j8 https://github.com/pseudocc/dotfiles.git ~/projects/github/dotfiles

    source ~/projects/github/dotfiles/bootstrap.sh
fi

