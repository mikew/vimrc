# vimrc

## Installation

```shell
./install.sh
```

## Commands

```vim
" Helper to clean / install / update plugins in one fell swoop.
PlugSync
```

## Mappings

```
C-F          Search all files
⌘⇧F          Search all files
<leader>n    Toggle file drawer
C-P          File finder
⌘P           File finder
⌘T           File finder
C-/          Toggle comment
⌘/           Toggle comment
gd           Goto definition
K            Goto definition
gy           Goto type definition
gi           Goto implementation
gr           Show references
gh           Show hover information
<leader>rn   Rename
<leader>ac   Show actions
⌘.           Show actions
<space>a     Show all diagnostics
<space>o     Find symbol in current file
```

## Requirements

Tools:

- ripgrep
- fd
- fzf
- git

Linting / Formatting:

- eslint_d
- prettier_d_slim

Completion:

- nodejs
