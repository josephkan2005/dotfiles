# Setup fzf
# ---------
if [[ ! "$PATH" == */home/josephkan/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/josephkan/.fzf/bin"
fi

eval "$(fzf --bash)"
