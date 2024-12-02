-- Custom key bindings.

-- Tabs.
vim.keymap.set('n', '<leader>to', '<cmd>tabnew<CR>', {desc = '[T]ab [O]pen'})
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<CR>', {desc = '[T]ab [C]lose'})
vim.keymap.set('n', '<leader>tn', '<cmd>tabnext<CR>', {desc = '[T]ab [N]ext'})
vim.keymap.set('n', '<leader>tp', '<cmd>tabprevious<CR>', {desc = '[T]ab [P]revious'})

-- Buffers.
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', {desc = '[B]uffer [N]ext'})
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', {desc = '[B]uffer [P]revious'})

-- Like :bd[elete], but doesn't change the window layout.  Uses blcose.vim.
vim.keymap.set('n', '<leader>bd', '<cmd>Bclose<CR>', {desc = '[B]uffer [D]elete'})

-- Resize window using <shift> arrow keys.
vim.keymap.set("n", "<S-Up>", "<cmd>resize +1<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<S-Down>", "<cmd>resize -1<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -1<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +1<cr>", { desc = "Increase Window Width" })

-- Move highlighted lines up/down in visual mode.
vim.keymap.set("v", "J", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Lines Down" })
vim.keymap.set("v", "K", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Lines Up" })

-- Make vim-tmux-navigator work in Vim's built-in terminal emulator.
vim.keymap.set('t', '<c-h>', '<cmd>TmuxNavigateLeft<cr>')
vim.keymap.set('t', '<c-j>', '<cmd>TmuxNavigateDown<cr>')
vim.keymap.set('t', '<c-k>', '<cmd>TmuxNavigateUp<cr>')
vim.keymap.set('t', '<c-l>', '<cmd>TmuxNavigateRight<cr>')
vim.keymap.set('t', '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>')

return {}
