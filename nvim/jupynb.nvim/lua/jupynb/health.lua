local M = {}

local config = require("jupynb.config")

local function run(cmd)
  local ok, res = pcall(function()
    return vim.system(cmd, { text = true }):wait()
  end)
  if not ok or not res then
    return nil
  end
  return res
end

function M.check()
  local health = vim.health
  health.start("jupynb.nvim")

  local py = config.python()
  if vim.fn.executable(py) == 1 then
    health.ok("python: " .. py)
  else
    health.error("python not found: " .. py, {
      "set `python` in the jupynb setup, or vim.g.python3_host_prog",
    })
    return
  end

  local res = run({ py, "-c", "import jupyter_client, sys; print(jupyter_client.__version__)" })
  if res and res.code == 0 then
    health.ok("jupyter_client " .. vim.trim(res.stdout or ""))
  else
    health.error("jupyter_client is missing", { py .. " -m pip install jupyter_client ipykernel" })
  end

  local kernels = run({
    py,
    "-c",
    "from jupyter_client.kernelspec import KernelSpecManager as K; print(' '.join(K().get_all_specs()))",
  })
  if kernels and kernels.code == 0 and vim.trim(kernels.stdout or "") ~= "" then
    health.ok("kernels: " .. vim.trim(kernels.stdout))
  else
    health.warn("no Jupyter kernel installed", { py .. " -m ipykernel install --user" })
  end

  health.start("treesitter")
  for _, lang in ipairs({ "markdown", "markdown_inline" }) do
    if vim.treesitter.language.add(lang) then
      health.ok("parser " .. lang)
    else
      health.error("missing treesitter parser: " .. lang, { ":TSInstall " .. lang })
    end
  end
  local okpy = pcall(vim.treesitter.language.add, "python")
  if okpy then
    health.ok("parser python (syntax highlighting inside code cells)")
  else
    health.warn("missing treesitter parser: python", { ":TSInstall python" })
  end

  health.start("images")
  local has_image = pcall(require, "image")
  if not has_image then
    health.warn("image.nvim is not installed: figures are shown as placeholders")
  else
    health.ok("image.nvim")
    if vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1 then
      health.ok("ImageMagick")
    else
      health.warn("ImageMagick not found", { "brew install imagemagick" })
    end
    local term = vim.env.TERM_PROGRAM or vim.env.TERM or ""
    if term:match("ghostty") or term:match("kitty") or term:match("WezTerm") or vim.env.KITTY_WINDOW_ID then
      health.ok("terminal with graphics support: " .. term)
    else
      health.warn("this terminal may not support the kitty graphics protocol: " .. term)
    end

    -- a multiplexer sits between Neovim and the terminal
    local img = require("jupynb.image")
    local muxer = (vim.env.TMUX and vim.env.TMUX ~= "" and "tmux")
      or (vim.env.HERDR_PANE_ID and "herdr")
      or (vim.env.STY and "screen")
      or (vim.env.ZELLIJ and "zellij")
    local reason, fix = img.blocker()
    if reason then
      health.error(reason, { fix })
    elseif muxer then
      health.ok(muxer .. " forwards the graphics escape codes")
    end

    local cw, ch = img.term_cell_size()
    if cw then
      health.ok(string.format("terminal cell size: %dx%d px", cw, ch))
    else
      health.warn("the terminal does not report a cell size: figures stay as placeholders")
    end
  end

  health.start("optional")
  if pcall(require, "otter") then
    local name, usable = require("jupynb").lsp_for("python")
    if not name then
      health.info("otter.nvim is installed but no LSP server is enabled for python")
    elseif usable then
      health.ok("otter.nvim (LSP inside code cells) with " .. name)
    else
      health.warn(
        string.format("`%s` is enabled for python but cannot run (missing interpreter?)", name),
        { "jupynb skips otter.nvim so the failure is not repeated on every notebook" }
      )
    end
  else
    health.info("otter.nvim is not installed: no LSP inside code cells")
  end
  if pcall(require, "render-markdown") then
    health.ok("render-markdown.nvim (pretty markdown cells)")
  else
    health.info("render-markdown.nvim is not installed")
  end
end

return M
