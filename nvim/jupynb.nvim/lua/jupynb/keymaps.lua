local M = {}

local config = require("jupynb.config")

---Buffer local mappings, VSCode flavoured.
function M.attach(buf)
  local cfg = config.get().keymaps
  if not cfg.enabled then
    return
  end
  local actions = require("jupynb.actions")
  local kernel = require("jupynb.kernel")
  local p = cfg.prefix

  local function map(mode, lhs, fn, desc)
    vim.keymap.set(mode, lhs, fn, {
      buffer = buf,
      desc = "Notebook: " .. desc,
      silent = true,
      nowait = true,
    })
  end

  -- VSCode-like (needs a terminal speaking the kitty keyboard protocol,
  -- which Ghostty/kitty/WezTerm do).
  map({ "n", "i" }, "<C-CR>", function()
    actions.run(buf)
  end, "run cell")
  map({ "n", "i" }, "<S-CR>", function()
    actions.run(buf, { advance = true })
  end, "run cell and go to the next one")
  map({ "n", "i" }, "<M-CR>", function()
    actions.run(buf, { insert = true })
  end, "run cell and insert below")

  -- navigation
  map("n", "]c", function()
    actions.goto_cell(buf, 1)
  end, "next cell")
  map("n", "[c", function()
    actions.goto_cell(buf, -1)
  end, "previous cell")

  if not p or p == "" then
    return
  end

  -- run
  map("n", p .. "r", function()
    actions.run(buf)
  end, "run cell")
  map("n", p .. "R", function()
    actions.run_scope(buf, "all")
  end, "run every cell")
  map("n", p .. "A", function()
    actions.run_scope(buf, "above")
  end, "run every cell above")
  map("n", p .. "B", function()
    actions.run_scope(buf, "below")
  end, "run every cell below")

  -- structure
  map("n", p .. "a", function()
    actions.insert(buf, "above", "code")
  end, "insert a cell above")
  map("n", p .. "b", function()
    actions.insert(buf, "below", "code")
  end, "insert a cell below")
  map("n", p .. "d", function()
    actions.delete(buf)
  end, "delete the cell")
  map("n", p .. "m", function()
    actions.change_kind(buf)
  end, "toggle code / markdown")
  map("n", p .. "s", function()
    actions.split(buf)
  end, "split the cell at the cursor")
  map("n", p .. "J", function()
    actions.merge(buf)
  end, "merge with the next cell")
  map("n", p .. "<", function()
    actions.move(buf, -1)
  end, "move the cell up")
  map("n", p .. ">", function()
    actions.move(buf, 1)
  end, "move the cell down")

  -- outputs
  map("n", p .. "c", function()
    actions.clear(buf, false)
  end, "clear the outputs of the cell")
  map("n", p .. "C", function()
    actions.clear(buf, true)
  end, "clear every output")
  map("n", p .. "o", function()
    actions.show_output(buf)
  end, "open the full output")

  -- kernel
  map("n", p .. "k", function()
    kernel.pick(buf)
  end, "choose the kernel")
  map("n", p .. "x", function()
    kernel.restart(buf)
  end, "restart the kernel")
  map("n", p .. "i", function()
    kernel.interrupt(buf)
  end, "interrupt the kernel")
  map("n", p .. "F", function()
    actions.fix(buf)
  end, "repair the notebook structure")

  local ok, wk = pcall(require, "which-key")
  if ok and wk.add then
    pcall(wk.add, { { p, group = "notebook", buffer = buf } })
  end
end

return M
