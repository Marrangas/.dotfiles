# Makefile for layered dotfiles deployment using GNU Stow & Git sparse-checkouts.

SHELL := /bin/bash
PROFILE := $(shell grep "^profile:" config.yml | awk '{print $$2}')
ENV ?= $(PROFILE)

# Read active profile and packages using our helper script
# PACKAGES := $(shell python3 scripts/parse_config.py packages)

# Default stowed packages (can be overridden via make link PKGS="pkg1 pkg2")
PKGS ?= $(PACKAGES)

.PHONY: help info link unlink sparse config test-env test-live
.SILENT: help info

help:
	echo "Available Makefile targets:"
	echo "  make info           - Show active workspace environment and layered files"
	echo "  make link           - Link active dotfiles (uses layered profile if present, else fallback to Stow)"
	echo "  make unlink         - Unlink active dotfiles (uses layered profile if present, else fallback to Stow)"
	echo "  make sparse         - Configure Git sparse-checkout (uses layered profile if present, else fallback to standard)"
	echo "  make config         - Set up git configurations, hooks, and download plugins"
	echo "  make test-env       - Build and run the dotfiles deployment in a clean, isolated Docker test container"
	echo "  make test-live      - Deploy the dotfiles inside Docker and drop into an interactive bash shell"

info:
	if [ ! -f .$(ENV).env ]; then \
		echo "Error: .$(ENV).env not found."; \
		exit 1; \
	fi
	echo "========================================================="
	echo "Active Workspace Profile: $(ENV)"
	echo "========================================================="
	bash -c ' \
		source .$(ENV).env && \
		echo "Workspace Name: $$WORKSPACE_NAME" && \
		echo "Active Layers:  $${DEPLOY_LAYERS[*]}" && \
		echo "Files to be deployed:" && \
		for layer in "$${DEPLOY_LAYERS[@]}"; do \
			echo "  [Layer: $$layer]" && \
			var="LAYER_$${layer}[@]"; \
			for file in "$${!var}"; do \
				echo "    - $$file"; \
			done; \
		done \
	'

link:
	@if [ -f .$(ENV).env ]; then \
		echo "Deploying files for layers in .$(ENV).env..."; \
		bash -c ' \
			source .$(ENV).env && \
			for layer in "$${DEPLOY_LAYERS[@]}"; do \
				var="LAYER_$${layer}[@]"; \
				for file in "$${!var}"; do \
					target_path=$$(echo "$$file" | cut -d/ -f2-); \
					echo "Linking: $$file -> $(HOME)/$$target_path"; \
					mkdir -p "$$(dirname "$(HOME)/$$target_path")"; \
					ln -sf "$$(pwd)/$$file" "$(HOME)/$$target_path"; \
				done; \
			done \
		'; \
		echo "Deployment complete."; \
	else \
		mkdir -p $(HOME)/.config/dotfiles; \
		echo "Stowing packages: $(PKGS)"; \
		stow --target $(HOME) --dotfiles --verbose 1 $(PKGS); \
	fi

unlink:
	@if [ -f .$(ENV).env ]; then \
		echo "Removing linked files for layers in .$(ENV).env..."; \
		bash -c ' \
			source .$(ENV).env && \
			for layer in "$${DEPLOY_LAYERS[@]}"; do \
				var="LAYER_$${layer}[@]"; \
				for file in "$${!var}"; do \
					target_path=$$(echo "$$file" | cut -d/ -f2-); \
					if [ -L "$(HOME)/$$target_path" ]; then \
						echo "Unlinking: $(HOME)/$$target_path"; \
						rm "$(HOME)/$$target_path"; \
						rmdir "$$(dirname "$(HOME)/$$target_path")" 2>/dev/null || true; \
					fi; \
				done; \
			done \
		'; \
		echo "Removal complete."; \
	else \
		echo "Unstowing packages: $(PKGS)"; \
		stow -D --target $(HOME) --dotfiles --verbose 1 $(PKGS); \
	fi

sparse:
	@if [ -f .$(ENV).env ]; then \
		echo "Configuring Git sparse-checkout for layers in .$(ENV).env..."; \
		if ! git sparse-checkout list >/dev/null 2>&1; then \
			git sparse-checkout init --cone; \
		fi; \
		bash -c ' \
			source .$(ENV).env && \
			files=() && \
			for layer in "$${DEPLOY_LAYERS[@]}"; do \
				var="LAYER_$${layer}[@]"; \
				for file in "$${!var}"; do \
					files+=("$$file"); \
				done; \
			done && \
			echo "Setting sparse checkout list with $${#files[@]} files..." && \
			git sparse-checkout set scripts/ "$${files[@]}" \
		'; \
	else \
		echo "Configuring Git sparse-checkout for profile $(PROFILE)..."; \
		if ! git sparse-checkout list >/dev/null 2>&1; then \
			git sparse-checkout init --cone; \
		fi; \
		git sparse-checkout set scripts/ ansible/ $(PACKAGES); \
	fi

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
