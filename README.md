dotdotdot ... or with the gliph ...

- [[dotfiles]]
- [ ] ansible
- [ ] nvim with ia (use deep seek)
- [ ] add layers for the sparse checkout
- [ ] rclone setup
- [ ] how to backup this and expose publicly
- [ ] better secret cli
- [ ] footprint
- [ ] testing performance
- [ ] testing
  - phone
  - tablet
  - workstation
- [ ] when push redeploy ansible
- [ ] being able to clean
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

- maquetar dispositivos

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
