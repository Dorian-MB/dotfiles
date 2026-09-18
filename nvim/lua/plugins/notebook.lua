-- Jupyter notebooks (.ipynb) inside Neovim, with real cells.
--
-- Requirements (already installed in ~/.venvs/nvim):
--   pip install jupyter_client ipykernel   (+ matplotlib, pandas, ...)
-- Images are displayed through the kitty graphics protocol, which Ghostty
-- speaks natively, and need ImageMagick (`brew install imagemagick`).

return {
  {
    "jupynb.nvim",
    dir = vim.fn.stdpath "config" .. "/jupynb.nvim",
    lazy = false,
    priority = 100,
    dependencies = {
      "3rd/image.nvim",
      "jmbuhr/otter.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    opts = {
      -- see jupynb.nvim/README.md for every option
      keymaps = { prefix = "<leader>j" },
    },
  },

  -- Inline images (matplotlib figures) through the kitty graphics protocol.
  {
    "3rd/image.nvim",
    lazy = true,
    opts = {
      backend = "kitty",
      processor = "magick_cli", -- uses the `magick` binary, no luarocks needed
      integrations = {
        markdown = { enabled = false },
        neorg = { enabled = false },
        typst = { enabled = false },
        html = { enabled = false },
        css = { enabled = false },
      },
      max_width_window_percentage = 100,
      max_height_window_percentage = 100,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "blink-cmp-menu", "" },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = true,
    },
  },

  -- LSP (pyright) + completion inside the code cells.
  { "jmbuhr/otter.nvim", lazy = true },

  -- Pretty rendering of the markdown cells.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "jupynb" },
    opts = {
      file_types = { "markdown", "jupynb" },
      -- code blocks are the notebook cells themselves: jupynb draws those
      code = { enabled = false },
      sign = { enabled = false },
      heading = { sign = false, width = "block", left_pad = 1, right_pad = 2 },
      anti_conceal = { enabled = true },
    },
  },
}
