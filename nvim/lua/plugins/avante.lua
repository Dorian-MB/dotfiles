-- See https://github.com/yetone/avante.nvim
-- for more
return {
    "yetone/avante.nvim",
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    event = "VeryLazy",
    version = false, -- Never set this to "*"
    ---@module 'avante'
    ---@type avante.Config
    opts = {

        -- provider = "turbofieldfare", -- default to it; switch back with :AvanteSwitchProvider claude
        -- mode = "legacy",
        -- providers = {
        --     turbofieldfare = {
        --         __inherited_from = "openai",
        --         endpoint = "http://127.0.0.1:8080/v1",
        --         model = "gemma-4-26b-a4b-it",
        --         api_key_name = "TURBOFIELDFARE_API_KEY", -- server ignores the value, avante just needs it set
        --         disable_tools = true,
        --         timeout = 3000,
        --         context_window = 32000, -- match the --max-context you started the server with
        --         -- disable_tools = true, -- uncomment if the agentic tool loop errors out (see caveats)
        --         extra_request_body = {
        --             temperature = 0.2, -- matches turbo-fieldfare's own default sampling
        --             max_completion_tokens = 4096, -- keep well under your server's context window
        --         },
        --     },
        -- },

        instructions_file = "avante.md",
        -- for example
        provider = "claude",
        providers = {
            claude = {
                endpoint = "https://api.anthropic.com",
                model = "claude-sonnet-4-20250514",
                timeout = 30000, -- Timeout in milliseconds
                extra_request_body = {
                    temperature = 0.75,
                    max_tokens = 20480,
                },
            },
            moonshot = {
                endpoint = "https://api.moonshot.ai/v1",
                model = "kimi-k2-0711-preview",
                timeout = 30000, -- Timeout in milliseconds
                extra_request_body = {
                    temperature = 0.75,
                    max_tokens = 32768,
                },
            },
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
        {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = { file_types = { "markdown", "Avante" } },
            ft = { "markdown", "Avante" },
        },
    },
}
