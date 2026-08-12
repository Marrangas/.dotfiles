#!/usr/bin/env bash
# helpers/bootstrap.sh - Bootstraps the workspace environment with layering
# This script is both the configuration data and the execution engine.
# In "lisp-fashion", it can be sourced to load variables, or executed to run the setup.

set -euo pipefail

# CONFIGURATION DATA (The Single Source of Truth for Workspace Layering)

# GLOBAL SETTINGS
DOTFILE_FONT="FiraCode Nerd Font"
DOTFILE_FONT_SIZE=12
DOTFILE_STYLE="dark"
DOTFILE_THEME="tokyonight"
DOTFILE_TERMINAL="ghostty"
DOTFILE_SEARCH_TOOL="ripgrep"
DOTFILE_TERMINAL_OPACITY=0.85

# SYSTEM PACKAGES
# All directories that can be stowed as packages
DOTFILE_PACKAGES=(
  "git"
  "zsh"
  "vim"
  "nvim"
  "tmux"
  "ghostty"
  "nvimpager"
  "aerospace"
  "editorconfig"
  "bat"
  "fzf"
  "copyq"
  "starship"
  "garden"
  "gemini"
  "htop"
  "macOs"
  "scripts"
)

# Packages that have granular layer control
DOTFILE_LAYERED=(
  "nvim"
)

# NEOVIM
# LSP Servers to install/configure
DOTFILE_LSP_SERVERS=(
  "gopls"
  "html-lsp",
  "lua_ls"
  "markdown-oxide",
  "prettier",
  "pyright"
  "shellharden",
)

# GRANULAR LAYERS
NVIM_MINIMAL_LAYER=(
  "nvim/.config/nvim/init.lua"
  "nvim/.config/nvim/lua/config/autocmd.lua"
  "nvim/.config/nvim/lua/config/options.lua"
  "nvim/.config/nvim/lua/config/keymaps.lua"
  "nvim/.config/nvim/lua/plugins/mini.lua"
  "nvim/.config/nvim/lua/util/health.lua"
  "nvim/.config/nvim/lua/util/whip.lua"
  "nvim/.config/nvim/lua/util/init.lua"
  "nvim/.config/nvim/.stylua.toml"
  "nvim/.config/nvim/README.md"
  "nvim/.config/nvim/nvim-pack-lock.json"
)

NVIM_STANDARD_LAYER=(
  "nvim/.config/nvim/lua/plugins/treesitter.lua"
  "nvim/.config/nvim/lua/plugins/lsp.lua"
  "nvim/.config/nvim/lua/plugins/completion.lua"
  "nvim/.config/nvim/lua/plugins/picker.lua"
  "nvim/.config/nvim/lua/plugins/format.lua"
  "nvim/.config/nvim/lua/plugins/lint.lua"
  "nvim/.config/nvim/lua/plugins/comments.lua"
  "nvim/.config/nvim/lua/plugins/git.lua"
  "nvim/.config/nvim/lua/plugins/navegation.lua"
  "nvim/.config/nvim/lua/plugins/quickfix.lua"
  "nvim/.config/nvim/lua/plugins/ui.lua"
  "nvim/.config/nvim/lua/plugins/undo.lua"
  "nvim/.config/nvim/lua/util/wiki_completions.lua"
  "nvim/.config/nvim/luasnippets/markdown.lua"
  "nvim/.config/nvim/luasnippets/all.lua"
  "nvim/.config/nvim/luasnippets/sh.lua"
  "nvim/.config/nvim/doc/whip.txt"
)

NVIM_SPECIFIC_LAYER=(
  "nvim/.config/nvim/lua/plugins/markdown.lua"
  "nvim/.config/nvim/lua/plugins/ia.lua"
  "nvim/.config/nvim/lua/plugins/sec.lua"
  "nvim/.config/nvim/lua/plugins/debug.lua"
  "nvim/.config/nvim/lua/xperiments/wiki.lua"
  "nvim/.config/nvim/lua/xperiments/dev.lua"
  "nvim/.config/nvim/lua/xperiments/vim-mappings.lua"
  "nvim/.config/nvim/lua/xperiments/vim-practice.lua"
  "nvim/.config/nvim/lua/xperiments/colors-custom.lua"
  "nvim/.config/nvim/lua/xperiments/colors-treesiter.lua"
  "nvim/.config/nvim/lua/xperiments/colors-markdown.lua"
)

