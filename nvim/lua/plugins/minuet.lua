return {
    "milanglacier/minuet-ai.nvim",
    -- Loaded on the first insert; `lazy = false` used to sit next to this
    -- event and silently won, pulling the provider in at every startup.
    event = "InsertEnter",
    config = function()
        require("minuet").setup {
            -- preset actif au démarrage
            provider = "gemini",
            provider_options = {
                gemini = {
                    model = "gemini-3.1-flash-lite",
                },
                openai_compatible = {
                    end_point = "http://127.0.0.1:8080/v1/chat/completions",
                    api_key = "TURBOFIELDFARE_API_KEY",
                    model = "gemma-4-26b-a4b-it",
                    name = "TurboFieldfare",
                    optional = {
                        -- moins de tokens a generer = moins de forward pass sur
                        -- un modele MoE dont les experts sont lus depuis le disque
                        max_tokens = 64,
                    },
                },
            },

            virtualtext = {
                auto_trigger_ft = { "*" },
                keymap = {
                    accept = "<C-e>",
                    accept_line = "<C-a>",
                    dismiss = "<C-e>",
                },
            },
        }
    end,
}
