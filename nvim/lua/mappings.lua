require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "move down the selected line" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "move up the selected line" })

-- Find and replaced
map("n", "<leader>R", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gc<Left><Left><Left>", { desc = "Find and Replace current word curent file"})
map("n", "<leader>rr", ":.,$s/\\<<C-r><C-w>\\>/<C-r><C-w>/gc<Left><Left><Left>", {desc = "Find and Replace current word from current position to the end"})
map("n", "<leader>rf", ":.,$s///gc<Left><Left><Left><Left>", {desc = "Find and Replace commande from current position to the end"})
-- Find and replace (visual mode)
map("v", "<leader>R", [["zy:%s/<C-r>z//gc<Left><Left><Left>]], { desc = "Find and Replace selection (whole file)" })
map("v", "<leader>rr", [["zy:.,$s/<C-r>z//gc<Left><Left><Left>]], { desc = "Find and Replace selection from current position to the end" })

map("n", "<leader>G", "<cmd>tabnew<cr>")
-- by debault past over a selection doent copy
-- but <leader> + p does
map("x", "p", 'p:let @+=@0<cr>:let @"=@0<cr>', {desc = "dont copy replaced text"})
map("x", "<leader>p", '"+p' , {desc = "past and copy over the selection"})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
desc = 'Highlight when yanking (copying) text',
group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
callback = function() vim.hl.on_yank() end,
})


map({ "n", "t" }, "<A-o>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggleable horizontal term" })


map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "telescope current word" })
map("n", "<leader>fc", "<cmd>Telescope commands<CR>", { desc = "telescope commands" })
map("n", "<leader>fr", "<cmd>Telescope resume<CR>", { desc = "telescope resume" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "telescope diagnostics" })
map("n", "<leader>fb", "<cmd>Telescope builtin<CR>", { desc = "telescope builtin" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "telescope git brances" })
map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", {desc = "telescope document symbole"})
map("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", {desc = "telescope document symbole"})




-- map('n', '<leader>k', vim.lsp.buf.hover, { desc = "Afficher la description (LSP)" })


-- ---- Notebook keymap
-- -- Navigation
-- map("n", "<leader>cd", function()
--   require("notebook-navigator").move_cell("d")
-- end, { desc = "Next notebook cell" })
--
-- map("n", "<leader>cu", function()
--   require("notebook-navigator").move_cell("u")
-- end, { desc = "Previous notebook cell" })
--
-- -- Execution
-- map("n", "<leader>M", function()
--   require("notebook-navigator").run_cell()
-- end, { desc = "Run notebook cell" })
-- -- Execution
-- map({"n", "i"}, "<C-CR>", function()
--   require("notebook-navigator").run_and_move()
-- end, { desc = "Run notebook cell" })
--
-- map({"n", "i"}, "<C-a>", function()
--   require("notebook-navigator").add_cell_above()
-- end, { desc = "Run cell and move" })
--
-- map({"n", "i"}, "<C-b>", function()
--   require("notebook-navigator").add_cell_below()
-- end, { desc = "Run cell and move" })
--
-- map("n", "<C-:>", function()
--   require("notebook-navigator").comment_cell()
-- end, { desc = "Run cell and move" })
--


