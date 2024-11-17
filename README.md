This repo stores my personal neovim config and related files.

## Installation

_Recursively_ clone this repo into something like `~/dotfiles/dotnvim`,
then add a symlink `~/.config/nvim` to your local clone of this repo.  For
example:

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