# --- GLOBAL DEFAULT LAYERS ---
# Merged from individual package variables across the workspace
DOTFILE_LAYER_MINIMAL=(
  "${NVIM_MINIMAL_LAYER[@]}"
)

DOTFILE_LAYER_STANDARD=(
  "${NVIM_STANDARD_LAYER[@]}"
)

DOTFILE_LAYER_SPECIFIC=(
  "${NVIM_SPECIFIC_LAYER[@]}"
)

# ENGINE & FUNCTIONS
CONFIG_FILE="build.sh"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Verify repository git status
check_git_status() {
  if [ "$(git status --porcelain 2>/dev/null)" != "" ]; then
    printf "Notice: You have uncommitted changes in your repository.\n"
    printf "Committing your workspace captures active configs and autodocuments them!\n\n"
  fi
}


# Generate package-specific configurations (like Ghostty)
generate_ghostty_config() {
  if [[ " ${DOTFILE_PACKAGES[*]} " =~ " ghostty " ]]; then
    mkdir -p ghostty/.config/ghostty
    cat <<EOF > ghostty/.config/ghostty/env.conf
# Generated dynamically by helpers/bootstrap.sh - DO NOT EDIT MANUALLY
font-family = "${DOTFILE_FONT:-FiraCode Nerd Font}"
font-size = ${DOTFILE_FONT_SIZE:-12}
theme = "${DOTFILE_THEME:-catppuccin-mocha}"
background-opacity = ${DOTFILE_TERMINAL_OPACITY:-1.0}
EOF
  fi
}

generate_bat_config() {
  if [[ " ${DOTFILE_PACKAGES[*]} " =~ " bat " ]]; then
    mkdir -p ghostty/.config/ghostty
    cat <<EOF > bat/.config/bat/config
--style="changes"
--pager="never"
--map-syntax "*.jenkinsfile:Groovy"
--map-syntax "*.props:Java Properties"
EOF
	if [[ ${DOTFILE_STYLE} == "dark" ]]; then
		cat <<EOF >> bat/.config/bat/config
			--theme="Catppuccin Mocha"
EOF
	elif [[ ${DOTFILE_STYLE} == "light" ]]; then
		cat <<EOF >> bat/.config/bat/config
			--theme="Monokai Extended Light"
EOF
	fi
  fi
}

# Write environment profile headers and global configurations
write_profile_header() {
  local env_name="$1"
  local active_layer="$2"
  local dest_file="$3"
  local joined_lsps="$4"

  printf '# Workspace Environment: %s\n' "$env_name" > "$dest_file"
  printf '# Loaded by Bash, Makefile, and Ansible.\n' >> "$dest_file"
  printf '# Generated automatically from build.sh.\n\n' >> "$dest_file"
  printf 'WORKSPACE_NAME="%s"\n' "$env_name" >> "$dest_file"
  printf 'DOTFILE_LAYER="%s"\n\n' "$active_layer" >> "$dest_file"

  # Global configurations from build.sh
  printf 'export DOTFILE_FONT="%s"\n' "${DOTFILE_FONT:-FiraCode Nerd Font}" >> "$dest_file"
  printf 'export DOTFILE_FONT_SIZE="%s"\n' "${DOTFILE_FONT_SIZE:-12}" >> "$dest_file"
  printf 'export DOTFILE_STYLE="%s"\n' "${DOTFILE_STYLE:-dark}" >> "$dest_file"
  printf 'export DOTFILE_THEME="%s"\n' "${DOTFILE_THEME:-catppuccin-mocha}" >> "$dest_file"
  printf 'export DOTFILE_TERMINAL="%s"\n' "${DOTFILE_TERMINAL:-ghostty}" >> "$dest_file"
  printf 'export DOTFILE_SEARCH_TOOL="%s"\n' "${DOTFILE_SEARCH_TOOL:-ripgrep}" >> "$dest_file"
  printf 'export DOTFILE_TERMINAL_OPACITY="%s"\n\n' "${DOTFILE_TERMINAL_OPACITY:-0.85}" >> "$dest_file"
  printf 'export DOTFILE_LSP_SERVERS="%s"\n\n' "$joined_lsps" >> "$dest_file"

  printf 'DOTFILE_PACKAGES=(\n' >> "$dest_file"
  for pkg in "${DOTFILE_PACKAGES[@]}"; do
    printf '  "%s"\n' "$pkg" >> "$dest_file"
  done
  printf ')\n\n' >> "$dest_file"
}

