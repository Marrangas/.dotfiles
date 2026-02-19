# Source shared config
source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/fzf-config.sh"

eval "$(fzf --bash)"
