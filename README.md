## Layered & Environment-by-Default Deployment

This workspace is **Layered by Default** and **Environment-by-Default**. This means
standard operations read your active configuration automatically, with optional
overrides via environment variables or Makefile arguments.

### Default Behavior

By default, running `make link`, `make sparse`, or `make unlink` will:

1. Auto-detect the active profile configured in `config.yml` (using the `profile:`
   key, e.g. `profile: workspace`).
2. Load the corresponding environment configuration from `.workspace-$(ENV).env`
   (e.g. `.workspace-workspace.env` which is linked to your active profile
   `.workspace-dia.env`).
3. Deploy or clean files based on the active **layers** (e.g., `MINIMAL`, `STANDARD`,
   `SPECIFIC`) configured in that `.env` file using standard Bash indexed arrays.

### Overriding Configurations

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

### File Tracking Subtleties: Layer Arrays vs Stow Ignore

To maintain a perfectly controlled, sparse, and layerable dotfiles repository, this
setup intentionally separates **Workspace Tracking** from **Symlink Deployment**.
This can seem subtle but is crucial for how the system safely scales:

- **Workspace Tracking (`build.sh` Layer Arrays)**: Every single file within a
  layered package (e.g., `nvim/`) **must** be explicitly registered within its
  appropriate layer array in `build.sh` (like `NVIM_MINIMAL_LAYER`).
  - **Why?** The validation script (`make validate` / `./verify_config.sh`) strictly
    enforces this to prevent "ghost" configurations that are modified/added locally
    without being explicitly tracked in a layer. Furthermore, the Makefile
    dynamically uses these arrays to generate the `git sparse-checkout` list,
    checking out _only_ the specific files requested by your active profile.

- **Symlink Deployment (`.stow-local-ignore`)**: Sometimes, a file belongs to a
  package logically (and must be tracked via `build.sh`) but _should not_ be
  symlinked into your home directory (e.g., `README.md`, or local formatters like
  `.stylua.toml`).
  - **Why?** We declare these exceptions in `.stow-local-ignore` via regex (e.g.,
    `(^|/)\.stylua\.toml$`).
  - **The Result:** `make sparse` will keep `.stylua.toml` visible on the filesystem
    because it is safely tracked in `build.sh` layers, allowing you to edit the
    configuration—but `make link` (via GNU Stow) will silently ignore it, preventing
    it from polluting your actual `~/.config/nvim/` runtime folder.

### Self-Healing Lifecycle (`make re`)

The `make re` command handles completely regenerating a layered workspace without
requiring interactive prompts:

1. **Validates**: Runs `./verify.sh` to ensure no "ghost" files were left unaccounted
   for.
2. **Preserves**: Extracts the currently active workspace (`WORKSPACE_NAME`) and
   layer (`DOTFILE_LAYER`) directly from your active `.env`.
3. **Cleans**: Reverts all symlinks and aggressively runs `git clean -fdx` to nuke
   everything untracked/ignored (which also wipes the current `.env` tracking
   symlink).
4. **Rebuilds & Links**: Transparently injects the preserved variables back into
   `./build.sh` to recreate the layer definitions without prompting, re-applies the
   sparse checkout (`make sparse`), and re-Stows the symlinks.
