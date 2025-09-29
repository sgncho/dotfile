HISTFILE="${XDG_CACHE_HOME}/.bash_history"  # Path to the history file
HISTSIZE=10000                              # Number of commands to keep in internal history
HISTFILESIZE=10000                          # Number of commands to save in the history file

HISTTIMEFORMAT="%F %T "                         # Save timestamp and duration
HISTCONTROL="ignorespace:ignoredups:erasedups"  # Ignore space, duplicates
shopt -s histappend                             # Append to history file
shopt -s cmdhist                                # Save multi-line commands as one entry
PROMPT_COMMAND="history -a; history -n"         # Append immediately and reload
