-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- couleur des commentaires, du plus clair au plus sombre :
--   "#9399b2"  overlay2 (Catppuccin), premier essai
--   "#8f95ae"  a peine plus sombre
--   "#8c92ab"  un tiers vers overlay1 
--   "#868ba3"  deux tiers vers overlay1
--   "#7f849c"  overlay1 (Catppuccin)
local comment_fg = "#7f849c"

M.base46 = {
    theme = "catppuccin",
        theme_toggle = { "penumbra_dark", "catppuccin" },
        transparency = true,
    -- commentaires plus lisibles : base46 catppuccin les met en #4e4d5d,
    -- presque invisible avec la transparence. #9399b2 = overlay2 de Catppuccin.
    hl_override = {
    	Comment = { fg = comment_fg, italic = true },
    	["@comment"] = { fg = comment_fg, italic = true },
    	-- selection visuelle : base46 met #2f2e3e, invisible avec la transparence.
    	-- #585b70 = surface2 de Catppuccin.
    	Visual = { bg = "#585b70" },
    },
}

M.nvdash = { load_on_startup = true }
M.ui = {
            tabufline = {
                lazyload = false
        }
}

return M
