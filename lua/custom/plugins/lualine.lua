-- Custom statusline using lualine.nvim.  For customization options see
-- https://github.com/nvim-lualine/lualine.nvim

---- Custom Refresh Setup ----
-- Though lualine is quite responsive by default, its default refresh_time
-- of 16 milliseconds makes nvim eat up noticable CPU even while idle.
-- Therefore, we use this workaround to force lualine to refresh on certain
-- events so it stays responsive, even with low refresh rate settings.
local setup_refresh_timer = function()
  -- XXX: this should more-or-less match lualine's default config values
  -- for options.refresh.events.  It's a pain, but we'll have to keep this
  -- up-to-date with lualine's default options in the README:
  -- https://github.com/nvim-lualine/lualine.nvim/blob/master/README.md#global-options
  --
  -- This _does not_ mean that this list of events should match _exactly_
  -- with the above lualine docs.  But it _does_ mean we should pay
  -- attention if it changes on future lualine updates.
  local LUALINE_REFRESH_EVENTS = {
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
  }
  local REFRESH_DEBOUNCE_TIME = 20  -- minimum milliseconds between refreshes

  local lualine = require('lualine')
  local uv = vim.uv or vim.loop
  local dbg_refresh_cnt = 0

  local refresh_callback = function(ev)
    if false then print('('..ev.event..') refreshes: '..dbg_refresh_cnt) end
    dbg_refresh_cnt = dbg_refresh_cnt + 1
    lualine.refresh({
      force = true,
      -- 'place' must have one or more of: 'statusline', 'winbar', 'tabline'.
      -- Add these values here if you enable winbar or tabline.
      place = { 'statusline', },
    })
  end

  local debounce_timer = uv.new_timer()
  vim.api.nvim_create_autocmd(LUALINE_REFRESH_EVENTS,
    {
      group = vim.api.nvim_create_augroup("MyLualineForceRefreshGroup", { clear = true }),
      callback = function(ev)
        assert(debounce_timer ~= nil)
        debounce_timer:start(REFRESH_DEBOUNCE_TIME, 0, function()
          debounce_timer:stop()
          vim.schedule(function() refresh_callback(ev) end)
        end)
      end,
    }
  )
end

---- Main Lualine Plugin Config ----
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Custom component 'my_filetype' - like Lualine's built-in 'filetype'
    -- component, but use Unicode icon instead of nerdfont icon.  Don't
    -- want to make coworkers install a nerdfont just for tmux sharing.
    local my_filetype = function()
      return '⠿ ' .. vim.bo.filetype
    end

    require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'auto',
      --component_separators = { left = '', right = ''},
      --section_separators = { left = '', right = ''},
      component_separators = { left = '', right = '│'},
      section_separators = { left = ' ', right = ''},
      always_show_tabline = true,
      --globalstatus = true,  -- show one statusline for all windows if true
      refresh = {             -- refresh times are in milliseconds
        statusline = 10000,   -- default 100
        tabline = 10000,      -- default 100
        winbar = 10000,       -- default 100
        refresh_time = 10000  -- default 16
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

    setup_refresh_timer()
  end
}
