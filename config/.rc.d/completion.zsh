#!/usr/bin/env zsh
# shellcheck disable=SC1071

# Initialize completion system
COMP_CACHE_DIR="${XDG_CACHE_HOME}/.zsh_cache"
autoload -Uz compinit

if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' "${COMP_CACHE_DIR}" 2>/dev/null)" ]; then
    compinit -d "$COMP_CACHE_DIR"
else
    compinit -C -d "$COMP_CACHE_DIR"
fi

# Completion options
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion

# Rehash automatically
zstyle ':completion:*' rehash true
# zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview "eza -1 --color=always $realpath"

# fzf
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# uv
if command -v uv &>/dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

COMPLETION_DIR="${0:A:h}/completion.d"

if [ -f "$COMPLETION_DIR/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "$COMPLETION_DIR/fzf-tab/fzf-tab.plugin.zsh"
fi
