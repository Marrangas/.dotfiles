#!/usr/bin/env bash
# verify_config.sh - Verifies that build.sh is in sync with the filesystem
# This script ensures that all stowed folders are registered and all layered files are documented.

set -euo pipefail

# Ensure we operate relative to the repository root directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Source the bootstrap script (loads configurations without running main due to sourcing guard)
source build.sh

# List of folders in the repository root to exclude from stowing
EXCLUDE=(
  "nix"
  ".git"
  "TODO"
  "helpers"
  "tests"
  "scripts"
  "ansible"
)

errors=0

# 1. Verify that all stowed folders in the root are defined in DOTFILE_PACKAGES
for item in */; do
  # Remove trailing slash
  pkg="${item%/}"
  
  # Check if in EXCLUDE list
  is_excluded=false
  for excl in "${EXCLUDE[@]}"; do
    if [ "$excl" = "$pkg" ]; then
      is_excluded=true
      break
    fi
  done
  
  if [ "$is_excluded" = "true" ]; then
    continue
  fi
  
  # Check if listed in DOTFILE_PACKAGES
  is_active=false
  for active_pkg in "${DOTFILE_PACKAGES[@]}"; do
    if [ "$active_pkg" = "$pkg" ]; then
      is_active=true
      break
    fi
  done
  
  if [ "$is_active" = "false" ]; then
    printf "Error: Folder '%s' exists in root but is missing from DOTFILE_PACKAGES in build.sh.\n" "$pkg" >&2
    errors=$((errors + 1))
  fi
done

# 2. For each layered package, verify that all files under its directory are accounted for in its layer arrays
for pkg in "${DOTFILE_PACKAGES[@]}"; do
  pkg_upper=$(echo -n "$pkg" | tr '[:lower:]' '[:upper:]' | tr -c '[:alnum:]' '_')
  
  # Check if the package is layered (defines MINIMAL array or MINIMAL_LAYER array)
  is_layered=false
  if declare -p "${pkg_upper}_MINIMAL_LAYER" >/dev/null 2>&1 || declare -p "${pkg_upper}_MINIMAL" >/dev/null 2>&1; then
    is_layered=true
  fi
  
  if [ "$is_layered" = "true" ]; then
    # Package has layers; recursively find all files in the package directory
    if [ -d "$pkg" ]; then
      while IFS= read -r file; do
        if [ -z "$file" ]; then
          continue
        fi
        
        # Check if the file is listed in any of the layer arrays for this package
        is_mapped=false
        
        # We check both standard formats with/without _LAYER suffix
        for array_suffix in "_MINIMAL_LAYER" "_MINIMAL" "_STANDARD_LAYER" "_STANDARD" "_SPECIFIC_LAYER" "_SPECIFIC" "_ALL_LAYER" "_ALL" "_FULL_LAYER" "_FULL"; do
          array_name="${pkg_upper}${array_suffix}"
          if declare -p "$array_name" >/dev/null 2>&1; then
            # Read elements of the array and check if they match the file
            eval "for elem in \"\${${array_name}[@]}\"; do
              if [ \"\$elem\" = \"$file\" ]; then
                is_mapped=true
                break 2
              fi
            done"
          fi
        done
        
        if [ "$is_mapped" = "false" ]; then
          printf "Error: File '%s' exists in layered package '%s' but is missing from all layer arrays in build.sh.\n" "$file" "$pkg" >&2
          errors=$((errors + 1))
        fi
      done < <(find "$pkg" -type f 2>/dev/null)
    fi
  fi
done

if [ "$errors" -gt 0 ]; then
  printf "\nValidation failed with %d error(s). Please update build.sh.\n" "$errors" >&2
  exit 1
fi

printf "Success: All packages and layered files are fully synchronized and accounted for!\n"
exit 0
