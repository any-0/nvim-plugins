require("user.options")
require("user.keymaps")
require("user.lazy")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("NvimTreeToggle")
    end, 20)
  end,
})
  
vim.opt.termguicolors = true
vim.opt.guicursor = ""

vim.opt.shell = 'powershell.exe'
