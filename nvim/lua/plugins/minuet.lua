-- lua/plugins/minuet.lua
return {
    "milanglacier/minuet-ai.nvim",
    lazy = false,
    event = "InsertEnter",
    config = function()
        require("minuet").setup {
            provider = "gemini", -- ton provider par défaut
            provider_options = {
                gemini = {
                    model = "gemini-3.1-flash-lite",
                    -- clé lue automatiquement depuis GEMINI_API_KEY
                },
                openai_compatible = {
                    -- pour TurboFieldfare (serveur local en loopback)
                    end_point = "http://127.0.0.1:8080/v1/chat/completions",
                    api_key = "TURBOFIELDFARE_API_KEY", -- variable factice, valeur peu importe en local
                    model = "gemma-4-26b-a4b", -- vérifie le nom exact exposé par le serveur
                    name = "TurboFieldfare",
                },
            },
            -- affichage : virtual-text (ghost text) ou intégration nvim-cmp/blink-cmp
            virtualtext = {
                auto_trigger_ft = { "*" },
                keymap = {
                    accept = "<C-e>",
                    accept_line = "<C-a>",
                    dismiss = "<C-q>",
                },
            },
        }
    end,
}
