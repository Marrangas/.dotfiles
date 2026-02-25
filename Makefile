STOW_TARGET := $(HOME)
VERBOSITY := 1

# Folders to exclude from stowing (internal management only)
# Removed 'scripts' and 'helpers' from exclusion so their .local/bin contents get stowed
EXCLUDE := nix .git TODO

# Use Makefile's native functions to handle spaces and exclusions correctly
# 1. Get all directories: $(wildcard */)
# 2. Filter out management folders: $(filter-out $(EXCLUDE), ...)
# 3. Wrap each in quotes to handle spaces: $(foreach pkg, ..., "$(pkg)")
PACKAGES := $(filter-out $(EXCLUDE), $(patsubst %/,%,$(wildcard */)))
STOW_SRC := $(foreach pkg,$(PACKAGES),"$(pkg)")

.PHONY: all link clean help config scan

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "- all:      Same as 'link'"
	@echo "- link:     Link dotfiles to $(STOW_TARGET) using GNU Stow"
	@echo "- clean:    Unlink dotfiles from $(STOW_TARGET)"
	@echo "- config:   Set up git configuration (e.g., hooksPath)"
	@echo "- scan:     Scan repository history for secrets (gitleaks)"

all: config link

link:
	@echo "Stowing packages: $(PACKAGES)"
	stow --target $(STOW_TARGET) --dotfiles --verbose $(VERBOSITY) $(STOW_SRC)

clean:
	@echo "Unstowing packages: $(PACKAGES)"
	stow -D --target $(STOW_TARGET) --dotfiles --verbose $(VERBOSITY) $(STOW_SRC)

	@rm -rf $(HOME)/.config/tmux
	@rm -rf $(HOME)/.config/zsh

config:
	@git config core.hooksPath .githooks
	@chmod +x .githooks/pre-commit scripts/.local/bin/* helpers/manage_plugin.sh 2>/dev/null || true
	@echo "Git configuration and scripts ready."
	@# TPM
	@./helpers/manage_plugin.sh "TPM" "https://github.com/tmux-plugins/tpm" "$(HOME)/.config/tmux/plugins/tpm"
	@# Zsh Plugins
	@mkdir -p $(HOME)/.config/zsh
	@./helpers/manage_plugin.sh "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" "$(HOME)/.config/zsh/zsh-autosuggestions"
	@./helpers/manage_plugin.sh "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting" "$(HOME)/.config/zsh/zsh-syntax-highlighting"
	@./helpers/manage_plugin.sh "zsh-transient-prompt" "https://github.com/olets/zsh-transient-prompt" "$(HOME)/.config/zsh/zsh-transient-prompt" "v1"
	@# Helper permissions
	@chmod +x helpers/.local/bin/* 2>/dev/null || true
	@echo "All plugins and helpers initialized."

scan:
	@gitleaks detect --verbose
