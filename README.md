This repo stores my personal Neovim config and related files.

## Prerequisites

Make sure you have the following components installed on your system and in
your `$PATH` before using this Neovim config:

* Neovim, **at least** version 0.12
* If you're on Windows, you'll need Git Bash (included in
  [Git](https://git-scm.com/)'s Windows installer) or MinGW/MSYS2.
* Git
* Curl
* Unzip (command-line tool)
* Python, **at least** version 3.9
  - You'll need `pip` and `pynvim`:
    ```bash
    for py in python python3; do
      type -p "$py" >/dev/null || continue
      "$py" -m pip install --user --upgrade pip
      "$py" -m pip install --user --use-feature=truststore pynvim
      "$py" -m pip install --user --upgrade pynvim
    done
    ```
* [`ripgrep`](https://github.com/BurntSushi/ripgrep) - you'll need this for
  [`telescope`](https://github.com/nvim-telescope/telescope.nvim)'s
  `grep-string` (and possibly other telescope functions).
* [`fd`](https://github.com/sharkdp/fd) - to improve `telescope`'s file
  finder performance.
* `npm` - you'll need this for some of the language servers.
  - Run `npm install -g neovim`.  If you don't have root/admin access, run
    `echo "prefix=$HOME/local/npm-packages" >> ~/.npmrc` to make future
    `npm install -g` commands install npm packages to your home directory.
  - Re-run `npm install -g neovim` any time you upgrade Neovim.
* `make`, `gcc`, and the usual suspects to build optional plugins.
* For Java integration, you'll need the following executables installed:
  `java`, `javac`, `mvn`, `ant`, etc.  For example, on MacOS using `brew`:
  ```bash
  brew install oracle-jdk
  brew install mvn
  brew install ant
  ```
  Note that Java integration requires **at least JDK >= 21**.

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
#
# !!! Stop here if you're on Windows !!!

mkdir -p ~/.config
rm -f ~/.config/nvim
ln -s ../dotfiles/dotnvim ~/.config/nvim
```

### Windows Installation
On Windows you can do the above using Git Bash or MSYS 2, _but with the
following differences_:
1.  You must enable _non-admins_ to create symlinks.  See the following for
    how to do this:
    - [Enable developer mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development)
    - [Allow non-admins to create symlinks](https://stackoverflow.com/a/76632011)
    - [Tell git to use symlinks](https://stackoverflow.com/a/59761201)
2.  The symlinks must be placed under `$LOCALAPPDATA` rather than
    `~/.config`:
    ```bash
    # Do this after following the above installation steps, _but stop after
    # the`git clone ...` step_:
    rm -f "$LOCALAPPDATA/nvim"
    ln -s ~/dotfiles/dotnvim "$LOCALAPPDATA/nvim"
    ```

## Experimental

You'll need JDTLS (Java language server) for Java LSP support.  This should
get installed automatically by Mason.  However, we can _optionally_ use the
[`install-jdtls.sh`](install-jdtls.sh) script included in this repo to have
a more customized install.  I originally wrote this script while trying to
make JDTLS work, but at this point the config works with the auto-installed
JDTLS, so this script isn't really needed anymore.  I'm still leaving the
script here though for future reference.
