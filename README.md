- use ctags
  - https://kulkarniamit.github.io/whatwhyhow/howto/use-vim-ctags.html

- git 
  - next change // next hunk
  - stage por partes...
  - blame ...
- puede que el treesitter me ralentice el codigo... como es posible analizar el
  performance y si me es util o no?
- use
- vim:
  - quickfix vs location vs edit ...(interact with those in vanilla vim)
    - https://www.youtube.com/watch?v=AuXZA-xCv04
    - vimgrep /{gerp pattern} {files pattern}
    - vim
    - grep -r (usando el commando externo)
    - vim unimpared (learn or discover...)
  - fzf
  - diagnostics
  - cmp
  - lsp


- [ ] autocommands for my fucking wiki (cuando edito, o directamente sync con
  obsidian?? para tener en hidden)
- [ ] the autocommands could be usefull to automante a lot of stuff which is the
  thin I do most of the time... use my routines to learn (this could also be
  use to trigger my own ecosystem in wiki... can it be interchangeable?? --> )

I do not know how to test: maybe this is what gets me to get interested in it: https://github.com/nvim-neotest/neotest

make your tooling better inside the containers man
https://github.com/mutagen-io/mutagen

deploy and manage your dotfiles (separate them so you can create  a fucking dev container??)

en luagar de tener una lualine, a lo mejor tiene sentido:
nvim file data show lsp, size, filetype, file status, size, errors
- hacer un buen setup con el fucking netrw... no esta mal, aunque sea muy feo

- [ ] gsutil performance optimizations
- [ ] fuse / fuse mount in linux (wrapper) -> See `helpers/.local/bin/cloud-mount`
- [ ] htop -> Modernized in `htop/.config/htop/htoprc`
- [ ] Kube kubernetes config -> Modular pattern in `kube/.kube/configs/`
- [x] bat -> Cleaner config in `bat/.config/bat/config`
- [ ] packer
- [ ] pgadmin
- [ ] prettierd
- [ ] pulumi
- [ ] pyenv
- [ ] rclone -> Systemd automation in `rclone/.config/systemd/user/`
- [x] vim -> Minimal config in `vim/.config/vim/vimrc`
- [ ] ansible
la capa que todos estamos pensando: arquitectura 3-2-1

- origenes:
  - github (my own repos)
  - one drive
  - google drive

- install fd
- install fzf
- install python ecosystem (pyenv, pip, venv, etc) and understand it deeply

seems rubi is a good thing to learn specially for fast dev on startup...
basecamp was succesfull why not me (dsl languages are a bad start for the future but you can do stuff fast)

## 3 copias totales

1. local...
2. aws
3. fisico en mi disco NAS // el fucking cluster desatendido (automatizarlo)
4. fragmentaria en cada elemento que debería de estar en los orignes que toca...

## 2 soportes

- disco duro local (el fucking cluster) (en discos con formato interoperativo)
- s3

## 1 en el exterior

- aws no está en mi casa pero mi disco sí (no dependo de internet donde esté mi casa)
- **low power cluster is needed** [low power](??)


mkdir -p helpers/.local

git subtree add --prefix helpers/.local/bin
git@github.com:Marrangas/bash-mrgs-lib.git master --squash

brew install starship bash-completion@2

con esto puedo hacerme una lista de lo que quiero aprender y de lo que ahora mismo no
se instalations:

- brew tap FelixKratz/formulae
- brew install borders
- gitleaks
- trufflehog

  xz git zsh bash curl cmake coreutils gettext lua luarocks ansible

  postgresql sqlite redis

  hcl2json terraform terraform-docs driftctl tfsec tofu docker ansible infracost
  pulumi act kubectl

  mtr nmap nginx rclone ipcalc openssh openssl

  pyenv perl

  # python

  # golang

  # zsh

  lsd bat eza tldr

  # starship

  direnv zsh-powerlevel10k gh csvq jq

  pandoc imagemagick ffmpeg chafa catimg

  neovim p7zip git-lfs tmux fzf ripgrep parallel sed direnv ssh stow

# JMT Dotfiles

Personal configuration files (dotfiles) managed with **GNU Stow**.

## 🚀 Quick Start

1. **Clone**:
   ```bash
   git clone git@github.com-marrangas:Marrangas/.dotfiles.git ~/.dotfiles
   ```
2. **Setup**: Configures the git hooks and other local environment settings.
   ```bash
   make config
   ```
3. **Deploy**: Use GNU Stow to symlink configurations to your `$HOME`.
   ```bash
   make link
   ```

## 🏗 Architecture

This repository is structured for **GNU Stow**:

- Each directory (e.g., `nvim/`, `zsh/`) represents a "package".
- Running `make link` symlinks the contents of these packages to your home directory.
- `Makefile` automates the inclusion/exclusion of directories.

## 🛠 Makefile Commands

- `make link`: Symlink all enabled packages to your `$HOME`.
- `make clean`: Remove symlinks for all packages.
- `make config`: Set up local git hooks and configuration.
- `make scan`: Run a security audit on the entire repository history using
  `gitleaks`.

## 🛡 Security

This repository includes a `gitleaks` pre-commit hook (via `make config`) to ensure
no sensitive tokens or keys are accidentally committed to the dotfiles.

---

_Created: 2025-11-29 | Refined: 2026-02-19_
