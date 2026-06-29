[[ -f "${XDG_CACHE_HOME:-$HOME/.cache}/starship-instant-prompt.zsh" ]] && \
  source "${XDG_CACHE_HOME:-$HOME/.cache}/starship-instant-prompt.zsh"

# =============================================================================
# DEBUGGING & ERROR HANDLING
# =============================================================================
# Enable debugging by setting DEBUG_ZSH=1 before sourcing
export DEBUG_ZSH="${DEBUG_ZSH:-0}"

# Debug logging function
debug_log() {
  [[ "$DEBUG_ZSH" -eq 1 ]] && echo "DEBUG: $*" >&2
}

# Safe source function with error handling
safe_source() {
  local file="$1"
  if [[ -r "$file" ]]; then
    debug_log "Sourcing: $file"
    if ! source "$file" 2>&1; then
      echo "WARNING: Failed to source $file" >&2
      return 1
    fi
  else
    debug_log "File not readable or missing: $file"
    return 1
  fi
}

# Safe eval function with error handling
safe_eval() {
  local cmd="$1"
  debug_log "Evaluating: $cmd"
  if ! eval "$cmd" 2>&1; then
    echo "WARNING: Failed to evaluate: $cmd" >&2
    return 1
  fi
}

# Trap for unhandled errors (optional, can be enabled with DEBUG_ZSH=2)
if [[ "$DEBUG_ZSH" -eq 2 ]]; then
  set -e
  trap 'echo "ERROR: Command failed at line $LINENO: $BASH_COMMAND" >&2' ERR
fi

# =============================================================================
# ENVIRONMENT & PATH
# =============================================================================

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export BOTO_PATH="$XDG_CONFIG_HOME/boto"
export CARGO_HOME="$HOME/.config/cargo"
export GOBIN="$HOME/.local/bin"
export TLDR_CONFIG_DIR="$HOME/.config/tldr"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export EDITOR='nvim'
export SHELL=$(which zsh)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export ZSH_CACHE_DIR="$HOME/.cache/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"
autoload -Uz compinit
compinit -d "$ZSH_CACHE_DIR/.zcompdump-$HOST"
autoload -Uz bashcompinit
bashcompinit

# Unified PATH management using Zsh's 'path' array
# Directories are ordered by precedence (top = highest)
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/bin
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
safe_source "$HOME/.local/bin/google-cloud-sdk/path.zsh.inc"
safe_source "$HOME/.local/bin/terraform-old/path.zsh.inc"
[[ -d "$HOME/.local/bin/fzf/bin" ]] && path+=("$HOME/.local/bin/fzf/bin")

export PATH

# Homebrew environment variables (Cellar, Prefix, etc.)
# Logic: We already have Homebrew in PATH via the array above.
# brew shellenv is kept for internal variables but we ensure it doesn't mess with our path ordering.
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
  safe_eval "$(brew shellenv)"
fi

# Modular KUBECONFIG
if [[ -d "$HOME/.kube/configs" ]]; then
  export KUBECONFIG="$HOME/.kube/config:$(find "$HOME/.kube/configs" -maxdepth 1 -type f \( -name "*.yaml" -o -name "*.yml" \) | tr '\n' ':')"
fi
export KUBE_EDITOR="nvim"

# =============================================================================
# ZSH OPTIONS & COMPLETIONS
# =============================================================================
setopt histignorealldups sharehistory
unsetopt complete_aliases
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.cache/.zsh_history


# Completion styling
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=long
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# =============================================================================
# ALIASES & MODERN TOOLS (with Fallbacks)
# =============================================================================

# ZLE (Zsh Line Editor) settings
bindkey -e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
bindkey "^[[3~" delete-char    # Del
bindkey '^[[3;3~' kill-word   # Alt+Del
bindkey '\eb' backward-word   # Alt+b
bindkey '\ef' forward-word    # Alt+f
bindkey -s '^x' 'kubectx\n'

alias rc="${EDITOR} ${HOME}/.zshrc && source ${HOME}/.zshrc"
alias vi='nvim'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if command -v bat &>/dev/null; then
  alias cat=bat
  export MANPAGER="nvim +Man!"
fi

if command -v nvim &>/dev/null;then
  export MANPAGER="nvim +Man!"
  export PAGER="nvim -c 'set ft=man' -"
fi

if command -v nvimpager &>/dev/null;then
  export PAGER="nvimpager"
  export MANPAGER="nvimpager"
fi

# if command -v moor &>/dev/null; then
#   export PAGER=moor
#   export MOOR='--style=catppuccin-macchiato'
# fi

if command -v lsd &>/dev/null; then
  alias ls='lsd --group-dirs=first'
  alias l='lsd --group-dirs=first'
  alias ll='lsd -lh --group-dirs=first'
  alias la='lsd -a --group-dirs=first'
else
  if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
  else
    alias ls='ls --color=auto'
  fi
  alias ll='ls -lh'
  alias la='ls -A'
fi

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


alias wiki="cd ~/Documents/wiki/ && nvim atlas/TODO.md"
alias dia="cd ~/Documents/dgrp/docs && nvim dia.md"

if command -v git &>/dev/null; then
    alias g='git'
    compdef g=git
