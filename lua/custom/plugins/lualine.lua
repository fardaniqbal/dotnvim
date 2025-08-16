-- Custom statusline using lualine.nvim.  For customization options see
-- https://github.com/nvim-lualine/lualine.nvim
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
      refresh = {           -- refresh times are in milliseconds
        statusline = 200,
        tabline = 200,
        winbar = 200,
        refresh_time = 33   -- default is 16
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
