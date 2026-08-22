return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
        require("nvim-treesitter").install {
            "vim",
            "lua",
            "luadoc",
            "printf",
            "vimdoc",
            "html",
            "css",
            "rust",
            "python",
            "markdown",
            "markdown_inline",
        }

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "vim",
                "lua",
                "luadoc",
                "printf",
                "vimdoc",
                "html",
                "css",
                "rust",
                "python",
                "markdown",
            },
            callback = function(args)
                vim.treesitter.start(args.buf)
            end,
        })
    end,
}
