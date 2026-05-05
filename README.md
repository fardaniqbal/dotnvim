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
      "$py" -m pip install --help 2>&1 | grep -q 'break-system-packages' &&
      pyflags='--break-system-packages' || pyflags=''
      "$py" -m pip install $pyflags --user --upgrade pip
      "$py" -m pip install $pyflags --user --use-feature=truststore pynvim
      "$py" -m pip install $pyflags --user --upgrade pynvim
    done
    ```
* [`ripgrep`](https://github.com/BurntSushi/ripgrep) - you'll need this for
  [`telescope`](https://github.com/nvim-telescope/telescope.nvim)'s
  `grep-string` (and possibly other telescope functions).
  - On Windows, you can install using Winget by running the following in
    `cmd.exe`:
    ```cmd
    winget install BurntSushi.ripgrep.MSVC
    ```
  - On Mac OS, you can use install using Homebrew:
    ```bash
    brew install ripgrep
    ```
    Or with MacPorts:
    ```bash
    sudo port install ripgrep
    ```
  - On Linux, install using your favorite package manager.  Details in
    ripgrep's [README](https://github.com/burntsushi/ripgrep#installation).
* [`fd`](https://github.com/sharkdp/fd) - to improve `telescope`'s file
  finder performance.
  - On Windows, you can install using Winget by running the following in
    `cmd.exe`:
    ```cmd
    winget install sharkdp.fd
    ```
  - On Mac OS, you can use install using Homebrew:
    ```bash
    brew install fd
    ```
    Or with MacPorts:
    ```bash
    sudo port install fd
    ```
  - On Linux, install using your favorite package manager.  Details in
    fd's [README](https://github.com/sharkdp/fd#on-ubuntu).
* `npm` - you'll need this for some of the language servers.
  - On Windows, you can install by running the following **in Git Bash or
    MinGW/MSYS2** (replace `PREFIX=...` with your preferred install
    location):
    ```bash
    PREFIX="$HOME/local"
    mkdir -p "$PREFIX" &&
    cd "$PREFIX" &&
    curl -kL "https://nodejs.org/dist/v24.15.0/node-v24.15.0-win-x64.zip -O &&
    unzip node-v24.15.0-win-x64.zip" &&
    /bin/rm -f node-v24.15.0-win-x64.zip &&
    node_dir="$(cd "$(ls -1trd node-* | tail -n1)" && pwd)" &&

    # Add node, npm, npx, etc to PATH _only_ if it's not already there:
    win_path_munge() {
      local winpath="$(powershell.exe -NoProfile -ExecutionPolicy Bypass \
        -Command "\$([Environment]::GetEnvironmentVariable('PATH','User'))")" &&
      ([[ ";$winpath;" == *";$(cygpath -wl "$1");"* ]] ||
      powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
        "[Environment]::SetEnvironmentVariable('PATH',\"$(cygpath -wl "$1");$winpath\",'User');")
    }
    win_path_munge "$node_dir" && echo 'SUCCESS' || echo 'FAIL'
    ```
  - Run `npm install -g neovim`.  If you don't have root/admin access, run
    `echo "prefix=$HOME/local/npm-packages" >> ~/.npmrc` to make future
    `npm install -g` commands install npm packages to your home directory.
  - Re-run `npm install -g neovim` any time you upgrade Neovim.
* `make`, `gcc`, and the usual suspects to build optional plugins.
  - You can use `zig` as a drop-in replacement if you're on Windows and
    don't want to set up MinGW/MSYS2.  See [Installing Zig on
    Windows](#installing-zig-on-windows) below for details.
* `tree-sitter` and `tree-sitter-cli` - for accurate syntax highlighting.
  - On Windows: run the following **in Git Bash or MinGW/MSYS2** (replace
    `PREFIX=...` with your preferred install location):
    ```bash
    PREFIX="$HOME/local/bin"
    mkdir -p "$PREFIX" &&
    cd "$PREFIX" &&
    curl -kL "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.8/tree-sitter-cli-windows-x64.zip" -O &&
    unzip tree-sitter-cli-windows-x64.zip &&
    /bin/rm -f tree-sitter-cli-windows-x64.zip &&

    # Add tree-sitter to PATH _only_ if it's not already there:
    win_path_munge() {
      local winpath="$(powershell.exe -NoProfile -ExecutionPolicy Bypass \
        -Command "\$([Environment]::GetEnvironmentVariable('PATH','User'))")" &&
      ([[ ";$winpath;" == *";$(cygpath -wl "$1");"* ]] ||
      powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
        "[Environment]::SetEnvironmentVariable('PATH',\"$(cygpath -wl "$1");$winpath\",'User');")
    }
    win_path_munge "$(pwd)" && echo 'SUCCESS' || echo 'FAIL'
    ```
  - On MacOS using `brew`:
    ```bash
    brew install tree-sitter
    brew install tree-sitter-cli
    ```
  - On Linux: **TODO**
* If using Windows, install PowerShell 7 (i.e., `pwsh.exe`) if you don't
  already have it.  **This is _NOT_ the PowerShell included with Windows**.
  Run the following commands in a Windows command prompt (based on [these
  instructions](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.6)):
    ```cmd
    echo Y | winget search --id Microsoft.PowerShell --exact
    winget install --id Microsoft.PowerShell --source winget
    ```
* Install a "nerd font" _and_ configure your terminal to use it.
  - On Windows using PowerShell 7 (i.e., `pwsh.exe`):
    ```pwsh
    # Run the following ONCE to install the module.
    Install-PSResource -Name NerdFonts -TrustRepository
    Import-Module -Name NerdFonts

    # Run the following for each font you want to install.
    Install-NerdFont -Name 'Meslo*' -Confirm:$False
    ```
  - On MacOS using `brew`:
    ```bash
    brew install --cask font-meslo-lg-nerd-font
    ```
  - For Linux or other operating systems, see [instructions in nerd-font
    repo](https://github.com/ryanoasis/nerd-fonts#font-installation).
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

### Installing Zig on Windows

On Windows, if you don't want to set up MSYS2 just to get `gcc`, `make`,
etc, then `zig` works fine as a drop-in replacement for NeoVim plugin
purposes.  Run the following **in a Git Bash window** to install zig:

```bash
PREFIX="$HOME/local/zig"
export MSYS="winsymlinks:nativestrict"
export TMPDIR="${TMPDIR:-${TMP:-/tmp}}"
mkdir -p "$PREFIX" && cd "$PREFIX" &&

