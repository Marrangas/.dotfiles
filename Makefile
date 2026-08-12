# Folders to exclude from stowing (internal management only)
# Use Makefile's native functions to handle spaces and exclusions correctly
# TODO: this is the magic of makefile do not waste it
SHELL := /bin/bash
EXCLUDE := nix .git TODO helpers tests
PACKAGES := $(filter-out $(EXCLUDE), $(patsubst %/,%,$(wildcard */)))

.PHONY: help info build link sparse clean re test live validate
.SILENT: help info build link sparse clean re test live validate

help:
	echo "Available Makefile targets:"
	echo "  make info         Show active workspace environment and layered files"
	echo "  make build        Initialize a new workspace profile and link to .seed for direnv auto-loading"
	echo "  make link         Link active dotfiles (uses layered profile if present, else fallback to Stow)"
	echo "  make sparse       Configure Git sparse-checkout (uses layered profile if present, else fallback to standard)"
	echo "  make clean        Unlink all active files and completely nuke all untracked/ignored workspace configurations"
	echo "  make validate     Verify that all active packages and layered files are fully synchronized"
	echo "  make re           Validate, clean, rebuild the active profile (preserving workspace/layer), and link"
	echo "  make test         Build and run the dotfiles deployment in a clean, isolated Docker test container"
	echo "  make live         Deploy the dotfiles inside Docker and drop into an interactive bash shell"

info:
	@if [ ! -f .env ]; then \
		echo "Error: .env not found. Run 'make build' first."; \
		exit 1; \
	fi
	@bash -c ' \
		source .env && \
		active_pkgs=("$${DOTFILE_PACKAGES[@]}") && \
		source helpers/bootstrap.sh && \
		echo -e "Active Workspace Profile: $$WORKSPACE_NAME" && \
		echo -e "Active Layer Setting:     $$DOTFILE_LAYER" && \
		echo -e "Active Packages:          $${active_pkgs[*]}\n" && \
		echo "Available Extra Packages:" && \
		extra=$$(comm -13 <(echo "$${active_pkgs[*]}" | tr " " "\n" | sort) <(echo "$${DOTFILE_PACKAGES[*]}" | tr " " "\n" | sort)) && \
		if [ -n "$$extra" ]; then \
			echo "$$extra" | sed "s/^/  + /"; \
		else \
			echo "  None (all configured packages are active)"; \
		fi \
	'
config:
	git config core.hooksPath .githooks
	echo "Fetching latest agnostic hooks from remote lib-gittools..."
	mkdir -p .githooks
	# Natively fetch the agnostic hooks from the remote git tools repo directly into the hidden .githooks folder
	git archive --remote=git@git.sr.ht:~marrangas/gittools master githooks | tar -xf - --strip-components=1 -C .githooks 2>/dev/null || true
	chmod +x .githooks/* 2>/dev/null || true
	echo "Git configurations, scripts, and standard hooks are ready."

build: config
	./build.sh

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
			git sparse-checkout set "/Makefile" "/README.md" "/build.sh" "/verify.sh" "/tests/" "/.gitignore" "/.stow-local-ignore" "/.*.env" "$${files[@]}" \
		'; \
	fi

link: sparse
	@if [ ! -f .env ]; then \
		echo "Error: .env not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Deploying visible packages:"
	@for pkg in $(PACKAGES); do \
		echo "  - $$pkg"; \
	done
	stow --target $(HOME) --dotfiles --verbose 1 $(PACKAGES)
	@echo "Deployment complete."


clean:
	@if [ -f .env ]; then \
		echo "Removing linked files for active packages..."; \
		stow -D --target $(HOME) --dotfiles --verbose 1 $(PACKAGES); \
	fi
	git clean -fdx --exclude=build.sh --exclude=verify.sh --exclude=.githooks/pre-commit

validate:
	./verify.sh

re: validate
	@if [ -f .env ]; then \
		echo "Extracting active environment profile and layer configuration..."; \
		WORKSPACE=$$(bash -c 'source .env 2>/dev/null && echo "$$WORKSPACE_NAME"'); \
		LAYER=$$(bash -c 'source .env 2>/dev/null && echo "$$DOTFILE_LAYER"'); \
		echo "Preserving Workspace: $$WORKSPACE (Layer: $$LAYER)"; \
		$(MAKE) clean; \
		echo "Rebuilding profile for $$WORKSPACE (Layer: $$LAYER)..."; \
		ENV=$$WORKSPACE LAYER=$$LAYER ./build.sh; \
	else \
		echo "No active .env found, performing a fresh clean and build..."; \
		$(MAKE) clean; \
		$(MAKE) build; \
	fi
	$(MAKE) link

test:
	@docker build -f ansible/Dockerfile -t dotfiles-ansible-test .
	@docker run -it --rm dotfiles-ansible-test

live:
	@docker build -f ansible/Dockerfile -t dotfiles-ansible-test .
	@docker run -it --rm dotfiles-ansible-test bash -c "ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --connection=local && exec bash"