# Core function to dynamically gather package files and compile the profile
recreate_profile() {
  local env_name="$1"
  local active_layer="$2"
  local dest_file=".${env_name}.env"

  printf "Regenerating profile file: %s for layer %s...\n" "$dest_file" "$active_layer"

  generate_ghostty_config
  generate_bat_config

  local joined_lsps=""
  if [ ${#DOTFILE_LSP_SERVERS[@]} -gt 0 ]; then
    joined_lsps=$(IFS=,; echo "${DOTFILE_LSP_SERVERS[*]}")
  fi

  write_profile_header "$env_name" "$active_layer" "$dest_file" "$joined_lsps"
  local -a deploy_files=()

  # Now gather stowed files based on active packages and layers
  for pkg in "${DOTFILE_PACKAGES[@]}"; do
    local -a pkg_files=()
    local pkg_upper
    pkg_upper=$(echo -n "$pkg" | tr '[:lower:]' '[:upper:]' | tr -c '[:alnum:]' '_')

    # Dynamically auto-detect if the package has layers configured via top-level variables
    local is_layered=false
    if declare -p "${pkg_upper}_MINIMAL_LAYER" >/dev/null 2>&1 || declare -p "${pkg_upper}_MINIMAL" >/dev/null 2>&1; then
      is_layered=true
    fi

    if [ "$is_layered" = "true" ]; then
      if declare -p "${pkg_upper}_MINIMAL_LAYER" >/dev/null 2>&1; then
        eval "pkg_files+=( \"\${${pkg_upper}_MINIMAL_LAYER[@]}\" )"
      elif declare -p "${pkg_upper}_MINIMAL" >/dev/null 2>&1; then
        eval "pkg_files+=( \"\${${pkg_upper}_MINIMAL[@]}\" )"
      fi
      if [ "$active_layer" = "STANDARD" ] || [ "$active_layer" = "SPECIFIC" ] || [ "$active_layer" = "ALL" ]; then
        if declare -p "${pkg_upper}_STANDARD_LAYER" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_STANDARD_LAYER[@]}\" )"
        elif declare -p "${pkg_upper}_STANDARD" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_STANDARD[@]}\" )"
        fi
      fi
      if [ "$active_layer" = "SPECIFIC" ] || [ "$active_layer" = "ALL" ]; then
        if declare -p "${pkg_upper}_SPECIFIC_LAYER" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_SPECIFIC_LAYER[@]}\" )"
        elif declare -p "${pkg_upper}_SPECIFIC" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_SPECIFIC[@]}\" )"
        fi
      fi
      if [ "$active_layer" = "ALL" ]; then
        if declare -p "${pkg_upper}_ALL_LAYER" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_ALL_LAYER[@]}\" )"
        elif declare -p "${pkg_upper}_ALL" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_ALL[@]}\" )"
        fi
        if declare -p "${pkg_upper}_FULL_LAYER" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_FULL_LAYER[@]}\" )"
        elif declare -p "${pkg_upper}_FULL" >/dev/null 2>&1; then
          eval "pkg_files+=( \"\${${pkg_upper}_FULL[@]}\" )"
        fi
      fi
    else
      # Standard package: find all files recursively
      if [ -d "$pkg" ]; then
        while IFS= read -r file; do
          if [ "$file" != "" ]; then
            pkg_files+=("$file")
          fi
        done < <(find "$pkg" -type f 2>/dev/null)
      fi
    fi

    # Append this package's active files to the global deploy list
    deploy_files+=("${pkg_files[@]}")
  done

  # Write the complete DEPLOY_FILES array
  printf 'DEPLOY_FILES=(\n' >> "$dest_file"
  for file in "${deploy_files[@]}"; do
    printf '  "%s"\n' "$file" >> "$dest_file"
  done
  printf ')\n' >> "$dest_file"
}

