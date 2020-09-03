#!/bin/zsh

fpath=($fpath $DOTFILES/zsh/fpath)
if [ ! "$PATH_LOADED" = "true" ]; then
    # We want to extend path once
    export EDITOR="$(which code)"
    
    export LANG=en_GB.UTF-8 # Default language
    export LC_ALL=en_GB.UTF-8
    
    if [[ $commands[javac] ]]; then
        export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"
    fi

    # Add custom bin files
    if [ -d "$HOME/bin" ]; then export PATH="$HOME/bin:$PATH"; fi
    if [ -d "$HOME/.local/bin" ]; then export PATH="$HOME/.local/bin:$PATH"; fi

    # export PATH="$HOME/.tfenv/bin:$PATH"
    export ZPLUG_LOADFILE="$DOTFILES/.zplugs.zsh"
    export PATH_LOADED="true"

    # export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

alias tolower="tr '[:upper:]' '[:lower:]'"
alias toupper="tr '[:lower:]' '[:upper:]'"