#!/usr/bin/env bash
# helpers/bootstrap.sh - Bootstraps the workspace environment with layering
# This script is the engine called by 'make bootstrap' to manage profile state.

set -euo pipefail

CONFIG_FILE="helpers/config.sh"

# Ensure we operate relative to the repository root directory
setup(){
	echo "setup"
}
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
  printf "Error: Centralized '%s' not found in %s.\n" "$CONFIG_FILE" "$DOTFILES_DIR" >&2
  exit 1
fi

# Helper function to generate/recreate the environmental profile
recreate_profile() {
  local env_name="$1"
  local active_layer="$2"
  local dest_file=".${env_name}.env"

  printf "Regenerating profile file: %s for layer %s...\n" "$dest_file" "$active_layer"

  # Source helpers/config.sh to get master definitions
  source "./$CONFIG_FILE"

  # Dynamic generation of package-specific configurations if the package is active
  # Ghostty: environment configuration
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

  # Start writing the profile with clean formatting
  printf '# Workspace Environment: %s\n' "$env_name" > "$dest_file"
  printf '# Loaded by Bash, Makefile, and Ansible.\n' >> "$dest_file"
  printf '# Generated automatically from helpers/config.sh.\n\n' >> "$dest_file"
  printf 'WORKSPACE_NAME="%s"\n' "$env_name" >> "$dest_file"
  printf 'DOTFILE_LAYER="%s"\n\n' "$active_layer" >> "$dest_file"

  # Global configurations from helpers/config.sh
  printf 'export DOTFILE_FONT="%s"\n' "${DOTFILE_FONT:-FiraCode Nerd Font}" >> "$dest_file"
  printf 'export DOTFILE_FONT_SIZE="%s"\n' "${DOTFILE_FONT_SIZE:-12}" >> "$dest_file"
  printf 'export DOTFILE_STYLE="%s"\n' "${DOTFILE_STYLE:-dark}" >> "$dest_file"
  printf 'export DOTFILE_THEME="%s"\n' "${DOTFILE_THEME:-catppuccin-mocha}" >> "$dest_file"
  printf 'export DOTFILE_TERMINAL="%s"\n' "${DOTFILE_TERMINAL:-ghostty}" >> "$dest_file"
  printf 'export DOTFILE_SEARCH_TOOL="%s"\n' "${DOTFILE_SEARCH_TOOL:-ripgrep}" >> "$dest_file"
  printf 'export DOTFILE_TERMINAL_OPACITY="%s"\n\n' "${DOTFILE_TERMINAL_OPACITY:-0.85}" >> "$dest_file"

  # Join LSP servers array into a single-line comma-separated string for high-readability environment injection
  local joined_lsps=""
  if [ ${#DOTFILE_LSP_SERVERS[@]} -gt 0 ]; then
    joined_lsps=$(IFS=,; echo "${DOTFILE_LSP_SERVERS[*]}")
  fi
  printf 'export DOTFILE_LSP_SERVERS="%s"\n\n' "$joined_lsps" >> "$dest_file"

  printf 'DOTFILE_PACKAGES=(\n' >> "$dest_file"
  for pkg in "${DOTFILE_PACKAGES[@]}"; do
    printf '  "%s"\n' "$pkg" >> "$dest_file"
  done
  printf ')\n\n' >> "$dest_file"

  # Gather files dynamically
  local -a deploy_files=()

  # Now gather stowed files based on active packages and layers
  for pkg in "${DOTFILE_PACKAGES[@]}"; do
    local -a pkg_files=()

    if [ "$pkg" = "nvim" ]; then
      # nvim has layers; build active files based on selected layer setting
      pkg_files+=("${NVIM_MINIMAL[@]}")

      if [ "$active_layer" = "STANDARD" ] || [ "$active_layer" = "SPECIFIC" ] || [ "$active_layer" = "ALL" ]; then
        pkg_files+=("${NVIM_STANDARD[@]}")
      fi

      if [ "$active_layer" = "SPECIFIC" ] || [ "$active_layer" = "ALL" ]; then
        pkg_files+=("${NVIM_SPECIFIC[@]}")
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

    # Write package-specific file list to the destination file
    local pkg_upper=$(echo -n "$pkg" | tr '[:lower:]' '[:upper:]' | tr -c '[:alnum:]' '_')
    printf 'DOTFILE_%s=(\n' "$pkg_upper" >> "$dest_file"
    for file in "${pkg_files[@]}"; do
      printf '  "%s"\n' "$file" >> "$dest_file"
    done
    printf ')\n\n' >> "$dest_file"
  done

  # Write the complete DEPLOY_FILES array
  printf 'DEPLOY_FILES=(\n' >> "$dest_file"
  for file in "${deploy_files[@]}"; do
    printf '  "%s"\n' "$file" >> "$dest_file"
  done
  printf ')\n' >> "$dest_file"
}

# MAIN LIFECYCLE

# 1. Check for uncommitted changes in the repository
if [ "$(git status --porcelain 2>/dev/null)" != "" ]; then
  printf "Notice: You have uncommitted changes in your repository.\n"
  printf "Committing your workspace captures active configs and autodocuments them!\n\n"
fi

# 2. Automatically configure and set up Git hooks
printf "Configuring Git hooks...\n"
git config core.hooksPath .githooks
mkdir -p .githooks
if [ -d ".githooks" ]; then
  chmod +x .githooks/* 2>/dev/null || true
fi

if [ -f ".env" ] || [ -L ".env" ]; then
  printf "Found active '.env' file.\n"

  # Resolve the actual environment name from the existing .env file
  ACTIVE_ENV=$(bash -c 'source .env 2>/dev/null && echo "${WORKSPACE_NAME:-}"')
  # Allow command line LAYER override, else fallback to existing layer setting
  ACTIVE_LAYER="${LAYER:-$(bash -c 'source .env 2>/dev/null && echo "${DOTFILE_LAYER:-ALL}"')}"

  if [ "$ACTIVE_ENV" = "" ]; then
    # Try resolving via target of symbolic link if .env is a symlink
    if [ -L ".env" ]; then
      TARGET_FILE=$(readlink ".env")
      # Extract name between leading '.' and trailing '.env'
      ACTIVE_ENV=$(echo "$TARGET_FILE" | sed -E 's/^\.([^.]+)\.env$/\1/')
    fi
  fi

  if [ "$ACTIVE_ENV" = "" ]; then
    printf "Error: '.env' exists but active environment name could not be resolved.\n" >&2
    exit 1
  fi

  printf "Active environment detected: '%s' (Layer: '%s')\n" "$ACTIVE_ENV" "$ACTIVE_LAYER"

  # Ensure .env is a symbolic link rather than a static file
  if [ ! -L ".env" ]; then
    printf "Converting static '.env' file to symbolic link...\n"
    rm -f .env
    ln -s ".${ACTIVE_ENV}.env" .env
  fi

  # Compare modification dates using the "-nt" (newer than) file operator, or force if LAYER is explicitly specified
  if [ "$CONFIG_FILE" -nt ".${ACTIVE_ENV}.env" ] || [ "${LAYER:-}" != "" ]; then
    printf "Changes detected in '%s' (newer than '.%s.env').\n" "$CONFIG_FILE" "$ACTIVE_ENV"

    # Recreate the profile
    recreate_profile "$ACTIVE_ENV" "$ACTIVE_LAYER"
    printf "Successfully synchronized '.%s.env' with the latest config.sh definitions.\n" "$ACTIVE_ENV"
  else
    printf "Profile '.%s.env' is already up to date with '%s'.\n" "$ACTIVE_ENV" "$CONFIG_FILE"
  fi

else
  printf "No active '.env' found. Initializing a new workspace profile...\n"

  # Prompt or use env variable for environment name
  DEFAULT_NAME="${ENV:-}"
  if [ "$DEFAULT_NAME" = "" ]; then
    printf "Please enter a name for the new environment profile (e.g. dia, minimal, work) [default: dia]: "
    read -r ENV_NAME
    ENV_NAME="${ENV_NAME:-dia}"
  else
    ENV_NAME="$DEFAULT_NAME"
  fi

  if [ "$ENV_NAME" = "" ]; then
    printf "Error: Environment name cannot be empty.\n" >&2
    exit 1
  fi

  # Prompt or use env variable for active layer
  DEFAULT_LAYER="${LAYER:-}"
  if [ "$DEFAULT_LAYER" = "" ]; then
    printf "\nAvailable layers: MINIMAL, STANDARD, SPECIFIC, ALL [default: ALL]\n"
    printf "Please enter active layer to deploy: "
    read -r SELECTED_LAYER
    SELECTED_LAYER="${SELECTED_LAYER:-ALL}"
  else
    SELECTED_LAYER="$DEFAULT_LAYER"
  fi

  # Create the profile file
  recreate_profile "$ENV_NAME" "$SELECTED_LAYER"

  # Establish the active .env symlink pointing to the new profile
  printf "Linking '.env' to '.%s.env'...\n" "$ENV_NAME"
  rm -f .env
  ln -s ".${ENV_NAME}.env" .env

  # Set up the .envrc configuration
  printf "Writing 'ENV=%s' to .envrc...\n" "$ENV_NAME"
  printf "ENV=%s\n" "$ENV_NAME" > .envrc

  if command -v direnv >/dev/null 2>&1; then
    printf "Allowing direnv...\n"
    direnv allow
  fi

  printf "Bootstrap complete! New environment '%s' is now active.\n" "$ENV_NAME"
fi
