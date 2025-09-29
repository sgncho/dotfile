# Completion options
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set colored-stats on'
bind 'set menu-complete-display-prefix on'

# fzf
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
fi

# uv
if command -v uv &>/dev/null; then
    eval "$(uv generate-shell-completion bash)"
fi
