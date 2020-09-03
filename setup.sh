#!/usr/bin/env bash

# abort on errors
set -e

_gen_ssh() {
    echo ">> GENERATING SSH KEY <<"
    ssh-keygen -t rsa -b 4096 -C "gbarkeling@gmail.com"
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa
    
    echo "Remember to add public key to Github"
    echo ">> DONE GENERATING SSH KEY <<"
}

_setup_zsh() {
    echo ">> SETTING UP ZSH AND ZINIT <<"
    # install
    sudo apt-get install zsh -y

    # https://github.com/kornicameister/dotfiles
    echo "

    source "$HOME/zsh/path.zsh"
    source "$HOME/zsh/alias.zsh"
    source "$HOME/zsh/zinit.zsh"

    " >> ~/.zshrc
    
    # set zsh as default shell
    sudo chsh -s /bin/zsh gustaf

    # install zinit
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

#     mkdir ~/.zinit
#     git clone https://github.com/zdharma/zinit.git ~/.zinit/bin


    echo ">> DONE SETTING UP ZSH AND ZINIT <<"
}


_setup_cuda() {
    echo ">> SETTING CUDA <<"
    sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    sudo sh -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
    sudo apt-get update
    sudo apt-get install -y cuda-toolkit-11-0
    echo ">> DONE SETTING CUDA <<"
}

_update_wsl() {
    echo ">> UPDATING WSL <<"
    uname -r
    wsl.exe --update
    echo ">> DONE UPDATING WSL <<"
}

_pre_install() {
    echo ">> RUNNING PRE INSTALL <<"
    sudo apt-get update
    sudo apt-get upgrade -y
    echo ">> DONE RUNNING PRE INSTALL <<"
}

_pre_install
_update_wsl
_gen_ssh
_setup_cuda
_setup_zsh


# load zsh
zsh
