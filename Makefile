STOW_TARGET := $(HOME)
VERBOSITY := 1

# Folders to exclude from stowing
EXCLUDE := nix .git scripts helpers TODO

.PHONY: all link clean help config scan
STOW_SRC := $(wildcard */)

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
	@echo "Stowing packages..."
	stow --target $(STOW_TARGET) --verbose $(STOW_SRC)

clean:
	@echo "Unstowing packages..."
	stow -D --target $(STOW_TARGET) --verbose $(STOW_SRC)

	@rm -rf $(HOME)/.config/tmux
	@rm -rf $(HOME)/.config/zsh

config:
	@git config core.hooksPath .githooks
	@chmod +x .githooks/pre-commit scripts/manage_plugin.sh
	@echo "Git configuration and scripts ready."
	@# TPM
	@./scripts/manage_plugin.sh "TPM" "https://github.com/tmux-plugins/tpm" "$(HOME)/.config/tmux/plugins/tpm"
	@# Zsh Plugins
	@mkdir -p $(HOME)/.config/zsh
	@./scripts/manage_plugin.sh "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" "$(HOME)/.config/zsh/zsh-autosuggestions"
	@./scripts/manage_plugin.sh "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting" "$(HOME)/.config/zsh/zsh-syntax-highlighting"
	@./scripts/manage_plugin.sh "zsh-transient-prompt" "https://github.com/olets/zsh-transient-prompt" "$(HOME)/.config/zsh/zsh-transient-prompt" "v1"
	@# Helper permissions for the subtree
	@chmod +x helpers/.local/bin/* 2>/dev/null || true
	@echo "All plugins and helpers initialized."

scan:
	@gitleaks detect --verbose
