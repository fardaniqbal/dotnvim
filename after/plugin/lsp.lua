local lsp = require('lsp-zero')

--lsp.preset('recommended')
--lsp.setup();

require('mason').setup()

require('mason-lspconfig').setup({
  -- Add items from 'Server name' column here:
  -- https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
  -- You'll need `npm` installed for these to work.
  ensure_installed = {
    'bashls',
    'java_language_server',
    'clangd',                -- C and C++
    'eslint',                -- Javascript and Typescript
  }
})

--require('lspconfig')['bashls'].setup { capabilities = capabilities }
