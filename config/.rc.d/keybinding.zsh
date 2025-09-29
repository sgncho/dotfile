#!/usr/bin/env zsh
# shellcheck disable=SC1071

# Use vim key bindings
bindkey -v

function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[2 q'
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[1 q'
    fi
}

zle -N zle-keymap-select
