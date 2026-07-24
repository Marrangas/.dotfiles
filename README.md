dotdotdot ... or with the gliph ...

- [[dotfiles]]

- [ ] layers?
- [ ] secrets
- [ ] ansible

## ansible

- [ ] how to backup this and expose publicly check for pre commit secrets ... and
      hoock as a bootstrap...
- [ ] footprint
- [ ] testing performance

- [ ] testing
  - phone
  - tablet
  - workstation
- [ ] when push redeploy ansible
- [x] being able to clean
- [ ] maquetar dispositivos
- [ ] using/ migrate nvim to visual studio just to know what you are using aprender a
      usar el visual studio de la forma más parecida... la ia, creo que es una forma
      muy diferente de leer, y de editar. hay que saber o al menos terner en cuenta
      cuales son los archivos que estás tocando tu y los que va a tocar la ia?
- [ ] expose variables
  - https://github.com/adapta-project/adapta-gtk-theme
  - [themes](https://github.com/mbadolato/iTerm2-Color-Schemes/tree/a56897c3e031cb1be715706b7b25df860d5fc0a5)
  - [nvim theme](https://www.opendesktop.org/p/1154707/)
- [ ] make the jira accessible (know your coworkers)
- [ ] investigate git patterns

## understand

- MAKEFILE
  - this should be with files and folders
- BASH
  - you suck at programming
- VIM
- LUA

---

- [x] add layers for the sparse checkout ([Architecture Guide](neovim-layering.md))

## Layered & Environment-by-Default Deployment

This workspace is **Layered by Default** and **Environment-by-Default**. This means
standard operations read your active configuration automatically, with optional
overrides via environment variables or Makefile arguments.

### 1. Default Behavior

By default, running `make link`, `make sparse`, or `make unlink` will:

1. Auto-detect the active profile configured in `config.yml` (using the `profile:`
   key, e.g. `profile: workspace`).
2. Load the corresponding environment configuration from `.workspace-$(ENV).env`
   (e.g. `.workspace-workspace.env` which is linked to your active profile
   `.workspace-dia.env`).
3. Deploy or clean files based on the active **layers** (e.g., `MINIMAL`, `STANDARD`,
   `SPECIFIC`) configured in that `.env` file using standard Bash indexed arrays.

### 2. Overriding Configurations

You can override standard configurations instantly on the command line by passing the
`ENV` variable. This will load the custom `.workspace-$(ENV).env` profile instead of
the default:

```bash
# Display the active configuration and files for the default profile
make info-layered

# Display active configuration for the minimal profile
make info-layered ENV=minimal

# Deploy layers for a specific environment (e.g. minimal)
make link ENV=minimal

# Configure Git sparse-checkout for a specific environment
make sparse ENV=minimal

# Clean and unlink files for a specific environment
make unlink ENV=minimal
```

### 3. Pure-Bash Zero-Dependency Engine

The deployment relies on native `/bin/bash` features (such as indirect expansion) to
parse the indexed arrays inside `.workspace-$(ENV).env` files. This keeps the
bootstrapping lifecycle completely independent of external dependencies or
third-party interpreters.

---

- [ ] better secret cli

---

- [ ] git commit hooks
- [ ] headers and templates
- [ ] make norm and auto headers to check for formating and autodocumentation
      elements + a todo documentations to go to with links as a markdown or vim so it
      is like a pane of glass for navegation (static tools)

---

- [ ] nvim with ia (use deep seek)
- lsp the python bien
  - de htmx
  - de html
  - de css

- [[git-hooks]] y cuales son las tools que quiero para git...(poder analizarlo, no se
  yo si esto me interesa hacerlo a mi, no son git-tools? o es un comienzo)
  - cuando hago push de un cambio deben de sincronicarse? git-Ops
  - linter de yaml
  - secrets...
  - formating

- [[ansible]]

## mac defaults

hide the status bar in mac

```sh
defaults write NSGlobalDomain _HIHideMenuBar -bool true
killall Finder
defaults write NSGlobalDomain _HIHideMenuBar -bool false
```

- if mac, linux, or windows
- MAC https://cbrgm.net/post/2021-05-5-setup-macos/
- terminal

## packages

- FreeRDP Free rdp para Lynux: https://miloserdov.org/?p=4514 Free rdp manuals
  configuration:
  https://github.com/awakecoding/FreeRDP-Manuals/blob/master/Configuration/FreeRDP-Configuration-Manual.markdown
  Free rdp manuals user:
  https://github.com/awakecoding/FreeRDP-Manuals/blob/master/User/FreeRDP-User-Manual.markdown
- FortyClient
- NVIM
- ghostscript (or inventariar)
- tree-sitter

- [[git]]
- fzf
- packer
- rclone
- fd
- pgadmin
- pulumi
- pyenv
- fuse
- diagnostics
- cmp
- lsp
- git subtree add --prefix helpers/.local/bin
- git@github.com:Marrangas/bash-mrgs-lib.git master --squash
- brew install starship bash-completion@2
- python
- golang
- zsh
- lsd bat eza tldr
- starship
- brew tap FelixKratz/formulae
- brew install borders
- gitleaks
- trufflehog
- xz git zsh bash curl cmake coreutils gettext lua luarocks ansible
- postgresql sqlite redis

- hcl2json terraform terraform-docs driftctl tfsec tofu docker ansible infracost
  pulumi act kubectl
- mtr nmap nginx rclone ipcalc openssh openssl
- pyenv perl
- direnv zsh-powerlevel10k gh csvq jq
- pandoc imagemagick ffmpeg chafa catimg
- neovim p7zip git-lfs tmux fzf ripgrep parallel sed direnv ssh stow

## future

- [ ] firebox config (maybe I do not like even firefox anymore)
      https://github.com/sobolevn/dotfiles/blob/master/firefox/user-overrides.js

## patrones de diseño

- [ ] modularidad
- [ ] reusabilidad
- granularidad
