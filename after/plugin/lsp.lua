local lsp = require('lsp-zero')

--lsp.preset('recommended')
--lsp.setup();

require('mason-lspconfig').setup({
  ensure_installed = {
    'c',
    'cpp',
    'java',
    --'javascript',
    --'typescript',
    --'rust_analyzer',
    --'tsserver',
  }
})
