vim.g.mapleader = " "
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  local function lastWriteTime()
    local file = vim.fn.expand("%:p")
    if vim.fn.filereadable(file) == 1 then
      local stat = vim.loop.fs_stat(file)
      if stat and stat.mtime then
        return os.date(" %Y-%m-%d %H:%M:%S", stat.mtime.sec)
      end
    end
    return ""
  end

  vim.o.completeopt = "menuone,noselect"

  require("lazy").setup({
    require("user.plugins.tree"),
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp", dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    } },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require('lualine').setup {
          sections = {
            lualine_c = {
            'filename',
            lastWriteTime,
            },
          },
          }
      end,
    },
    {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "light"   -- or "hard", "mix", "light"
      vim.cmd("colorscheme gruvbox-material")
    end,
    },
     { 
      "mluders/comfy-line-numbers.nvim",
      config = function()
        require("comfy-line-numbers").setup({
          up_key = '<Up>',
          down_key = '<Down>'
        })
      end,
    },

  })



  require("user.plugins.lsp")
  require("user.plugins.cmp")
  require("user.plugins.treesitter")
