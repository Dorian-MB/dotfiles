return {
    "mrcjkb/rustaceanvim",
    -- To avoid being surprised by breaking changes,
    -- I recommend you set a version range
    version = "^9",
    -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
    -- No need for lazy.nvim to lazy-load it.
    lazy = false,
    -- rustaceanvim is configured through vim.g.rustaceanvim, not through the
    -- lazy.nvim spec: any unknown key put directly on the spec (as `cargo` was)
    -- is silently ignored. It must be set before the plugin loads, hence init.
    init = function()
        vim.g.rustaceanvim = {
            server = {
                default_settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                        },
                    },
                },
            },
        }
    end,
}
