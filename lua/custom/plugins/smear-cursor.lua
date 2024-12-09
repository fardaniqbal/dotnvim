-- Cursor smearing animations to make large cursor movements easier to see.
return {
  "sphamba/smear-cursor.nvim",
  event = 'UIEnter',
  opts = {
    enabled = vim.fn.exists('g:neovide') == 0 -- smear is built in to neovide
  },
}
