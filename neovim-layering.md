# Layered Neovim Deployment Architecture

This document defines the **layered deployment architecture** for Neovim within this
dotfiles repository. It explains how to deploy Neovim across different target
environments—ranging from minimal headless servers to full-featured developer
workstations—using **Git Sparse-Checkouts** and **GNU Stow**.

## arch

Our dotfiles repository operates on a single principle: **Pay only for what you
use.** A heavy IDE configuration running inside a remote staging container or VM
slows down boot times, breaks on missing compilers, and litters the home directory
with unneeded binaries.

We separate our configurations into **3 distinct conceptual layers**:

```
                           ┌───────────────────────────┐
                           │   1. MINIMAL (Server)     │
                           │   - Core configuration    │
                           │   - Keymaps & options     │
                           │   - Boot time < 15ms      │
                           └─────────────┬─────────────┘
                                         │ (Git Sparse-Checkout)
                                         ▼
                           ┌───────────────────────────┐
                           │   2. STANDARD (Full IDE)  │
                           │   - Treesitter syntax     │
                           │   - LSPs & Autocomplete   │
                           │   - Linting & Formatting  │
                           └─────────────┬─────────────┘
                                         │ (Git Sparse-Checkout)
                                         ▼
                           ┌───────────────────────────┐
                           │   3. SPECIFIC (Workspace) │
                           │   - Xanadu Wiki (Linking) │
                           │   - Local AI (Ollama)     │
                           │   - Secrets & Decryption  │
                           └───────────────────────────┘
```

## 2. Directory & Component Mapping

Our plugin structure uses `lazy.nvim`'s import model
(`require("lazy").setup({ { import = "plugins" } })`). This enables a plug-and-play
architecture: **if a plugin configuration file is not present on disk, Neovim ignores
it entirely without throwing errors.**

### Tier 1: The Minimal Layer (Server Profile)

- **Target:** CI/CD runners, headless servers, staging VMs.
- **External Dependencies:** None. Works without `gcc`, `make`, `node`, `python`, or
  `unzip`.
- **Active Files:**
  ```text
  nvim/.config/nvim/init.lua               # Dynamic guard block & bootstrap
  nvim/.config/nvim/lua/config/autocmd.lua  # Base automation
  nvim/.config/nvim/lua/config/options.lua  # Core vim settings (dark mode, gaps)
  nvim/.config/nvim/lua/config/keymaps.lua  # Fundamental terminal-navigation bindings
  nvim/.config/nvim/lua/plugins/mini.lua    # Mini.nvim essentials (lightweight buffers)
  ```

### Tier 2: The Standard Layer (Developer Profile)

- **Target:** standard software engineering environments.
- **External Dependencies:** `gcc`/`clang`, `git`, `ripgrep`, `npm`/`go`/`python`
  (for language servers).
- **Active Files (Minimal + Standard):**
  ```text
  nvim/.config/nvim/lua/plugins/treesitter.lua   # High-fidelity code highlighting
  nvim/.config/nvim/lua/plugins/lsp.lua          # Language Server Protocol setup
  nvim/.config/nvim/lua/plugins/completion.lua   # Engine completions (cmp)
  nvim/.config/nvim/lua/plugins/picker.lua       # folke/snacks.nvim fuzzy lists
  nvim/.config/nvim/lua/plugins/format.lua       # Auto-formatters (conform)
  nvim/.config/nvim/lua/plugins/lint.lua         # Static linters (nvim-lint)
  nvim/.config/nvim/lua/plugins/comments.lua     # Inline commenting helpers
  nvim/.config/nvim/lua/plugins/git.lua          # Neogit & Gitsigns interfaces
  nvim/.config/nvim/lua/plugins/quickfix.lua     # Enhanced location handling
  nvim/.config/nvim/lua/plugins/ui.lua           # Statusline and buffer styles
  nvim/.config/nvim/lua/plugins/undo.lua         # Persistent undo history tree
  ```

### Tier 3: The Specific Layer (Workspace & Personal Knowledge Profile)

