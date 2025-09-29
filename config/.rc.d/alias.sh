#!/usr/bin/env sh

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias catp='bat --plain --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias l='eza -l'
    alias ll='eza -al'
    alias la='eza -A'
    alias lt='eza -alRT --no-user --level=2'
fi

if command -v zellij >/dev/null 2>&1; then
    alias tm='zellij'
fi

if command -v vim >/dev/null 2>&1; then
    alias vi='vim'
fi
