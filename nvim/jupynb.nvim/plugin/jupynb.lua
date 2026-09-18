if vim.g.loaded_jupynb then
  return
end
vim.g.loaded_jupynb = true

vim.filetype.add({ extension = { ipynb = "jupynb" } })
pcall(vim.treesitter.language.register, "markdown", "jupynb")

local group = vim.api.nvim_create_augroup("jupynb", { clear = true })

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = group,
  pattern = "*.ipynb",
  callback = function(ev)
    require("jupynb").read(ev)
  end,
})

vim.api.nvim_create_autocmd("BufWriteCmd", {
  group = group,
  pattern = "*.ipynb",
  callback = function(ev)
    require("jupynb").write(ev)
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = group,
  pattern = "*.ipynb",
  callback = function(ev)
    require("jupynb").new_file(ev)
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    if package.loaded["jupynb"] then
      vim.schedule(function()
        require("jupynb").refresh_theme()
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    if package.loaded["jupynb.kernel"] then
      require("jupynb.kernel").shutdown_all()
    end
  end,
})

vim.api.nvim_create_user_command("Jupynb", function(opts)
  require("jupynb").command(opts)
end, {
  nargs = "*",
  desc = "Notebook: run / edit cells, manage the kernel",
  complete = function(lead, line)
    return require("jupynb").complete(lead, line)
  end,
})
