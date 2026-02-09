## Main TODO List

- [ ] Add a plugin that integrates with Tmux's session saver.
  - Still in progress.  See `session.lua`.
- [ ] Eliminate idle CPU hogging by "which-key" plugin.  (See "Bottlenecks"
  section below).
- [ ] (Ongoing): continue to improve startup times with lazy loading.
- [ ] lualine: disable status line on greeter screen.
- [ ] Make `Telescope buffers` (`<leader><leader>`) open with the current
  buffer selected.
- [ ] Make telescope include hidden files in its search results by default.
  Something like `require("telescope.builtin").find_files({hidden=true})`.
- [ ] Set up dadbod and related plugins for interactive SQL.
  - See TJ DeVries' video: https://youtu.be/ALGBuFLzDSA?si=ugl13sHmgF5FKLhI
- [ ] Set up a greeter/dashboard.
- [x] Automatically go into insert mode when entering a terminal window.
- [x] Disable line numbers and sign column in terminal windows.
- [x] Set up JDTLS (Java LSP).
- [ ] Make JDTLS search for JDK installations under /opt and wherever
  sdkman installs its packages (in addition to where it already searches).
- [ ] Auto-refresh neo-tree when files are added/deleted/changed. (Neo-tree
  has a built-in setting for this called `use_libuv_file_watcher`).
- [x] FIXME: when opening a file from neo-tree with its preview mode
  enabled (SHIFT-P), the window in which the file opens has the same
  background color as neo-tree instead of the normal window background.
  Steps to reproduce:
  1.  Start nvim as follows:
      ```bash
      cd ~/dotfiles
      nvim dotnvim/init.lua
      ```
  2.  Hit backslash to open neo-tree.
  3.  Hit SHIFT-P to enable preview mode.
  4.  Select `ginit.nvim` in neo-tree and hit ENTER to open it.
      - NOTE: bug is not visible yet.
  5.  Hit backslash again to go back to neo-tree window.
  6.  Hit SHIFT-P to enable preview mode.
  7.  Select `README.md` in neo-tree and hit ENTER to open it.
      - `README.md` opens in a window with same background color as
        neo-tree instead of the expected background color.
  - **NOTES:**
    - I first noticed this bug when I added an `event_handler` to
      `neo-tree.lua` to hide the border on neo-tree's sidebar.  Don't know
      if that's the cause of the bug, or if that's just when I noticed it,
      but it's probbly a good place to investigate.
    - Additionally, the sign gutter is missing on the window with the wrong
      background color.  Might be a clue.
  - **FIXED** in commit
    [cf9a5eb](https://github.com/nvim-neo-tree/neo-tree.nvim/commit/cf9a5eb0c49b57385af7abf8463eb75013759eee)
- [ ] Add plugin to render Markdown files.
- [ ] Make tab-completion work in Telescope (at least for file finder)
- [ ] Add smooth-scrolling plugin
- [x] Make indent-blankline's vertical bars more subtle.  Defaults are too
  distracting.
- [x] Replace nvim-cmp with blink, which should be snappier.  Nvim-cmp has
  considerable input latency.
  - **[blink.cmp](https://github.com/Saghen/blink.cmp) is in beta (as of
    2024-12-05).**  Don't replace nvim-cmp until blink is stable.
- [x] Change window border colors to be more visible.  Tokyonight's window
  borders are too dark to see against a dark background.
  - [x] FIXME: the related changes to hide neo-tree's border changes window
    background of files opened from neo-tree.  Fix it so files have the
    expected window background color.
- [x] Make Telescope window's left pane narrower and preview pane wider.
- [ ] Make Telescope always show a horizontal split unless nvim window is
  _really_ wide.
- [ ] Make Telescope's file list show file names before directory names.
- [x] Make Telescope use fzf (see beginning of
  https://youtu.be/xdXE1tOT-qg?si=e7tK8mIL9i6L5Hup)
- [x] Make ~~\<C-E\> and \<C-Y\>~~ \<C-D\> and \<C-U\> scroll Telescope's
  preview window scroll down/up one line at a time.
- [x] Disable NeoTree's "File not in cwd" popup (e.g. when opening NeoTree
  from a :help buffer).  (Just default to "n" at the prompt).
  - **Fix:** change neo-tree's keybind command from `:Neotree reveal` to
    `:Neotree`, and enable `follow_current_file`.
- [x] For completion popup menus and inline code hints, change their
  background color and/or add a border to make it easier to visually
  distinguish them from actual buffer contents.

## Bottlenecks

Suspects of what's making nvim eat CPU while idle.

* which-key plugin
  - Commenting out the "which-key" section in `init.lua` brings nvim's CPU
    usage while idle **completely down to zero**.
  - This is _after_ putting in custom refresh/debounce logic in lualine.
  - Confirmed this by checking `htop` before and after commenting out
    "which-key" in `init.lua`.
  - See TODO above - figure out how to use "which-key" without hogging CPU.
