return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    event = 'VeryLazy',
    opts = {
      scope = {
        show_start = false, -- if true, underline the scope's first line
        show_end = false,   -- if true, underline the scope's last line

        -- HACK: change scope highlight color by just setting it to another
        -- highlight group.  Definitely NOT the right way to do this, but I
        -- have bigger fish to fry.
        highlight = {'diffLine'}
      },
    },
  },
}