# Scrape latest zig version from its index.json file.
zig_index="$(curl -kL "https://ziglang.org/download/index.json")" &&
scraped="$(printf '%s' "$zig_index" | awk '
  BEGIN { found_ver=0; found_url=0; found_plat=0 }
  found_ver==0  && /^ *"[0-9]+(\.[0-9]+)+" *: *{ *$/ { found_ver=1; print "ver: "$1 }
  found_ver==1  && /^ *"x86_64-windows" *: *{ *$/ { found_plat=1 }
  found_plat==1 && /^ *"tarball" *: */ { found_url=1; print "url: "$2 }
  found_url==1 { exit 0 }
  END { exit (found_url==0) }')"
if [ $? -ne 0 ]; then error "unable to scrape zig's index.json"; fi

zig_bin=''
zig_ver="$(printf '%s' "$scraped" | grep '^ver:' | sed -E 's,^[^"]*"([^"]+)".*$,\1,')"
zig_url="$(printf '%s' "$scraped" | grep '^url:' | sed -E 's,^[^"]*"([^"]+)".*$,\1,')"
if [[ "$zig_url" != http?://* ]]; then
  echo "ERROR: could not scrape zig url: '%zig_url'"
else
  echo "Installing zig $zig_ver from '$zig_url'..."
  curl -kL -o "$TMPDIR/zig-$zig_ver.zip" "$zig_url" &&
  unzip -uC "$TMPDIR/zig-$zig_ver.zip" &&
  /bin/rm -f "$TMPDIR/zig-$zig_ver.zip" &&
  [ -x */zig.exe ] && zig_bin="$(echo */zig.exe)"
fi
if [ -z "$zig_bin" ]; then
  echo 'ERROR: could not extract zig package'
else
  gen_zig_wrapper() {
    [ $# -ge 2 ] && local file="$2" || local file="$1"
    printf '%s\n' \
      '#!/usr/bin/env bash' \
      'realself="$(readlink -f "$0")" &&' \
      'here="$(dirname "$realself")" &&' \
      'exec "$here/zig" '"'$1'"' "$@"' >"$PREFIX/bin/$file" &&
    chmod a+x "$PREFIX/bin/$file"
  }
  mkdir -p "$PREFIX/bin" &&
  /bin/ln -sf "../$zig_bin" "$PREFIX/bin/zig" &&
  gen_zig_wrapper 'ar' &&
  gen_zig_wrapper 'cc' &&
  gen_zig_wrapper 'cc' 'gcc' &&
  gen_zig_wrapper 'c++' &&
  gen_zig_wrapper 'c++' 'g++' &&
  gen_zig_wrapper 'dlltool' &&
  gen_zig_wrapper 'lib' &&
  gen_zig_wrapper 'objcopy' &&
  gen_zig_wrapper 'objdump' &&
  gen_zig_wrapper 'ranlib' &&
  gen_zig_wrapper 'rc' &&
  gen_zig_wrapper 'ld.lld' &&
  gen_zig_wrapper 'ld64.lld' &&
  gen_zig_wrapper 'lld-link' &&
  gen_zig_wrapper 'wasm-ld' &&
  gen_zig_wrapper 'lld-link' 'ld'
  if [ $? -ne 0 ]; then
    echo 'FAIL'
  else
    # Add $PREFIX/bin to PATH _only_ if it's not already there:
    win_path_munge() {
      local winpath="$(powershell.exe -NoProfile -ExecutionPolicy Bypass \
        -Command "\$([Environment]::GetEnvironmentVariable('PATH','User'))")" &&
      ([[ ";$winpath;" == *";$(cygpath -wl "$1");"* ]] ||
      powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
        "[Environment]::SetEnvironmentVariable('PATH',\"$(cygpath -wl "$1");$winpath\",'User');")
    }
    win_path_munge "$PREFIX/bin" && echo 'SUCCESS' || echo 'FAIL'
  fi
fi
```

## Experimental

You'll need JDTLS (Java language server) for Java LSP support.  This should
get installed automatically by Mason.  However, we can _optionally_ use the
[`install-jdtls.sh`](install-jdtls.sh) script included in this repo to have
a more customized install.  I originally wrote this script while trying to
make JDTLS work, but at this point the config works with the auto-installed
JDTLS, so this script isn't really needed anymore.  I'm still leaving the
script here though for future reference.