# --- LIFECYCLE MANAGEMENT FLOWS ---
# Handle synchronization of an already active environment symlink
sync_active_environment() {
  printf "Found active '.env' file.\n"
  # Resolve the actual environment name from the existing .env file
  local active_env
  active_env=$(bash -c 'source .env 2>/dev/null && echo "${WORKSPACE_NAME:-}"')
  local active_layer
  active_layer="${LAYER:-$(bash -c 'source .env 2>/dev/null && echo "${DOTFILE_LAYER:-ALL}"')}"

  if [ "$active_env" = "" ] && [ -L ".env" ]; then
    local target_file
    target_file=$(readlink ".env")
    active_env=$(echo "$target_file" | sed -E 's/^\.([^.]+)\.env$/\1/')
  fi

  if [ "$active_env" = "" ]; then
    printf "Error: '.env' exists but active environment name could not be resolved.\n" >&2
    exit 1
  fi

  printf "Active environment detected: '%s' (Layer: '%s')\n" "$active_env" "$active_layer"

  # Ensure .env is a symbolic link rather than a static file
  if [ ! -L ".env" ]; then
    printf "Converting static '.env' file to symbolic link...\n"
    rm -f .env
    ln -s ".${active_env}.env" .env
  fi

  # Check if bootstrap.sh is newer than the active profile, or if LAYER is explicitly specified
  if [ "$CONFIG_FILE" -nt ".${active_env}.env" ] || [ "${LAYER:-}" != "" ]; then
    printf "Changes detected in '%s' (newer than '.%s.env').\n" "$CONFIG_FILE" "$active_env"
    recreate_profile "$active_env" "$active_layer"
    printf "Successfully synchronized '.%s.env' with the latest definitions.\n" "$active_env"
  else
    printf "Profile '.%s.env' is already up to date with '%s'.\n" "$active_env" "$CONFIG_FILE"
  fi
}

# Handle initialization of a new profile
initialize_new_environment() {
  printf "No active '.env' found. Initializing a new workspace profile...\n"

  # Prompt or use env variable for environment name
  local env_name="${ENV:-}"
  if [ "$env_name" = "" ]; then
    printf "Please enter a name for the new environment profile (e.g. dia, minimal, work) [default: dia]: "
    read -r env_name
    env_name="$env_name"
  fi

  if [ "$env_name" = "" ]; then
    printf "Error: Environment name cannot be empty.\n" >&2
    exit 1
  fi

  # Prompt or use env variable for active layer
  local selected_layer="${LAYER:-}"
  if [ "$selected_layer" = "" ]; then
    printf "\nAvailable layers: MINIMAL, STANDARD, SPECIFIC, ALL [default: ALL]\n"
    printf "Please enter active layer to deploy: "
    read -r selected_layer
    selected_layer="${selected_layer:-ALL}"
  fi

  # Create the profile file
  recreate_profile "$env_name" "$selected_layer"

  # Establish the active .env symlink pointing to the new profile
  printf "Linking '.env' to '.%s.env'...\n" "$env_name"
  rm -f .env
  ln -s ".${env_name}.env" .env

  # Set up the .envrc configuration
  printf "Writing 'ENV=%s' to .envrc...\n" "$env_name"
  printf "ENV=%s\n" "$env_name" > .envrc

  if command -v direnv >/dev/null 2>&1; then
    printf "Allowing direnv...\n"
    direnv allow
  fi

  printf "Bootstrap complete! New environment '%s' is now active.\n" "$env_name"
}

main() {
  check_git_status
  if [ -f ".env" ] || [ -L ".env" ]; then
    sync_active_environment
  else
    initialize_new_environment
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
