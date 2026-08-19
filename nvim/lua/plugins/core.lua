return {
     {
          "stevearc/conform.nvim",
          -- event = 'BufWritePre', -- uncomment for format on save
          opts = require "configs.conform",
     },

     -- These are some examples, uncomment them if you want to see them work!
     {
          "neovim/nvim-lspconfig",
          config = function()
               require "configs.lspconfig"
          end,
     },

     {
          "kylechui/nvim-surround",
          version = "*", -- Use for stability; omit to use `main` branch for the latest features
          event = "VeryLazy",
          config = function()
               require("nvim-surround").setup({
                    -- Configuration here, or leave empty to use defaults
               })
          end
     },

     -- test new blink
     { import = "nvchad.blink.lazyspec" },

     {
          "nvim-treesitter/nvim-treesitter",
          branch = "main",
          lazy = false,
          build = ":TSUpdate",

          config = function()
               require("nvim-treesitter").install({
                    "lua",
                    "rust",
                    "python",
                    "markdown",
                    "markdown_inline",
               })

               vim.api.nvim_create_autocmd("FileType", {
                    callback = function(args)
                         vim.treesitter.start(args.buf)
                    end,
               })
          end,
     },


     {
          'mrcjkb/rustaceanvim',
          -- To avoid being surprised by breaking changes,
          -- I recommend you set a version range
          version = '^9',
          -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
          -- No need for lazy.nvim to lazy-load it.
          lazy = false,
          cargo = {
               allfeatures = true,
          }
     },


     {
          "jiaoshijie/undotree",
          opts = {
               -- your options
          },
          keys = { -- load the plugin only when using it's keybinding:
               { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>"},
          },
     },


}