fi

if command -v jq &>/dev/null; then
    alias json2csv='jq -r '\''(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv'\'''
fi

if command -v kubectl &>/dev/null; then
    alias k='kubectl'
    source <(kubectl completion zsh)
    compdef k=kubectl
fi

if command -v terraform &>/dev/null; then
    alias t='terraform'
    complete -o nospace -C terraform terraform t
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

    function tsrmt(){
      for cmd in terraform xargs; do
        if ! command -v "$cmd" &> /dev/null; then
          echo "zsh: function tsrmt: command not found: $cmd" >&2
          return 1
        fi
      done
      terraform plan -refresh="false" -lock="false" -no-color -target "'$1'" | \
          grep "will be destroyed" | \
          sed 's|.*# \(.*\) will be destroyed|\1|' | \
          xargs -I {} -P 1 -n 1 sh -c "terraform state rm {}; sleep 1"
    }

    function tsrmq(){
      for cmd in terraform xargs; do
        if ! command -v "$cmd" &> /dev/null; then
          echo "zsh: function tsrmq: command not found: $cmd" >&2
          return 1
        fi
      done
      terraform plan -refresh="false" -lock="false" -no-color | \
          grep "will be destroyed" | \
          sed 's|.*# \(.*\) will be destroyed|\1|' | \
          xargs -I {} -P 1 -n 1 sh -c "terraform state rm {}; sleep 1"
    }

    function tsrm(){
      for cmd in terraform xargs; do
        if ! command -v "$cmd" &> /dev/null ; then
          echo "zsh: function tsrm: command not found: $cmd" >&2
          return 1
        fi
      done
      terraform plan -lock="false" -no-color | \
          grep "will be destroyed" | \
          sed 's|.*# \(.*\) will be destroyed|\1|' | \
          xargs -I {} -P 1 -n 1 sh -c "terraform state rm {}; sleep 1"
    }

    function tclean(){
      for cmd in terraform xargs; do
        if ! command -v "$cmd" &> /dev/null ; then
          echo "zsh: function tsrm: command not found: $cmd" >&2
          return 1
        fi
      done
      find . -type d -name '.terraform' -print0 | xargs -0 -P 0 rm -rf
    }
fi

if command -v gcloud &>/dev/null; then
    [ -f "$HOME"/.local/bin/.fzf-gcloud.plugin.zsh ] && source "$HOME"/.local/bin/.fzf-gcloud.plugin.zsh

    function gtoken(){
      curl -H "Authorization: Bearer $(gcloud auth print-access-token)" $@
    }

    function glog() {
      for cmd in gcloud curl jq nvim; do
        if ! command -v "$cmd" &> /dev/null ; then
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
fi

function mkt(){
    mkdir {nmap,content,exploits,scripts}
}

function rmk(){
  if ! command -v scrub &> /dev/null ; then
    echo "zsh: function rmk: command not found: scrub. On macOS, run: brew install secure-delete" >&2
    return 1
  fi
  if ! command -v shred &> /dev/null ; then
    echo "zsh: function rmk: command not found: shred. On macOS, run: brew install coreutils" >&2
    return 1
  fi
	scrub -p dod "$1"
	shred -zun 10 -v "$1"
}

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

# Determine plugin paths with Homebrew support
ZSH_AUTOSUGGEST_PATH="$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_HIGHLIGHT_PATH="$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  [[ -r "$ZSH_AUTOSUGGEST_PATH" ]] || ZSH_AUTOSUGGEST_PATH="$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$ZSH_HIGHLIGHT_PATH" ]] || ZSH_HIGHLIGHT_PATH="$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

safe_source "$HOME/.local/bin/google-cloud-sdk/completion.zsh.inc"

# Locate and source zsh-autosuggestions with portable fallbacks (Homebrew/Linux)
if [[ -r "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  safe_source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -n "$HOMEBREW_PREFIX" && -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  safe_source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -r "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  safe_source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -r "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  safe_source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Locate and source zsh-syntax-highlighting with portable fallbacks (Homebrew/Linux)
if [[ -r "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  safe_source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -n "$HOMEBREW_PREFIX" && -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  safe_source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -r "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  safe_source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -r "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  safe_source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

safe_source "$ZSH_AUTOSUGGEST_PATH"
safe_source "$ZSH_HIGHLIGHT_PATH"

if command -v starship &>/dev/null; then
  safe_eval "$(starship init zsh)"
fi

if [[ -f "$ZSH_PLUGINS_DIR/zsh-transient-prompt/zsh-transient-prompt.zsh" ]]; then
  source "$ZSH_PLUGINS_DIR/zsh-transient-prompt/zsh-transient-prompt.zsh"
fi

if command -v fzf &>/dev/null; then
  safe_eval "$(fzf --zsh)"
fi

if command -v direnv &>/dev/null; then
  safe_eval "$(direnv hook zsh)"
  _direnv_hook() {
    safe_eval "$(direnv export zsh 2>&1 | \
      sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g" | \
      egrep -v -e '^direnv: (loading|export|unloading)' \
    )"
  }
fi

# Added by Antigravity IDE
export PATH="/Users/altostratus/.antigravity-ide/antigravity-ide/bin:$PATH"
