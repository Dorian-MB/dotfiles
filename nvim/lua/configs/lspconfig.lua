require("nvchad.configs.lspconfig").defaults()

local servers = {
          "html",
          "cssls",
          "pyright",
          -- lua_ls by defalut with nvchad
          -- rust-analyzer with rustaceanvim
 }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
