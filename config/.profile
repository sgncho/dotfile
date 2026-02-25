# Set PATH
export PATH="$HOME/.local/bin:$PATH"

# Homebrew setup (for login shell)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set language environment
export LANG=en_US.UTF-8

# Set default editor
if command -v nvim &> /dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
elif command -v vim &> /dev/null; then
  export EDITOR='vim'
  export VISUAL='vim'
else
  export EDITOR='vi'
  export VISUAL='vi'
fi

# XDG Base Directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export BINARY_HOME="$HOME/.local/bin"

# Rust
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
if [ -d "$RUSTUP_HOME" ]; then
  export PATH="$CARGO_HOME/bin:$PATH"
fi

# fzf
export FZF_DEFAULT_OPTS="
    --height=50%
    --reverse
    --border=top
    --info=inline-right
    --ansi
"
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden --exclude .git --color=always"
else
  export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/\.git/*'"
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# kubectl
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"

# npm
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

# bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"
if [ -d "$BUN_INSTALL" ]; then
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# nvm
export NVM_DIR="$XDG_DATA_HOME/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# man
if command -v bat &> /dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  export MANPAGER="less -R"
fi

# claude code
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# codex
export CODEX_HOME="$XDG_CONFIG_HOME/codex"
