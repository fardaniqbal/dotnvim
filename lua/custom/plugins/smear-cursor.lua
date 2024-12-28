-- Cursor smearing animations to make large cursor movements easier to see.
return {
  "sphamba/smear-cursor.nvim",
  event = 'VeryLazy',
  opts = {
    enabled = vim.fn.exists('g:neovide') == 0, -- smear is built in to neovide

    -- Stop animating when the smear's tail is within this distance (in
    -- characters) from the target.  Default = 0.1.
    distance_stop_animating = 1.5,
  },
}
