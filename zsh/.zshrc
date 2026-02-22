[[ -f "${XDG_CACHE_HOME:-$HOME/.cache}/starship-instant-prompt.zsh" ]] && \
  source "${XDG_CACHE_HOME:-$HOME/.cache}/starship-instant-prompt.zsh"

# =============================================================================
# ENVIRONMENT & PATH
# =============================================================================
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export BOTO_PATH="$XDG_CONFIG_HOME/boto"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export EDITOR='nvim'
export SHELL=$(which zsh)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Unified PATH management using Zsh's 'path' array
# Directories are ordered by precedence (top = highest)
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/bin
  $HOME/.nix-profile/bin
  /nix/var/nix/profiles/default/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  /usr/local/go/bin
  $HOME/.local/go/bin
  $path
)

# Source tool-specific path injections
[[ -f "$HOME/.local/bin/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/.local/bin/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/.local/bin/terraform-old/path.zsh.inc" ]] && source "$HOME/.local/bin/terraform-old/path.zsh.inc"
[[ -d "$HOME/.local/bin/fzf/bin" ]] && path+=("$HOME/.local/bin/fzf/bin")

export PATH

# Homebrew environment variables (Cellar, Prefix, etc.)
# Logic: We already have Homebrew in PATH via the array above.
# brew shellenv is kept for internal variables but we ensure it doesn't mess with our path ordering.
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
  eval "$(brew shellenv)"
fi

# Modular KUBECONFIG
if [[ -d "$HOME/.kube/configs" ]]; then
  export KUBECONFIG="$HOME/.kube/config:$(find "$HOME/.kube/configs" -maxdepth 1 -type f \( -name "*.yaml" -o -name "*.yml" \) | tr '\n' ':')"
fi
export KUBE_EDITOR="nvim"

# =============================================================================
# ZSH OPTIONS & COMPLETIONS
# =============================================================================
setopt CORRECT
setopt histignorealldups sharehistory
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.cache/.zsh_history

autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# ZLE (Zsh Line Editor) settings
bindkey -e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
bindkey "^[[3~" delete-char    # Del
bindkey '^[[3;3~' kill-word   # Alt+Del
bindkey '\eb' backward-word   # Alt+b
bindkey '\ef' forward-word    # Alt+f

# Completion styling
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=long
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# =============================================================================
# ALIASES & MODERN TOOLS (with Fallbacks)
# =============================================================================
alias rc="${EDITOR} ${HOME}/.zshrc && source ${HOME}/.zshrc"
alias g='git'
alias vi='nvim'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Pager & Cat
if command -v bat &>/dev/null; then
  alias cat='bat --style=plain'
  export PAGER="bat"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  # No cat alias = standard cat
  export PAGER="less"
fi

# LS / LSD
if command -v lsd &>/dev/null; then
  alias ls='lsd --group-dirs=first'
  alias l='lsd --group-dirs=first'
  alias ll='lsd -lh --group-dirs=first'
  alias la='lsd -a --group-dirs=first'
else
  # Fallback to LS colors
  if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
  else
    alias ls='ls --color=auto'
  fi
  alias ll='ls -lh'
  alias la='ls -A'
fi

# Terraform & Kubernetes
alias k='kubectl'
alias t='terraform'
alias tv='terraform validate'
alias ti='terraform init'
alias tc='terraform console'
alias tu="terraform force-unlock"
alias tp='terraform plan'
alias tpq='terraform plan -refresh=false -lock=false'
alias ts='terraform plan -lock=false -no-color | grep "will be"'
alias tsq='terraform plan -refresh=false -lock=false -no-color | grep "will be"'
alias ta='terraform apply'
alias taq='terraform apply -refresh=false'
alias taa='terraform apply -auto-approve'
alias taaq='terraform apply -auto-approve -refresh=false'
alias tw='terraform workspace'
alias twl='terraform workspace list'
alias tws='terraform workspace select'
alias twn='terraform workspace new'

# Date variables (Portable)
if [[ "$(uname)" == "Darwin" ]]; then
  export m3=$(/bin/date -u -v-3m +"%Y-%m-%dT%H:%M:%SZ")
  export m1=$(/bin/date -u -v-1m +"%Y-%m-%dT%H:%M:%SZ")
  export w1=$(/bin/date -u -v-1w +"%Y-%m-%dT%H:%M:%SZ")
  export d3=$(/bin/date -u -v-3d +"%Y-%m-%dT%H:%M:%SZ")
  export d1=$(/bin/date -u -v-1d +"%Y-%m-%dT%H:%M:%SZ")
  export h6=$(/bin/date -u -v-6H +"%Y-%m-%dT%H:%M:%SZ")
  export h3=$(/bin/date -u -v-3H +"%Y-%m-%dT%H:%M:%SZ")
  export h1=$(/bin/date -u -v-1H +"%Y-%m-%dT%H:%M:%SZ")
else
  export m3=$(date -u --date="3 months ago" +"%Y-%m-%dT%H:%M:%SZ")
  export m1=$(date -u --date="1 month ago" +"%Y-%m-%dT%H:%M:%SZ")
  export w1=$(date -u --date="1 week ago" +"%Y-%m-%dT%H:%M:%SZ")
  export d3=$(date -u --date="3 days ago" +"%Y-%m-%dT%H:%M:%SZ")
  export d1=$(date -u --date="1 day ago" +"%Y-%m-%dT%H:%M:%SZ")
  export h6=$(date -u --date="6 hours ago" +"%Y-%m-%dT%H:%M:%SZ")
  export h3=$(date -u --date="3 hours ago" +"%Y-%m-%dT%H:%M:%SZ")
  export h1=$(date -u --date="1 hour ago" +"%Y-%m-%dT%H:%M:%SZ")
fi
export today=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Catppuccin Mocha for LESS
export LESS="-R --mouse --wheel-lines=3 --ignore-case --long-prompt -g -j20"
export LESS_TERMCAP_mb=$(tput setaf 212)
export LESS_TERMCAP_md=$(tput setaf 111)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput setaf 147; tput setab 235)
export LESS_TERMCAP_se=$(tput sgr0)
export LESS_TERMCAP_us=$(tput setaf 115)
export LESS_TERMCAP_ue=$(tput sgr0)

# =============================================================================
# PLUGINS & HOOKS
# =============================================================================
ZSH_PLUGINS_DIR="$HOME/.config/zsh"

source_if_exists() { [[ -r "$1" ]] && source "$1" }

source_if_exists "$ZSH_PLUGINS_DIR/nix-zsh-completions/nix-zsh-completions.plugin.zsh"
source_if_exists "$HOME/.local/bin/google-cloud-sdk/completion.zsh.inc"
source_if_exists "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_if_exists "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if [[ -f "$ZSH_PLUGINS_DIR/zsh-transient-prompt/zsh-transient-prompt.zsh" ]]; then
  source "$ZSH_PLUGINS_DIR/zsh-transient-prompt/zsh-transient-prompt.zsh"
fi

if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
  _direnv_hook() {
    eval "$(direnv export zsh 2>&1 | \
      sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g" | \
      egrep -v -e '^direnv: (loading|export|unloading)' \
    )"
  }
fi
