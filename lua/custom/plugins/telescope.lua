-- Fuzzy Finder (files, lsp, etc).
return {
  'nvim-telescope/telescope.nvim',
  event = 'VeryLazy',
  --branch = '0.1.x', -- removed in 9929044 in main kickstart repo
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Determine amount of padding for window of the given percentage of
    -- full Vim window win_size, but at least the given min_size.  Param
    -- win_size must be vim.o.columns (to calculate horizontal padding) or
    -- vim.o.lines (for vertical padding).
    local calc_pad = function(win_size, pct, min_size, min_pad)
      local target_size = win_size * pct
      target_size = math.min(win_size, math.max(target_size, min_size))
      local pad = min_pad
      if target_size < win_size - (pad*2) then
        pad = math.ceil((win_size - target_size) / 2)
      end
      pad = math.ceil(math.max(min_pad, pad))
      assert(0 <= pad and pad <= math.ceil(win_size/2));
      return pad;
    end

    -- !!! Define your default layout_config here !!!
    --
    -- We're splitting out our custom telescope layout_config settings
    -- because we want to use these as the initial settings, but we also
    -- want them to update dynamically with autocmd VimResized.
    --
    -- NOTE: we can alternatively use autocmd UIEnter to set these as
    -- initial settings, but that slows down startup time.
    local get_layout_config = function(_)
      local results_width_min = 40  -- adjust minimum width of results window
      local preview_width_min = 75  -- adjust minimum width of preview window
      local hpad = calc_pad(vim.o.columns, 0.8, results_width_min+preview_width_min, 1)
      local vpad = calc_pad(vim.o.lines, 0.9, 24, 0)

      local preview_width =
        math.ceil(math.max(preview_width_min, (vim.o.columns - (2*hpad)) / 2))

      local layout_config = {
        width = { padding = hpad },
        height = { padding = vpad },
        scroll_speed = 2,
        flex = {
          -- Have to add a hard-coded constant to prevent a deadzone
          -- where preview window doesn't show.  Related to issue:
          -- https://github.com/nvim-telescope/telescope.nvim/issues/3138
          --
          -- FIXME: this hard-coded number seems _extremely_ fragile
          -- because I found it through trial and error.  Figure out
          -- what breaks this, then figure out how to fix it.
          flip_columns = results_width_min + preview_width + 6,

          -- The flex layout's flip_lines option is more forgiving.
          -- Specifies max number of lines before switching to side
          -- by side (horizontal) results + preview window.
          flip_lines = 8,

          horizontal = {
            preview_width = preview_width,
            preview_cutoff = results_width_min + preview_width,
          },
          vertical = {
            preview_height = 0.5,
            preview_cutoff = 8,
          },
        },
      }
      return layout_config
    end

    -- Change telescope layout based on Vim's window size.
    vim.api.nvim_create_autocmd({--[['UIEnter',--]] 'VimResized'}, {
      group = vim.api.nvim_create_augroup('custom-telescope-augroup', { clear = true }),
      callback = function(event)
        require('telescope').setup {
          defaults = {
            path_display = { "truncate", },
            layout_strategy = 'flex',
            layout_config = get_layout_config(event),
          },
        }
        return false -- returning true deletes this autocmd
      end
    })

    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
        path_display = { "truncate", },
        layout_strategy = 'flex',
        layout_config = get_layout_config(nil),

        --[[ minimal config test
        layout_strategy = 'flex',
        layout_config = {
          width = { padding = 0 },
          flex = {
            flip_columns = 75,
            flip_lines = 20,
            horizontal = {
              preview_cutoff = 75, -- must be same as flip_columns
            },
            vertical = {
              preview_cutoff = 21, -- must be same as flip_lines+1
            },
          },
        },
        --]]
      },
      -- pickers = {}
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>//', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[//] Fuzzy search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