- **Target:** Primary development machines, local Apple Silicon workstations.
- **External Dependencies:** Local Ollama runtime, Obsidian Vault path.
- **Active Files (Minimal + Standard + Specific):**
  ```text
  nvim/.config/nvim/lua/plugins/markdown.lua     # Xanadu Wiki searching & [[wiki-link]] formatting
  nvim/.config/nvim/lua/plugins/ia.lua           # Local AI coding assistant prompts
  nvim/.config/nvim/lua/plugins/sec.lua          # Decryption key loaders and dotfile secure layers
  nvim/.config/nvim/lua/plugins/debug.lua        # Interactive debugger adapters (DAP)
  ```

---

## 3. Git Sparse-Checkout Deployment Recipes

Run these recipes in your target shells to checkout _only_ the directories required
for the chosen layers.

### Recipe A: Minimal Server Deployment (Headless VMs)

```bash
# Initialize sparse checkout in cone mode
git sparse-checkout init --cone

# Include only the minimal Neovim engine files
git sparse-checkout set \
    "scripts/" \
    "nvim/.config/nvim/init.lua" \
    "nvim/.config/nvim/lua/config/" \
    "nvim/.config/nvim/lua/plugins/mini.lua"

# Use GNU Stow to link the minimal configuration
stow --target "$HOME" --dotfiles --verbose 1 nvim
```

### Recipe B: Standard Developer Deployment

```bash
# Initialize sparse checkout
git sparse-checkout init --cone

# Include standard files, while explicitly excluding workspace specifics
git sparse-checkout set \
    "scripts/" \
    "nvim/.config/nvim/init.lua" \
    "nvim/.config/nvim/lua/config/" \
    "nvim/.config/nvim/lua/plugins/"

# Exclude Specific/Workspace configs (Git sparse-checkout supports negative matching)
# (Alternatively, simply delete/unlink these files on the server)
rm -f "$HOME/.config/nvim/lua/plugins/markdown.lua"
rm -f "$HOME/.config/nvim/lua/plugins/ia.lua"
```

### Recipe C: Full Personal Workspace Deployment

```bash
# Reset sparse checkout to pull everything
git sparse-checkout disable

# Stow all active packages
make link
```

---

## 4. Defensive Bootstrapping (`init.lua` Guard)

To ensure the minimal environment doesn't throw errors when plugins are missing or
compilers are absent, we add defensive checks in Neovim's bootstrapping lifecycle
(`nvim/.config/nvim/init.lua`):

```lua
-- Detect compiler availability dynamically
local has_compiler = vim.fn.executable('gcc') == 1 or vim.fn.executable('clang') == 1

-- Global flag for downstream plugin adjustments
vim.g.nvim_minimal_mode = false

if not has_compiler then
    -- We are on a thin VM/server. Prevent compilers from running
    vim.g.nvim_minimal_mode = true

    -- Strip down lazy.nvim default setup to avoid fetching missing heavy parsers
    -- e.g. Disable automatic installs of treesitter packages
    vim.g.markdown_fenced_languages = {}
end
```

Then, in any heavy standard/specific plugin file (e.g.,
`lua/plugins/treesitter.lua`):

```lua
if vim.g.nvim_minimal_mode then
    -- Instantly tell lazy.nvim to bypass loading this file on minimal hosts
    return {}
end

return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    -- ... rest of configuration ...
}
```

---

## 5. Deployment Lifecycle Workflow

When setting up a new environment, use this unified command cycle:

1.  **Clone the Repo Sparsely:**
    ```bash
    git clone --filter=blob:none --no-checkout git@github.com:marrangas/.dotfiles.git
    cd .dotfiles
    ```
2.  **Define Profile in `config.yml`:** Set the active profile (e.g. `minimal` or
    `workspace`) inside your local `config.yml`.
3.  **Run Makefile Automations:**
    - `make sparse`: Invokes git sparse checkout to only pull folders configured for
      your profile.
    - `make link`: Uses GNU Stow to seamlessly symlink your stowed folders into your
      system's `$HOME/.config`.
