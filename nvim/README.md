# Usage 
This is a personal nvim config, everything already install.


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
:TSInstall python
```

## Some Mapping :

- `<leader>` = space

- `p` - dont copy replaced text
- `<leader>p` - does

- `<leader>R` - find and replace current word
- `<leader>rr` - find and replace current word from the current position

- `J`&`K` - move down/up the selected line

