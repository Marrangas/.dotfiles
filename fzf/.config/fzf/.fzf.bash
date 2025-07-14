# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/altostratus/.dotfiles/fzf/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/altostratus/.dotfiles/fzf/.fzf/bin"
fi

eval "$(fzf --bash)"
