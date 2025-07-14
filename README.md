```bash
git clone git@github.com-marrangas:Marrangas/.dotfiles "$home/.dotfiles"
```

```bash
parallel stow -D {} ::: $(ls -1d */)
parallel stow -R {} ::: $(ls -1d */)
```

- [ ] refactor nvim to be minimal
- [ ] automae the installation of tmux
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      tmux run the tmux...
- [ ] make this testing
- [ ] work with one or more than one git submodules
- [ ] nix workflow `nix-env --delete-generations old`
