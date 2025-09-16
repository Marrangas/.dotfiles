typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

BOTO_PATH="$HOME/.config"


# To enable debug mode for zsh startup, run:
# ZSH_DEBUG=1 zsh
if [[ -n "$ZSH_DEBUG" ]]; then
  zsh_log() {
    echo "zshrc: $@" >&2
  }
else
  zsh_log() {
    # Do nothing. To log to a file, you could use:
    # echo "$(date) - zshrc: $@" >> ~/.zsh-startup.log
  }
fi

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Helper to check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Helper to source a file if it is readable
source_if_exists() {
  if [[ -r "$1" ]]; then
    zsh_log "Sourcing $1"
    source "$1"
  else
    zsh_log "File not found or not readable, skipping source: $1"
  fi
}

# =============================================================================
# COMPLETIONS
# =============================================================================
autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit
if [[ -d "$HOME/.config/zsh/nix-zsh-completions" ]]; then
  fpath=($HOME/.config/zsh/nix-zsh-completions $fpath)
fi

if command_exists terraform; then
  zsh_log "Setting up terraform completion"
  complete -o nospace -C "$(command -v terraform)" terraform
else
  zsh_log "terraform not found, skipping completion setup"
fi

if command_exists kubectl; then
  zsh_log "Setting up kubectl completion"
  source <(kubectl completion zsh)
else
  zsh_log "kubectl not found, skipping completion setup"
fi

# =============================================================================
# ZLE (Zsh Line Editor)
# =============================================================================
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Emacs style
bindkey -e

# word jumps
bindkey "^[[3~" delete-char # Delete character (Del key)
bindkey '^[[3;3~' kill-word # Alt+Del: kill word forward
bindkey '\eb' backward-word # Alt+b: move back one word
bindkey '\ef' forward-word # Alt+f: move forward one word

# =============================================================================
# ENVIRONMENT
# =============================================================================
setopt histignorealldups sharehistory
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.cache/.zsh_history

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

export SHELL=$(which zsh)
export EDITOR='nvim'
export ZSH_TMUX_AUTOSTART=true
export CLOUDSDK_PYTHON=/usr/bin/python3
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Date variables for scripts (macOS/BSD date syntax)
if [[ "$(uname)" == "Darwin" ]]; then
  # BSD/macOS date syntax
  export m3=$(/bin/date -u -v-3m +"%Y-%m-%dT%H:%M:%SZ")
  export m1=$(/bin/date -u -v-1m +"%Y-%m-%dT%H:%M:%SZ")
  export w1=$(/bin/date -u -v-1w +"%Y-%m-%dT%H:%M:%SZ")
  export d3=$(/bin/date -u -v-3d +"%Y-%m-%dT%H:%M:%SZ")
  export d1=$(/bin/date -u -v-1d +"%Y-%m-%dT%H:%M:%SZ")
  export h6=$(/bin/date -u -v-6H +"%Y-%m-%dT%H:%M:%SZ")
  export h3=$(/bin/date -u -v-3H +"%Y-%m-%dT%H:%M:%SZ")
  export h1=$(/bin/date -u -v-1H +"%Y-%m-%dT%H:%M:%SZ")
else
  # GNU/Linux date syntax
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

alias rc="${EDITOR} ${HOME}/.zshrc && source ${HOME}/.zshrc"

alias g='git'
alias cat='bat'
alias vi='nvim'
alias vim='nvim'

alias l='lsd --group-dirs=first'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias t='terraform'
alias tv='terraform validate'
alias ti='terraform init'
alias tc='terraform console'
alias tu="terraform force-unlock"
alias tp='terraform plan'
alias tpq='terraform plan -refresh=false -lock=false'
alias tl='terraform plan -lock=false 2>&1 | grep "will be"'
alias tlq='terraform plan -refresh=false -lock=false  2>&1 | grep "will be"'
alias ta='terraform apply'
alias taq='terraform apply -refresh=false'
alias taa='terraform apply -auto-approve'
alias taaq='terraform apply -auto-approve -refresh=false'
alias tw='terraform workspace'
alias twl='terraform workspace list'
alias tws='terraform workspace select'
alias twn='terraform workspace new'
alias texcept='terraform plan -destroy $(for r in `terraform state list | fgrep -v $1` ; do printf "-target ${r} "; done) -out destroy.plan'
alias ts='terraform plan -lock=false -no-color | grep "will be"'
alias tsq='terraform plan -refresh=false -lock=false -no-color | grep "will be"'

function tsrmq(){
  for cmd in terraform parallel; do
    if ! command_exists "$cmd"; then
      echo "zsh: function tsrmq: command not found: $cmd" >&2
      return 1
    fi
  done
  parallel --keep-order --line-buffer -j1 -v "terraform state rm {}; sleep 1 " ::: "$(terraform plan -refresh="false" -lock="false" -no-color | grep "will be destroyed" | sed 's|.*# \(.*\) will be destroyed|\1|')"
}

function tsrm(){
  for cmd in terraform parallel; do
    if ! command_exists "$cmd"; then
      echo "zsh: function tsrm: command not found: $cmd" >&2
      return 1
    fi
  done
  parallel -j1 -v "terraform state rm {}; sleep 1 " ::: "$(terraform plan -lock="false" -no-color | grep "will be destroyed" | sed 's|.*# \(.*\) will be destroyed|\1|')"
}

function tclean(){
  if ! command_exists parallel; then
    echo "zsh: function tclean: command not found: parallel" >&2
    return 1
  fi
  find . -type d -name '.terraform' | parallel 'rm -rf {}'
}

