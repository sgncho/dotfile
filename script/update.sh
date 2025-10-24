#!/usr/bin/env bash

set -e

has_local() {
    local _has_local
}

has_local 2>/dev/null || alias local=typeset

err() {
    local red
    local reset
    red=$(tput setaf 1 2>/dev/null || echo '')
    reset=$(tput sgr0 2>/dev/null || echo '')
    echo "${red}error${reset}: $1" >&2
    exit 1
}

if ! git pull origin main; then
    err "Failed to pull from origin/main"
fi

DOTFILE_DIR="$HOME/dotfile"

cd "$DOTFILE_DIR"
ansible-playbook init.yaml
