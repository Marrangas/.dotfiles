# Makefile for layered dotfiles deployment using GNU Stow & Git sparse-checkouts.

# Read active profile and packages using our helper script
PROFILE  := $(shell python3 scripts/parse_config.py profile)
PACKAGES := $(shell python3 scripts/parse_config.py packages)

# Default stowed packages (can be overridden via make link PKGS="pkg1 pkg2")
PKGS ?= $(PACKAGES)

.PHONY: default info link unlink sparse config test-env test-live

default:
	@echo "Available Makefile targets:"
	@echo "  make info       - Show currently active profile and exposed variables"
	@echo "  make link       - Link active dotfiles (or specific packages, e.g. make link PKGS=\"git nvim\")"
	@echo "  make unlink     - Unlink active dotfiles (or specific packages, e.g. make unlink PKGS=\"git nvim\")"
	@echo "  make sparse     - Configure Git sparse-checkout for the active profile"
	@echo "  make config     - Set up git configurations, hooks, and download plugins"
	@echo "  make test-env   - Build and run the dotfiles deployment in a clean, isolated Docker test container"
	@echo "  make test-live  - Deploy the dotfiles inside Docker and drop into an interactive bash shell"

info:
	@python3 scripts/parse_config.py info

link:
	@mkdir -p $(HOME)/.config/dotfiles
	@python3 scripts/parse_config.py env > $(HOME)/.config/dotfiles/env
	@python3 scripts/parse_config.py template
	@echo "Stowing packages: $(PKGS)"
	stow --target $(HOME) --dotfiles --verbose 1 $(PKGS)

unlink:
	@echo "Unstowing packages: $(PKGS)"
	stow -D --target $(HOME) --dotfiles --verbose 1 $(PKGS)

sparse:
	@echo "Configuring Git sparse-checkout for profile $(PROFILE)..."
	@if ! git sparse-checkout list >/dev/null 2>&1; then \
		git sparse-checkout init --cone; \
	fi
	@git sparse-checkout set scripts/ ansible/ $(PACKAGES)

config:
	@chmod +x scripts/.local/bin/helpers/* scripts/parse_config.py 2>/dev/null || true
	@git config core.hooksPath .githooks
	@echo "Fetching latest agnostic hooks from remote lib-gittools..."
	@mkdir -p .githooks
	@# Natively fetch the agnostic hooks from the remote git tools repo directly into the hidden .githooks folder
	@git archive --remote=git@git.sr.ht:~marrangas/gittools master githooks | tar -xf - --strip-components=1 -C .githooks 2>/dev/null
	@chmod +x .githooks/* 2>/dev/null || true
	@echo "Git configurations, scripts, and standard hooks are ready."
	@# Initialize plugins if stowed
	@if echo " $(PACKAGES) " | grep -q " tmux "; then \
		scripts/.local/bin/helpers/manage_plugin.sh "TPM" "https://github.com/tmux-plugins/tpm" $(HOME)/.config/tmux/plugins/tpm; \
	fi
	@if echo " $(PACKAGES) " | grep -q " zsh "; then \
		mkdir -p $(HOME)/.config/zsh; \
		scripts/.local/bin/helpers/manage_plugin.sh "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" $(HOME)/.config/zsh/zsh-autosuggestions; \
		scripts/.local/bin/helpers/manage_plugin.sh "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting" $(HOME)/.config/zsh/zsh-syntax-highlighting; \
		scripts/.local/bin/helpers/manage_plugin.sh "zsh-transient-prompt" "https://github.com/olets/zsh-transient-prompt" $(HOME)/.config/zsh/zsh-transient-prompt "v1"; \
	fi

test-env:
	@docker build -f ansible/Dockerfile -t dotfiles-ansible-test .
	@docker run -it --rm dotfiles-ansible-test

test-live:
	@docker build -f ansible/Dockerfile -t dotfiles-ansible-test .
	@docker run -it --rm dotfiles-ansible-test bash -c "ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --connection=local && exec bash"
