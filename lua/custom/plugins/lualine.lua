-- Custom statusline using lualine.nvim.  For customization options see
-- https://github.com/nvim-lualine/lualine.nvim
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require('lualine')
    local uv = vim.uv or vim.loop

    -- Custom component 'my_filetype' - like Lualine's built-in 'filetype'
    -- component, but use Unicode icon instead of nerdfont icon.  Don't
    -- want to make coworkers install a nerdfont just for tmux sharing.
    local my_filetype = function()
      return '⠿ ' .. vim.bo.filetype
    end

    -- Workaround to force lualine to refresh on certain events so it stays
    -- responsive, even with low refresh rate settings.
    local last_refresh_time = uv.now()
    local refresh_debounce = 16 -- minimum milliseconds between refreshes
    vim.api.nvim_create_autocmd(
    {
      -- XXX: this should more-or-less match lualine's default config
      -- values for options.refresh.events.  It's a pain, but we'll have to
      -- keep this up-to-date with lualine's default options in the README:
      -- https://github.com/nvim-lualine/lualine.nvim/blob/master/README.md#global-options
      --
      -- This _does not_ mean that this list of events should match
      -- _exactly_ with the above lualine docs.  But it _does_ mean we
      -- should pay attention if it changes on future lualine updates.
      'WinEnter',
      'BufEnter',
      'BufWritePost',
      'SessionLoadPost',
      'FileChangedShellPost',
      'VimResized',
      'Filetype',
      "CursorMoved",
      "CursorMovedI",
      "ModeChanged",
    },
    {
      group = vim.api.nvim_create_augroup("MyLualineForceRefreshGroup", { clear = true }),
      callback = function()
        local now = uv.now()
        local diff = now - last_refresh_time
        if diff >= refresh_debounce then
          last_refresh_time = now
        end
        lualine.refresh({
          force = diff >= refresh_debounce,
          place = { 'statusline', },
        })
      end,
    })

    lualine.setup {
    options = {
      icons_enabled = true,
      theme = 'auto',
      --component_separators = { left = '', right = ''},
      --section_separators = { left = '', right = ''},
      component_separators = { left = '', right = '│'},
      section_separators = { left = ' ', right = ''},
      always_show_tabline = true,
      --globalstatus = true,  -- show one statusline for all windows if true
      refresh = {           -- refresh times are in milliseconds
        statusline = 500,   -- default 100
        tabline = 500,      -- default 100
        winbar = 500,       -- default 100
        refresh_time = 200  -- default 16
      },
      disabled_filetypes = {
        statusline = {'neo-tree'},
      },
    },
    -- To see defaults run `:h lualine-Default-configuration`.
    sections = {
      lualine_b = {
        {icon = vim.g.have_nerd_font and '' or '⌥', 'branch'},
        'diff', 'diagnostics'
      },
      --lualine_c = {'%=', 'filename'}, -- center the filename
      lualine_x = {
        {'encoding', show_bomb = true}, -- show_bomb: byte order mark
        {'fileformat', symbols = {unix="unix", dos="dos", mac="mac"}},
        --{'filetype', icons_enabled = false},
        {my_filetype} --{my_filetype, color = {fg='#99cc66'}},
      },
    },
    --[[ -- inactive_sections is relevant only if globalstatus = false
    inactive_sections = {
      lualine_a = {'mode'},                               -- default = {}
      lualine_b = {'branch', 'diff', 'diagnostics'},      -- default = {}
      lualine_c = {'filename'},                           -- default = {'filename'}
      lualine_x = {'encoding', 'fileformat', 'filetype'}, -- defult = {'location'}
      lualine_y = {'progress'},                           -- default = {}
      lualine_z = {'location'},                           -- default = {}
    },
    --]]
    }
  end
}
