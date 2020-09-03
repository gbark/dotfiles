#!/usr/bin/env bash

WSL_EXEC="wsl.exe"

_configure_git() {
    if [ ! -f "${HOME}/.gitconfig.local" ]; then
        if [ -z "${GIT_USERNAME}" ]; then
            echo "GIT_USERNAME must be set"
            exit 2
        fi
        if [ -z "${GIT_PASSWORD}" ]; then
            echo "GIT_PASSWORD must be set"
            exit 2
        fi
        if [ -z "${GIT_EMAIL}" ]; then
            echo "GIT_EMAIL must be set"
            exit 2
        fi
        if [ -z "${GPG_FULL_NAME}" ]; then
            echo "GPG_FULL_NAME must be set"
            exit 2
        fi
        if [ -z "${GPG_PASSPHRASE}" ]; then
            echo "GPG_PASSPHRASE must be set"
            exit 2
        fi

        # generate ssh key
        mkdir -p "${HOME}/.ssh"
        ssh-keygen \
            -t ed25519 \
            -b 4096 \
            -C "${GIT_EMAIL}" \
            -f "${HOME}/.ssh/github" \
            -N "${GIT_PASSWORD}"

        key_type="rsa"
        key_strength=4096
        key_config=$(mktemp)

        # generating GPK key to sign the commits
        cat >>"${key_config}" <<EOF
Key-Type: ${key_type}
Key-Length: ${key_strength}
Name-Real: ${GPG_FULL_NAME}
Name-Comment: ${GIT_USERNAME} GPG key generated with dotfiles
Name-Email: ${GIT_EMAIL}
Expire-Date: 0
Passphrase: ${GPG_PASSPHRASE}
EOF
        gpg2 --quiet --batch --expert --full-gen-key "${key_config}"
        rm -rf "${key_config}"

        # assumed the highest rsa length:
        local signingKey=""
        signingKey=$(gpg2 --list-secret-keys --keyid-format LONG | grep -B 2 "${GIT_EMAIL}" | grep sec | awk -F"[/ ]+" '{print $3}')

        touch "${HOME}/.gitconfig.local"
        (
            git config --file="${HOME}/.gitconfig.local" user.name "${GIT_USERNAME}"
            git config --file="${HOME}/.gitconfig.local" user.email "${GIT_EMAIL}"
            git config --file="${HOME}/.gitconfig.local" user.signingKey "${signingKey}"
            git config --file="${HOME}/.gitconfig.local" gpg.program gpg2
            git config --file="${HOME}/.gitconfig.local" commit.gpgsign true
            git config --file="${HOME}/.gitconfig.local" github.user "${GIT_USERNAME}"
        )
        echo "Remember to upload the GPG and SSH keys to Github"
    else
        _done "Git already configured" "[  ]"
    fi
}

_setup_zsh() {
    # install
    sudo apt-get install zsh

    # change shell to zsh
    chsh -s /bin/zsh gustaf

    # install zinit
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

    mkdir ~/.zinit
    git clone https://github.com/zdharma/zinit.git ~/.zinit/bin

    # https://github.com/kornicameister/dotfiles
    echo "

    source "$HOME/zsh/path.zsh"
    source "$HOME/zsh/alias.zsh"
    source "$HOME/zsh/zinit.zsh"

    " >> ~/.zshrc


    # reload zsh
    source ~/.zshrc
}


_setup_cuda() {
    if test -f "$WSL_EXEC"; then
        echo "wsl.exe found. Installing cuda-toolkit-11-0"
        sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
        sh -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
        sudo apt-get update
        sudo apt-get install -y cuda-toolkit-11-0
    else
        echo "Not inside WSL. Skipping cuda-toolkit-11-0 install"
    fi
}

_update_wsl() {
    if test -f "$WSL_EXEC"; then
        echo "wsl.exe found. Updating wsl"
        uname -r
        wsl.exe --update
    else
        echo "Not inside WSL. Skipping wsl.exe update"
    fi
}

_pre_install() {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install git
}

_pre_install()
_update_wsl()
_configure_git()
_setup_zsh()
_setup_cuda()

