# Shared FZF Settings
if [[ ! "$PATH" == *"$HOME/.local/bin/fzf/.fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.local/bin/fzf/.fzf/bin"
fi

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--multi --height 60% --layout=reverse --border --prompt='󰭎 ' \
--preview 'if [ -d {} ]; then lsd --tree --color=always {} | head -200; else bat --color=always --style=numbers --line-range :500 {}; fi'"

# 3. Use ripgrep for search (faster, respects .gitignore)
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/*'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# 4. CUSTOM COMMANDS
# e: Quick open in Neovim with preview
# Use 'xargs -o' on macOS to ensure nvim takes over the terminal correctly
alias e='fzf --preview "bat --color=always --style=numbers {}" | xargs -o nvim'
