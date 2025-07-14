# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/altostratus/fzf/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/altostratus/fzf/.fzf/bin"
fi

eval "$(fzf --zsh)"
