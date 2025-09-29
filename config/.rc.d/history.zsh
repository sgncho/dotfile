#!/usr/bin/env zsh
# shellcheck disable=SC1071

ZSH_COMPDUMP=${XDG_CACHE_HOME}/.zsh_compdump
HISTFILE=${XDG_CACHE_HOME}/.zsh_history # Path to the history file
HISTSIZE=10000                          # Number of commands to keep in internal history
SAVEHIST=10000                          # Number of commands to save in the history file

# History options
setopt EXTENDED_HISTORY     # Save timestamp and duration
setopt HIST_IGNORE_SPACE    # Ignore commands that start with a space
setopt HIST_IGNORE_ALL_DUPS # Avoid storing duplicate commands sequentially
setopt HIST_FIND_NO_DUPS    # Don't display duplicates when searching
setopt HIST_SAVE_NO_DUPS    # Don't write duplicates to history file
setopt INC_APPEND_HISTORY   # Append commands to history file immediately
setopt SHARE_HISTORY        # Share history across terminals
