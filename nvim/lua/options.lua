require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

-- relativenumber by default
vim.opt.nu = true
vim.opt.relativenumber = true

-- 4 space indent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.wrap = false
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

-- stop scrolling 8 line before the end/top
vim.opt.scrolloff = 8

-- undo default nvchad setting
vim.g.loaded_python3_provider = nil
vim.g.python3_host_prog = vim.fn.expand "~/.venvs/nvim/bin/python"
