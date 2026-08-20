# Usage 
This is a personal nvim config.


# Credit 
- [ Neovim ](https://neovim.io/)
- [ NvChad distribution ](https://github.com/NvChad/NvChad.git)

# Installation

## Install Neovim

[ Install here ](https://github.com/neovim/neovim/blob/master/INSTALL.md)

Exemple on Mac os :
```bash
brew install neovim
```
**also consider**
```bash
brew install jesseduffield/lazygit/lazygit
```

## Make a backup of your current Neovim files:
```bash
# required
mv ~/.config/nvim{,.bak}

# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

## Or - Uninstall current Neovim config :
``` bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

Then open up neovim and let everything install.

if you need to re-install / update you can use `:MasonInstallAll` (then U to update if needed)

### Install treesitter syntax
Restart Neovim and install the treesitter syntax <br>
Exemple :
```
:TSInstall python rust 
```

## Some Mapping :

- `<leader>` = space

**[x]**
- `p` - dont copy replaced text
- `<leader>p` - does

**[v]**
- `J`&`K` - move down/up the selected line

**[n, v]**
- `<leader>R` - find and replace current word
- `<leader>rr` - find and replace current word from the current position

**[n]**
- `<leader>G` - goto tabnew
- `<leader>U` - Undo tree
- `<leader>ds` - telescope document_symbols
- `<leader>ws` - telescope workspace_symbols
- `<leader>lg` - LazyGit


