# Makefile for layered dotfiles deployment using GNU Stow & Git sparse-checkouts.

SHELL := /bin/bash

# Read active profile and packages using our helper script
# PACKAGES := $(shell python3 scripts/parse_config.py packages)

# Default stowed packages (can be overridden via make link PKGS="pkg1 pkg2")
PKGS ?= $(PACKAGES)

.PHONY: help ifo bootstrap config link unlink sparse clean test live
.SILENT: help info bootstrap config clean test live

help:
	echo "Available Makefile targets:"
	echo "  make bootstrap    Initialize a new workspace profile and link to .envrc for direnv auto-loading"
	echo "  make info         Show active workspace environment and layered files"
	echo "  make link         Link active dotfiles (uses layered profile if present, else fallback to Stow)"
	echo "  make unlink       Unlink active dotfiles (uses layered profile if present, else fallback to Stow)"
	echo "  make sparse       Configure Git sparse-checkout (uses layered profile if present, else fallback to standard)"
	echo "  make clean        Unlink all active files and completely nuke all untracked/ignored workspace configurations"
	echo "  make config       Set up git configurations, hooks, and download plugins"
	echo "  make test         Build and run the dotfiles deployment in a clean, isolated Docker test container"
	echo "  make try          Deploy the dotfiles inside Docker and drop into an interactive bash shell"

info:
	@if [ ! -f .env ]; then \
		echo "Error: .env not found. Run 'make bootstrap' first."; \
		exit 1; \
	fi
	@bash -c ' \
		source .env && \
		echo -e "Active Workspace Profile: $$WORKSPACE_NAME" && \
		echo -e "Active Layer Setting:     $$DOTFILE_LAYER" && \
		echo -e "Active Packages:          $${DOTFILE_PACKAGES[*]}\n" && \
		echo "Files to be deployed ($${#DEPLOY_FILES[@]} files):" && \
		for file in "$${DEPLOY_FILES[@]}"; do \
			echo "    - $$file"; \
		done \
	'

bootstrap:
	./helpers/bootstrap.sh

config:
	git config core.hooksPath .githooks
	echo "Fetching latest agnostic hooks from remote lib-gittools..."
	mkdir -p .githooks
	# Natively fetch the agnostic hooks from the remote git tools repo directly into the hidden .githooks folder
	git archive --remote=git@git.sr.ht:~marrangas/gittools master githooks | tar -xf - --strip-components=1 -C .githooks 2>/dev/null || true
	chmod +x .githooks/* 2>/dev/null || true
	echo "Git configurations, scripts, and standard hooks are ready."

link: sparse
	@if [ ! -f .env ]; then \
		echo "Error: .env not found. Run 'make bootstrap' first."; \
		exit 1; \
	fi
	@echo "Deploying files for active packages from .env..."
	@bash -c ' \
		source .env && \
		for file in "$${DEPLOY_FILES[@]}"; do \
			target_path=$$(echo "$$file" | cut -d/ -f2-); \
			parent_dir=$$(dirname "$(HOME)/$$target_path"); \
			if [ -L "$$parent_dir" ]; then \
				echo "Removing old stow symlink directory: $$parent_dir"; \
				rm -f "$$parent_dir"; \
			fi; \
			echo "Linking: $$file -> $(HOME)/$$target_path"; \
			mkdir -p "$$parent_dir"; \
			ln -sf "$$(pwd)/$$file" "$(HOME)/$$target_path"; \
		done \
	'
	@echo "Deployment complete."

unlink:
	@if [ -f .env ]; then \
		echo "Removing linked files for active packages from .env..."; \
		bash -c ' \
			source .env && \
			for file in "$${DEPLOY_FILES[@]}"; do \
				target_path=$$(echo "$$file" | cut -d/ -f2-); \
				if [ -L "$(HOME)/$$target_path" ]; then \
					echo "Unlinking: $(HOME)/$$target_path"; \
					rm "$(HOME)/$$target_path"; \
					rmdir "$$(dirname "$(HOME)/$$target_path")" 2>/dev/null || true; \
				fi; \
			done \
		'; \
		echo "Removal complete."; \
	else \
		echo "No active .env profile found. Unstowing fallback packages..."; \
		stow -D --target $(HOME) --dotfiles --verbose 1 $(PKGS) 2>/dev/null || true; \
	fi

sparse:
	@if [ -f .env ]; then \
		if [ -n "$$(git status --porcelain)" ]; then \
			echo "Notice: You have uncommitted changes in your repository. Committing your workspace captures active configs!"; \
		fi; \
		echo "Configuring Git sparse-checkout for active package files (Non-Cone Layered Mode)..."; \
		if git sparse-checkout list >/dev/null 2>&1; then \
			git sparse-checkout init --no-cone; \
		else \
			git sparse-checkout init --no-cone; \
		fi; \
		bash -c ' \
			source .env && \
			files=() && \
			for file in "$${DEPLOY_FILES[@]}"; do \
				files+=("/$$file"); \
			done && \
			echo "Setting sparse checkout list with $${#DEPLOY_FILES[@]} active files..." && \
			git sparse-checkout set "/Makefile" "/helpers/" "/tests/" "/.gitignore" "/.stow-local-ignore" "/.*.env" "$${files[@]}" \
		'; \
	fi

clean: unlink
	@echo "Nuking local directory untracked/ignored contents to leave no trace..."
	@git clean -fdx
	@echo "Local cleanup complete."


test-env:
	@docker build -f ansible/Dockerfile -t dotfiles-ansible-test .
	@docker run -it --rm dotfiles-ansible-test

test-live:
	@docker build -f ansible/Dockerfile -t dotfiles-ansible-test .
	@docker run -it --rm dotfiles-ansible-test bash -c "ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --connection=local && exec bash"
