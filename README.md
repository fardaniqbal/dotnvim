This repo stores my personal Neovim config and related files.  These notes
outline a [**summary of prerequisites**](#prerequisite-summary) for using
this config, how to [**install the config**](#how-to-install-this-config)
itself, and tips on [**setting up any
prerequisites**](#prerequisite-details) you may not already have installed.

## Prerequisite Summary

Make sure you have the following components installed on your system and
available in your `$PATH` before using this Neovim config:

* Neovim, **at least** version 0.12
* If you're on Windows, you'll need Git Bash or MinGW/MSYS2.
* On Windows, you must enable _non-admins_ to create symlinks.
* Git
* Curl
* Unzip (command-line tool)
* Python, **at least** version 3.9, with `pip` and the `pynvim` package
* [`ripgrep`](https://github.com/BurntSushi/ripgrep)
* [`fd`](https://github.com/sharkdp/fd)
* Nodejs/npm, with the `neovim` package
* `make`, `gcc`, and the usual suspects to build optional plugins.
* `tree-sitter`
* If using Windows, you need PowerShell 7/`pwsh.exe` - **this is _NOT_ the
  PowerShell included with Windows**
* A "nerd font", with your terminal configured to use it
* Java build tools if you want Java integration (JDK, Maven, etc)

## How to Install This Config

_Recursively_ clone this repo _and its submodules_ into something like
`~/dotfiles/dotnvim`, then symlink `$XDG_CONFIG_HOME/nvim` to your local
clone of this repo.  (If `$XDG_CONFIG_HOME` is not set, then substitute
with `$LOCALAPPDATA` on Windows, or `~/.config` otherwise.) For example, in
Bash:

```bash
if echo ${OSTYPE:-$(uname)} | grep -Eqi '^(win|mingw|cyg)'; then
  # Handle Windows specially.
  export MSYS='winsymlinks:nativestrict'
  git config --global core.symlinks true
  conf_dir="$(cygpath "${XDG_CONFIG_HOME:-$LOCALAPPDATA}")"
else
  conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
fi

mkdir -p ~/dotfiles
cd ~/dotfiles
git clone --recurse-submodules https://github.com/fardaniqbal/dotnvim
# Or git clone --recurse-submodules git@github.com:fardaniqbal/dotnvim.git
# to clone through ssh.

mkdir -p "$conf_dir"
rm -f "$conf_dir/nvim"
ln -s ~/dotfiles/dotnvim "$conf_dir/nvim"
```

Now start Neovim and wait for plugins to auto-install.  After plugins
finish installing, run command `:checkhealth` in Neovim to verify that
everything is set up correctly, and you're good to go!

## Prerequisite Details

This section contains details on setting up the prerequisites listed above.
The main purpose is to document the steps I took in the past to set things
up, so as to prevent spending hours re-googling steps I've already figured
out the hard way.

### Setting up Git Bash on Windows
If you're on Windows, you'll need Git Bash.  This is included in
[Git](https://git-scm.com/)'s Windows installer.  **TODO:** come up with an
automated script to install this with the correct install options selected.

### Enabling _non-admins_ to create symlinks on Windows
See the following for how to do this:
- [Enable developer mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development)
- [Allow non-admins to create symlinks](https://stackoverflow.com/a/76632011)
- [Tell git to use symlinks](https://stackoverflow.com/a/59761201)
- **TODO:** come up with a script to do this automatically.

### Installing Python >= 3.9
**TODO**

### Installing `pip` and the `pynvim` package
1.  **TODO:** how to ensure `pip` is installed.
2.  The following Bash snippet installs `pynvim`.
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

### Installing ripgrep
You'll need [`ripgrep`](https://github.com/BurntSushi/ripgrep) for
[`telescope`](https://github.com/nvim-telescope/telescope.nvim)'s
`grep-string` (and possibly other telescope functions).
- **Windows:** you can install using Winget by running the following in
  `cmd.exe`:
  ```cmd
  winget install BurntSushi.ripgrep.MSVC
  ```
- **Mac OS:**, you can use install using Homebrew:
  ```bash
  brew install ripgrep
  ```
  Or with MacPorts:
  ```bash
  sudo port install ripgrep
  ```
- **Linux:** install using your favorite package manager.  Details in
  ripgrep's [README](https://github.com/burntsushi/ripgrep#installation).
  * **TODO:** instructions to automate installation on common distros -
    Ubuntu/DEB-based, RedHat/RPM-based, and Arch/pacman-based.

### Installing fd (file finder)
[`fd`](https://github.com/sharkdp/fd) significantly improves `telescope`'s
usability.
- **Windows:**, you can install using Winget by running the following in
  `cmd.exe`:
  ```cmd
  winget install sharkdp.fd
  ```
- **Mac OS:** you can use install using Homebrew:
  ```bash
  brew install fd
  ```
  Or with MacPorts:
  ```bash
  sudo port install fd
  ```
- **Linux:** install using your favorite package manager.  Details in fd's
  [README](https://github.com/sharkdp/fd#on-ubuntu).
  * **TODO:** instructions to automate installation on common distros -
    Ubuntu/DEB-based, RedHat/RPM-based, and Arch/pacman-based.

### Installing Nodejs/npm
You'll need Nodejs and npm for some of the language servers.
- **Windows:** install by running the following **in Git Bash or
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
- **Mac OS:** you can use install using Homebrew:
  ```bash
  # TODO: homebrew command to install Nodejs/npm
  ```
  Or with MacPorts:
  ```bash
  # TODO: port command to install Nodejs/npm
  ```
- **Linux:** **TODO:** instructions to automate installation on common
  distros - Ubuntu/DEB-based, RedHat/RPM-based, and Arch/pacman-based.

After installing Nodejs/npm, run `npm install -g neovim`.  If you don't
have root/admin access, run `echo "prefix=$HOME/local/npm-packages" >>
~/.npmrc` first.  This makes future `npm install -g` commands install npm
packages to your home directory.

Re-run `npm install -g neovim` any time you upgrade Neovim.

### Installing tree-sitter
You'll need `tree-sitter` for accurate syntax highlighting.
- **Windows:** run the following **in Git Bash or MinGW/MSYS2** (replace
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
  } &&
  win_path_munge "$(pwd)" && echo 'SUCCESS' || echo 'FAIL'
  ```
- **MacOS:** using Homebrew:
  ```bash
  brew install tree-sitter
  brew install tree-sitter-cli
  ```
  Or with MacPorts:
  ```bash
  # TODO: port command to install tree-sitter
  ```
- **Linux:** **TODO:** instructions to automate installation on common
  distros - Ubuntu/DEB-based, RedHat/RPM-based, and Arch/pacman-based.

### Installing PowerShell 7/`pwsh.exe` (required only on Windows)
Run the following commands in a Windows command prompt (based on [these
instructions](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.6)):
```cmd
echo Y | winget search --id Microsoft.PowerShell --exact
winget install --id Microsoft.PowerShell --source winget
```

### Installing nerd fonts
- **Windows:** using PowerShell 7 (i.e., `pwsh.exe`):
  ```pwsh
  # Run the following ONCE to install the module.
  Install-PSResource -Name NerdFonts -TrustRepository
  Import-Module -Name NerdFonts

  # Run the following for each font you want to install.
  Install-NerdFont -Name 'Meslo*' -Confirm:$False
  ```
- **MacOS:** using Homebrew:
  ```bash
  brew install --cask font-meslo-lg-nerd-font
  ```
  Or with MacPorts:
  ```bash
  # TODO: port command to install nerd font
  ```
- **Linux:** see [instructions in nerd-font
  repo](https://github.com/ryanoasis/nerd-fonts#font-installation).
  **TODO:** instructions to automate installation on common distros -
  Ubuntu/DEB-based, RedHat/RPM-based, and Arch/pacman-based.

Don't forget to configure your terminal to actually use the nerd font.

### Installing Java build tools
For Java integration, you'll need the following executables installed:
`java`, `javac`, `mvn`, `ant`, etc.  For the JDKs, this Neovim config
assumes you use `sdkman` to install them.  Run this in Bash to install
`sdkman`:
```bash
curl -s "https://get.sdkman.io" | bash
```
Then use `sdkman` to install an LTS JDK, **at least version 25**:
```bash
sdk install java 25.0.3-tem
sdk default java 25.0.3-tem
```

To install additional JDK versions, do `sdk install java IDENTIFIER`
(replace `IDENTIFIER` with an appropriate value from the output of `sdk
list java`.)

### Installing Maven:
- **Windows:** run the following **in Git Bash or MinGW/MSYS2**:
  ```bash
  # TODO: automated install instructions for Maven.
  ```
- **Mac OS**: using Homebrew:
  ```bash
  brew install mvn
  ```
  Or with MacPorts:
  ```bash
  # TODO: port command to install Maven.
  ```
- **Linux:** **TODO:** instructions to automate installation on common
  distros - Ubuntu/DEB-based, RedHat/RPM-based, and Arch/pacman-based.

### Installing Zig on Windows
On Windows, if you don't want to set up MSYS2 just to get `gcc`, `make`,
etc, then `zig` works fine as a drop-in replacement for Neovim plugin
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
