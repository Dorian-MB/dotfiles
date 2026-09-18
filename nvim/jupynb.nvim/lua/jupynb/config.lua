local M = {}

---@class JupynbConfig
M.defaults = {
  -- Python interpreter used to run the kernel bridge. It only needs
  -- `jupyter_client`; the kernel itself can live in any other environment.
  python = nil, -- default: vim.g.python3_host_prog or "python3"

  kernel = {
    auto_start = true, -- start a kernel on the first execution
    name = nil, -- force a kernelspec name (default: notebook metadata)
    timeout = 60,
    -- Code run silently right after the kernel becomes ready, per language.
    startup = {
      python = "%matplotlib inline",
    },
    -- Offer `.venv/bin/python` style interpreters in the kernel picker.
    discover_venvs = true,
  },

  ui = {
    header = true, -- cell header bar
    gap = false, -- extra blank virtual line above each cell header
    statuscolumn = true, -- VSCode-like cell bar next to the text
    active_bg = true, -- subtle background on the focused cell
    signcolumn = "no",
    wrap = true, -- notebooks read better with wrapped lines
    reveal_output = true, -- scroll the output into view after a run
    max_output_lines = 24, -- per cell, before truncation
    max_output_width = 800, -- per line, before truncation
    number = true, -- keep line numbers in the custom statuscolumn
    spinner = {
      "\u{280b}",
      "\u{2819}",
      "\u{2839}",
      "\u{2838}",
      "\u{283c}",
      "\u{2834}",
      "\u{2826}",
      "\u{2827}",
      "\u{2807}",
      "\u{280f}",
    },
    -- Nerd Font code points are written as escapes so the file stays ASCII.
    icons = {
      code = nil, -- nil -> filetype icon from nvim-web-devicons
      markdown = "\u{f0354}", -- md-language-markdown
      raw = "\u{f0219}", -- md-file-document
      run = "\u{f04b}", -- fa-play
      ok = "\u{f00c}", -- fa-check
      error = "\u{f00d}", -- fa-times
      queued = "\u{25cc}", -- dotted circle
      bar = "\u{258a}", -- left three quarters block
      bar_dim = "\u{258f}", -- left one eighth block
      out = "\u{258f}",
      image = "\u{f03e}", -- fa-image
    },
  },

  images = {
    enabled = true, -- inline images through image.nvim (kitty protocol)
    max_height = 24, -- in terminal rows
    max_width = 120, -- in terminal columns
  },

  lsp = {
    otter = true, -- LSP / completion inside code cells via otter.nvim
  },

  save = {
    strip_outputs = false, -- write the notebook without its outputs
  },

  keymaps = {
    enabled = true,
    prefix = "<leader>j",
  },

  -- Any highlight group defined by the plugin can be overridden here, e.g.
  -- highlights = { JupynbHeader = { bg = "#2a2a3a" } }
  highlights = {},
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  return M.options
end

---@return JupynbConfig
function M.get()
  return M.options
end

function M.python()
  local py = M.options.python
  if py and py ~= "" then
    return vim.fn.expand(py)
  end
  if vim.g.python3_host_prog and vim.g.python3_host_prog ~= "" then
    return vim.fn.expand(vim.g.python3_host_prog)
  end
  return "python3"
end

return M