alias k='kubectl'

alias json2csv='jq -r '\''(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv'\'''

function mkt(){
    mkdir {nmap,content,exploits,scripts}
}

function gtoken(){
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" $@
}

function glog() {
  for cmd in gcloud curl jq nvim; do
    if ! command_exists "$cmd"; then
      echo "zsh: function glog: command not found: $cmd" >&2
      return 1
    fi
  done

  # Validate arguments
  if [ -z "$1" ]; then
    echo "Usage: glog <project_id>" >&2
    return 1
  fi

  if [ -z "$h1" ] || [ -z "$today" ]; then
    echo "Error: 'h1' and 'today' variables must be set." >&2
    return 1
  fi

  local token
  token=$(gcloud auth print-access-token)
  if [[ -z "$token" ]]; then
    echo "Error: could not get gcloud access token. Please run 'gcloud auth login'." >&2
    return 1
  fi

  curl --request POST "https://logging.googleapis.com/v2/entries:list" \
    --header "Authorization: Bearer $token" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --data '{
      "projectIds": ["'"$1"'"],
      "filter": "timestamp >= \"'"$h1"'\" AND timestamp <= \"'"$today"'\""
    }'\
    | jq '.entries[]' \
    | nvim -c "set ft=json"
}

function rmk(){
  if ! command_exists scrub; then
    echo "zsh: function rmk: command not found: scrub. On macOS, run: brew install secure-delete" >&2
    return 1
  fi
  if ! command_exists shred; then
    echo "zsh: function rmk: command not found: shred. On macOS, run: brew install coreutils" >&2
    return 1
  fi
	scrub -p dod "$1"
	shred -zun 10 -v "$1"
}

# Blinking text -> Bold Magenta
# Bold text -> Bold Magenta
# End all modes (reset)
# End standout mode
# Standout mode -> Bold Yellow foreground on Blue background
# Underline text -> Bold Cyan
function man() {
    env \
    LESS_TERMCAP_mb=$'\e[1;35m' \
    LESS_TERMCAP_md=$'\e[1;35m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[1;33;44m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[1;36m' \
    man "$@"
}

# =============================================================================
# PLUGINS & THEMES
# =============================================================================

# Powerlevel10k Theme
source_if_exists "$HOME/.config/powerlevel10k/powerlevel10k.zsh-theme"
source_if_exists "$HOME/.p10k.zsh"

# Zsh plugins
ZSH_PLUGINS_DIR="$HOME/.config/zsh"
source_if_exists "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_if_exists "$ZSH_PLUGINS_DIR/zsh-highlighting/zsh-syntax-highlighting.zsh"
source_if_exists "$ZSH_PLUGINS_DIR/nix-zsh-completions/nix-zsh-completions.plugin.zsh"

# Google Cloud SDK completion
source_if_exists "$HOME/.local/bin/google-cloud-sdk/completion.zsh.inc"

# FZF and related plugins
source_if_exists "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/fzf.zsh"
source_if_exists "${XDG_CONFIG_HOME:-$HOME/.config}/.local/bin/.fzf-gcloud.plugin.zsh"

# =============================================================================
# PATH CONFIGURATION
# =============================================================================

# Use `typeset -U path` to ensure the PATH array has unique elements.
# zsh automatically keeps the `path` array and `PATH` string in sync.
typeset -U path

# Define helper functions to modify the path array.
path_prepend() {
  if [[ -d "$1" ]]; then
    zsh_log "Prepending to path: $1"
    path=("$1" $path)
  else
    zsh_log "Directory not found, not adding to path: $1"
  fi
}

path_append() {
  if [[ -d "$1" ]]; then
    zsh_log "Appending to path: $1"
    path+=("$1")
  else
    zsh_log "Directory not found, not adding to path: $1"
  fi
}

# Start with system paths.
path=(
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
)

# Homebrew on macOS
if [[ "$(uname)" == "Darwin" ]]; then
  if command_exists brew; then
    zsh_log "Setting up Homebrew environment"
    eval "$(brew shellenv)"
  else
    zsh_log "Homebrew command not found, attempting manual path setup for /opt/homebrew/bin"
    path_prepend "/opt/homebrew/bin"
  fi
fi

# Nix
path_prepend "$HOME/.nix-profile/bin"
path_prepend "/nix/var/nix/profiles/default/bin"

# Go
path_prepend "$HOME/.local/go/bin"
path_prepend "/usr/local/go/bin"

# User-installed binaries
path_prepend "$HOME/.local/bin"

# FZF
path_append "$HOME/.local/bin/fzf/bin"

# Google Cloud SDK
source_if_exists "$HOME/.local/bin/google-cloud-sdk/path.zsh.inc"

# Old Terraform version
source_if_exists "$HOME/.local/bin/terraform-old/path.zsh.inc"

# final with local scripts
# bindkey -s ^e "sessionizer\n"

# =============================================================================
# FINAL SETUP
# =============================================================================

# Direnv
if command_exists direnv; then
  zsh_log "Setting up direnv hook"
  eval "$(direnv hook zsh)"

  # This hook is to suppress direnv's output.
  _direnv_hook() {
    eval "$(direnv export zsh 2>&1 | \
      sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g" | \
      egrep -v -e '^direnv: (loading|export|unloading)' \
    )"
  }
else
  zsh_log "direnv not found, skipping hook setup"
fi

# FZF keybindings and fuzzy completion
if command_exists fzf; then
  zsh_log "Setting up fzf"
  eval "$(fzf --zsh)"
else
  zsh_log "fzf not found, skipping setup"
fi

