This repo stores my personal Neovim config and related files.

## Installation

_Recursively_ clone this repo _and its submodules_ into something like
`~/dotfiles/dotnvim`, then add a symlink `~/.config/nvim` to your local
clone of this repo.  For example:

```bash
mkdir -p ~/dotfiles
cd ~/dotfiles
git clone --recurse-submodules https://github.com/fardaniqbal/dotnvim
# Or git clone --recurse-submodules git@github.com:fardaniqbal/dotnvim.git
# to clone through ssh.
mkdir -p ~/.config
rm -f ~/.config/nvim
ln -s ../dotfiles/dotnvim ~/.config/nvim
```

After installing the setup, open Neovim and run `:PackerSync` to
download/update plugins.

## Optional Components

The following components aren't required for this setup to work, but
they'll be used if they're installed.

* [`ripgrep`](https://github.com/BurntSushi/ripgrep) - you'll need this for
  [`telescope's`](https://github.com/nvim-telescope/telescope.nvim)
  `grep-string` (bound to `<leader>ps`) to search for strings.
* `npm` - you'll need this for some of the language servers.
