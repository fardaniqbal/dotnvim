-- Custom key bindings.

-- Tabs.
vim.keymap.set('n', '<leader>to', '<cmd>tabnew<CR>', {desc = '[T]ab: [O]pen tab'})
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', {desc = '[T]ab: [C]lose tab'})
vim.keymap.set('n', '<leader>tn', '<cmd>tabnext<CR>', {desc = '[T]ab: [N]ext tab'})
vim.keymap.set('n', '<leader>tp', '<cmd>tabprevious<CR>', {desc = '[T]ab: [P]revious tab'})

-- Buffers.
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', {desc = '[B]uffer: [N]ext'})
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', {desc = '[B]uffer: [P]revious'})

-- Make vim-tmux-navigator work in Vim's built-in terminal emulator.
vim.keymap.set('t', '<c-h>', '<cmd>TmuxNavigateLeft<cr>')
vim.keymap.set('t', '<c-j>', '<cmd>TmuxNavigateDown<cr>')
vim.keymap.set('t', '<c-k>', '<cmd>TmuxNavigateUp<cr>')
vim.keymap.set('t', '<c-l>', '<cmd>TmuxNavigateRight<cr>')
vim.keymap.set('t', '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>')

return {}
