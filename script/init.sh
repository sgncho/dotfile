#!/usr/bin/env bash

DOTFILE_REPOSITORY="git@github.com:sgncho/dotfile.git"

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

check_cmd() {
    command -v "$1" >/dev/null 2>&1
    return $?
}

need_cmd() {
    if ! check_cmd "$1"; then
        err "need '$1' (command not found)"
    fi
}

check_dependencies() {
    need_cmd git
    need_cmd curl
    check_uv
    check_ansible
}

check_uv() {
    if ! check_cmd uv; then
        curl -LsSf https://astral.sh/uv/install.sh | sh -
        # shellcheck disable=SC1091
        . "$HOME/.local/bin/env"
        need_cmd uv
    fi
}

check_ansible() {
    if ! check_cmd ansible; then
        uv tool install --with-executables-from ansible-core ansible >/dev/null 2>&1
        # shellcheck disable=SC1091
        . "$HOME/.local/bin/env"
        need_cmd ansible
    fi
}

clone_dotfile_repository() {
    local DOTFILE_DIR
    DOTFILE_DIR=$HOME/dotfile

    if [ -n "$CI" ]; then
        if [ -d "$GITHUB_WORKSPACE" ]; then
            ln -sf "$GITHUB_WORKSPACE" "$DOTFILE_DIR" || cp -r "$GITHUB_WORKSPACE" "$DOTFILE_DIR"
            echo "dotfile repository linked from CI workspace."
        else
            echo "Using current directory in CI environment."
            DOTFILE_DIR=$(pwd)
        fi
    else
        if [ -d "$DOTFILE_DIR" ]; then
            echo "dotfile directory already exists at $DOTFILE_DIR"
            if ! (cd "$DOTFILE_DIR" && git pull origin main 2>/dev/null); then
                err "failed to pull updates in existing dotfile repository."
            fi
            echo "dotfile repository updated."
        elif git clone "$DOTFILE_REPOSITORY" "$DOTFILE_DIR"; then
            echo "dotfile repository cloned successfully."
        else
            err "failed to clone dotfile repository."
        fi
    fi
}

export_env() {
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export LOCAL_BINARY_HOME=$HOME/.local/bin
}

create_directories() {
    mkdir -p "$XDG_CONFIG_HOME"
    mkdir -p "$XDG_DATA_HOME"
    mkdir -p "$LOCAL_BINARY_HOME"
}

install_packages() {
    cd "$HOME/dotfile"

    if ansible-playbook init.yaml; then
        echo "packages installed successfully."
    else
        err "failed to install packages."
    fi
}

bootstrap() {
    check_dependencies
    clone_dotfile_repository
    export_env
    create_directories
    install_packages
}

bootstrap "$@" || exit 1
