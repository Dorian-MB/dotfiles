local options = {
    formatters_by_ft = {
        lua = { "stylua" },
        css = { "prettier" },
        html = { "prettier" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
    },

    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        -- `lsp_fallback` is deprecated; "fallback" is a value of the new
        -- `lsp_format` key (use the LSP formatter only when no formatter above
        -- matches the filetype).
        lsp_format = "fallback",
    },
}

return options
