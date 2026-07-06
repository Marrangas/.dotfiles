# Wiki CLI Tool

A lightweight Bash command-line utility for managing personal wiki/atlas notes and
dotfiles, located at `scripts/.local/bin/wiki`.

## Subcommands

### `link`

Creates absolute symbolic links from files in the current folder (or a specified
source directory) into your central Wiki Atlas directory.

By default, it links **all** files—including hidden (dotted) files—except system and
VCS-related configuration files.

#### Usage

```bash
wiki link [options] [source_dir]
```

- `[source_dir]`: Optional. The folder containing the notes to link (defaults to the
  current working directory `.`).

#### Options

- `-t, --target <dir>`: Override the target wiki atlas directory.
- `-f, --force`: Force overwrite existing files or incorrect symlinks in the target
  directory.
- `-n, --dry-run`: Simulation mode. Shows exactly what would be linked, updated, or
  skipped without making changes.
- `-h, --help`: Display help information for the `link` command.

---

## Configuration via Environment Variables

To avoid specifying the target path with `-t` every time, you can configure a default
target path globally:

### `WIKI_TARGET`

Set the `WIKI_TARGET` environment variable to define your default central Wiki Atlas
directory.

- **Default Value:** `~/Documents/wiki/atlas` (if `WIKI_TARGET` is unset)

#### Setup Example

Add this to your shell configuration file (e.g., `~/.zshrc` or `~/.bashrc`):

```bash
# Define your default target Wiki path
export WIKI_TARGET="$HOME/Documents/wiki/atlas"
```

Once exported, you can simply run:

```bash
wiki link
```

---

## Exclusions (Ignored Files)

To keep your wiki clean, the script automatically ignores the following system and
VCS configurations:

- `.DS_Store` (case-insensitive)
- `.git`
- `.gitignore`
- `.gitattributes`
- `.gitmodules`
- `.stow-local-ignore`

---

## Conflict Resolution

When running `wiki link`, the script handles conflicts safely:

1. **Already Linked:** If a symlink already exists in the target directory pointing
   to the correct file, it skips it quietly with a success status
   (`✓ Already linked`).
2. **Path Conflict:** If a regular file, folder, or symlink pointing elsewhere exists
   at the target location, the script flags a `⚠ Conflict` and skips the file.
3. **Forced Overwrite:** Use the `-f` / `--force` option to overwrite any conflicting
   files or incorrect symlinks and re-establish the new link.
