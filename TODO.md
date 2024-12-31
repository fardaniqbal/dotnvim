- [ ] Set up dadbod and related plugins for interactive SQL.
  - See TJ DeVries' video: https://youtu.be/ALGBuFLzDSA?si=ugl13sHmgF5FKLhI
- [ ] Set up a greeter/dashboard.
- [x] Automatically go into insert mode when entering a terminal window.
- [x] Disable line numbers and sign column in terminal windows.
- [ ] Set up Java LSP.
- [ ] Auto-refresh neo-tree when files are added/deleted/changed. (Neo-tree
  has a built-in setting for this, but can't remember it).
- [ ] Add plugin to render Markdown files.
- [ ] Make tab-completion work in Telescope (at least for file finder)
- [ ] Add smooth-scrolling plugin
- [x] Make indent-blankline's vertical bars more subtle.  Defaults are too
  distracting.
- [ ] Replace nvim-cmp with blink, which should be snappier.  Nvim-cmp has
  considerable input latency.
- [ ] Change window border colors to be more visible.  Tokyonight's window
  borders are too dark to see against a dark background.
- [x] Make Telescope window's left pane narrower and preview pane wider.
- [ ] Make Telescope's file list show file names before directory names.
- [ ] Make Telescope use fzf (see beginning of
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
