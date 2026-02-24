- [ ] vim tutor part 2 has some things that are interesting
- [ ] how does the fucking syntax work
- [ ] understand and make lua plugin
    - https://learnxinyminutes.com/docs/lua/
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html
- [ ] always learn how to read further apart form the llm
      MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
      which is very useful when you're not exactly sure of what you're looking for.
- [ ] use ctags
  - https://kulkarniamit.github.io/whatwhyhow/howto/use-vim-ctags.html
- [ ] quickfix vs location vs edit ...(interact with those in vanilla vim)
    - https://www.youtube.com/watch?v=AuXZA-xCv04
    - vimgrep /{gerp pattern} {files pattern}
    - vim
    - grep -r (usando el commando externo)
    - vim unimpared (learn or discover...)
- [ ] crear diccionarios o skills de cosas... manen tus datos limpitos y tus listas
  bien agrupadas en la era de la ia (this is hacking setup by default... make
your things as easy to your fingertips)
- [ ] activar spelling en el idioma que toca... ins completion
- git 
  - next change // next hunk
  - stage por partes...
  - blame ...
- [ ] seems rubi is a good thing to learn specially for fast dev on startup...
basecamp was succesfull why not me (dsl languages are a bad start for the future but you can do stuff fast)


## leader
-- See `:help mapleader` -- NOTE: Must happen before
-- plugins are loaded (otherwise wrong leader will be used) } require('lazy').setup { --

## lsp
'bashls',
'shellharden',
'shellcheck',

'gopls',
'pylsp',

'terraform-ls',
'tflint',
'tfsec',

'ansible-language-server',
-- 'yalls',

'htmx-lsp',
'html-lsp',
'templ',
'prettierd',
'cssls',
'eslint-lsp',
'typescript-language-server',
'tailwindcss-language-server',
'markdown-oxide',

## repos and my own explanation
-- 'mbbill/undotree',
-- 'vim-utils/vim-man',
-- 'numToStr/Comment.nvim'
-- 'tpope/vim-sleuth',
-- 'tpope/vim-markdown',

-- markwown
-- 'yangzhixuan/bipandoc',

-- ia + avante. 
-- 'github/copilot.vim'
-- run: Copilot setup || Copilot enable

-- html live server without the shit { 'barrett-ruth/live-server.nvim', build = 'npm add -g live-server', cmd = {
'LiveServerStart', 'LiveServerStop' }, config = true, },
-- terraform
-- 'hashicorp/terraform-ls'
-- 'terraform-linters/tflint',
-- 'aquasecurity/vim-tfsec'

## color formating
['@markup.heading.1.markdown'] = { fg = cp.red, style = { 'bold' } },
['@markup.heading.2.markdown'] = { fg = cp.peach, style = { 'bold' } },
['@markup.heading.3.markdown'] = { fg = cp.green, style = { 'bold' } },
['@markup.heading.4.markdown'] = { fg = cp.sapphire, style = { 'bold' } },
['@markup.heading.5.markdown'] = { fg = cp.lavender, style = { 'bold' } },
['@markup.heading.6.markdown'] = { fg = cp.mauve, style = { 'bold' } },

-- Frontmatter (YAML Metadata) - Separación Robusta
['@markup.metadata.markdown'] = { fg = cp.overlay1 },             -- Los marcadores ---
['@punctuation.delimiter.markdown'] = { fg = cp.overlay1 },       -- Alternativa para ---
['@property.yaml'] = { fg = cp.blue, style = { 'bold' } },        -- Claves
['@variable.member.yaml'] = { fg = cp.blue, style = { 'bold' } }, -- Claves (alternativa)
['@punctuation.delimiter.yaml'] = { fg = cp.rosewater },          -- El colon :
['@string.yaml'] = { fg = cp.green },                             -- Valores de texto
['@string.unquoted.yaml'] = { fg = cp.green },                    -- Valores sin comillas
['@number.yaml'] = { fg = cp.peach },                             -- Valores numéricos
['@boolean.yaml'] = { fg = cp.peach },                            -- Valores booleanos
['@type.yaml'] = { fg = cp.yellow },
['@label.yaml'] = { fg = cp.blue },

-- Elementos Inline con más contraste
['@markup.raw.markdown_inline'] = { fg = cp.teal },                 -- Código `inline` en Teal (Cian)
['@markup.list.markdown'] = { fg = cp.yellow, style = { 'bold' } }, -- Balas en Amarillo
['@markup.strong.markdown_inline'] = { fg = cp.maroon, style = { 'bold' } },
['@markup.italic.markdown_inline'] = { fg = cp.sky, style = { 'italic' } },

-- UI de Obsidian y Enlaces
ObsidianTag = { fg = cp.pink, style = { 'bold' } },
ObsidianCheckbox = { fg = cp.blue },
ObsidianRefText = { fg = cp.mauve, style = { 'bold' } },
['@markup.link.label.markdown_inline'] = { fg = cp.blue, style = { 'bold' } },
['@markup.link.url.markdown_inline'] = { fg = cp.rosewater, style = { 'italic' } },

-- Tablas
['@markup.table.header.markdown'] = { fg = cp.sky, style = { 'bold' } },
['@punctuation.special.markdown_inline'] = { fg = cp.lavender }, -- Los pipes |




errides = {
function(cp)
rn {
-- Headers: Variedad cromática para distinguir niveles
['@markup.heading.1.markdown'] = { fg = cp.red, style = { 'bold' } },
['@markup.heading.2.markdown'] = { fg = cp.peach, style = { 'bold' } },
['@markup.heading.3.markdown'] = { fg = cp.green, style = { 'bold' } },
['@markup.heading.4.markdown'] = { fg = cp.sapphire, style = { 'bold' } },
['@markup.heading.5.markdown'] = { fg = cp.lavender, style = { 'bold' } },
['@markup.heading.6.markdown'] = { fg = cp.mauve, style = { 'bold' } },

-- Frontmatter (YAML Metadata) - Separación Robusta
['@markup.metadata.markdown'] = { fg = cp.overlay1 },             -- Los marcadores ---
['@punctuation.delimiter.markdown'] = { fg = cp.overlay1 },       -- Alternativa para ---
['@property.yaml'] = { fg = cp.blue, style = { 'bold' } },        -- Claves
['@variable.member.yaml'] = { fg = cp.blue, style = { 'bold' } }, -- Claves (alternativa)
['@punctuation.delimiter.yaml'] = { fg = cp.rosewater },          -- El colon :
['@string.yaml'] = { fg = cp.green },                             -- Valores de texto
['@string.unquoted.yaml'] = { fg = cp.green },                    -- Valores sin comillas
['@number.yaml'] = { fg = cp.peach },                             -- Valores numéricos
['@boolean.yaml'] = { fg = cp.peach },                            -- Valores booleanos
['@type.yaml'] = { fg = cp.yellow },
['@label.yaml'] = { fg = cp.blue },

-- Elementos Inline con más contraste
['@markup.raw.markdown_inline'] = { fg = cp.teal },                 -- Código `inline` en Teal (Cian)
['@markup.list.markdown'] = { fg = cp.yellow, style = { 'bold' } }, -- Balas en Amarillo
['@markup.strong.markdown_inline'] = { fg = cp.maroon, style = { 'bold' } },
['@markup.italic.markdown_inline'] = { fg = cp.sky, style = { 'italic' } },

-- UI de Obsidian y Enlaces
ObsidianTag = { fg = cp.pink, style = { 'bold' } },
ObsidianCheckbox = { fg = cp.blue },
ObsidianRefText = { fg = cp.mauve, style = { 'bold' } },
['@markup.link.label.markdown_inline'] = { fg = cp.blue, style = { 'bold' } },
['@markup.link.url.markdown_inline'] = { fg = cp.rosewater, style = { 'italic' } },

-- Tablas
['@markup.table.header.markdown'] = { fg = cp.sky, style = { 'bold' } },
['@punctuation.special.markdown_inline'] = { fg = cp.lavender }, -- Los pipes |



## docs

## packages
- brew install ghostscript (or inventariar)
- brew install tree-sitter

- fzf
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
-  xz git zsh bash curl cmake coreutils gettext lua luarocks ansible
-  postgresql sqlite redis

- hcl2json terraform terraform-docs driftctl tfsec tofu docker ansible infracost
  pulumi act kubectl
-  mtr nmap nginx rclone ipcalc openssh openssl
-  pyenv perl
-  direnv zsh-powerlevel10k gh csvq jq
-  pandoc imagemagick ffmpeg chafa catimg
-  neovim p7zip git-lfs tmux fzf ripgrep parallel sed direnv ssh stow



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
- install fd
- install fzf
- install python ecosystem (pyenv, pip, venv, etc) and understand it deeply

## backup

la capa que todos estamos pensando: arquitectura 3-2-1

- origenes:
  - github (my own repos)
  - one drive
  - google drive

1. local...
2. aws
3. fisico en mi disco NAS // el fucking cluster desatendido (automatizarlo)
4. fragmentaria en cada elemento que debería de estar en los orignes que toca...

- disco duro local (el fucking cluster) (en discos con formato interoperativo)
- s3
- aws no está en mi casa pero mi disco sí (no dependo de internet donde esté mi casa)


## elements of the repo
- makefile
- githooks and github flow
  -  gitleaks
