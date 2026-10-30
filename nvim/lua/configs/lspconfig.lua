require("nvchad.configs.lspconfig").defaults()

local servers = {
    "html",
    "cssls",
    "pyright",
    -- lua_ls by defalut with nvchad
    -- rust-analyzer with rustaceanvim
}
-- pyright prend le python du PATH (~/.venvs/nvim) : on lui donne celui du
-- projet, le .venv le plus proche en remontant depuis la racine (pyproject.toml,
-- .git...), sinon le venv active dans le shell ($VIRTUAL_ENV).
-- Ponctuellement : :LspPyrightSetPythonPath /chemin/vers/python
vim.lsp.config("pyright", {
    before_init = function(_, config)
        local start = config.root_dir or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        local venv = vim.fs.find(".venv", { path = start, upward = true, type = "directory" })[1]
            or vim.env.VIRTUAL_ENV
        local python = venv and venv .. "/bin/python"
        if python and vim.uv.fs_stat(python) then
            config.settings = config.settings or {}
            config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, { pythonPath = python })
        end
    end,
})

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
