-- Include vim configuration if available.  Based on
-- https://neovim.io/doc/user/nvim.html#nvim-from-vim, translated to Lua.
vim.opt.runtimepath:prepend({ vim.fn.expand('~/.vim') })
vim.opt.runtimepath:append({ vim.fn.expand('~/.vim/after') })
vim.cmd("let &packpath = expand(&runtimepath)")
if (vim.fn.filereadable(vim.fn.expand('~/.vimrc')) ~= 0) then
  vim.cmd("source ~/.vimrc")
elseif (vim.fn.filereadable(vim.fn.expand('~/.vim/vimrc')) ~= 0) then
  vim.cmd("source ~/.vim/vimrc")
end

require("fardan")
