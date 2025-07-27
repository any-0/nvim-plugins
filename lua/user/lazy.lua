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
    local theme = require("lualine.themes.gruvbox-material")
    for _, mode in pairs(theme) do
      for _, section in pairs(mode) do
        if type(section) == "table" then
          section.bg = nil
          section.gui = nil
        end
      end
    end

    for _, mode_name in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal" }) do
      if theme[mode_name] and theme[mode_name].a then
        theme[mode_name].a.fg = "#ffffff"
      end
    end

    require("lualine").setup {
      options = {
        theme               = theme,
        component_separators = "",
        section_separators   = "",
        globalstatus         = true,
      },
      sections = {
        lualine_a = { { "mode" } },
        lualine_b = {},
        lualine_c = { "filename", lastWriteTime },
        lualine_x = {}, lualine_y = {}, lualine_z = {},
      },
    }
  end,
},
{
  "sainnhe/gruvbox-material",
  lazy = false,
  priority = 1000,
  config = function()
    vim.g.gruvbox_material_background            = "light"
    vim.g.gruvbox_material_transparent_background = 1
    vim.cmd.colorscheme("gruvbox-material")
  end,
},

-- ▸ transparent helper
{
  "xiyaowong/transparent.nvim",
  lazy = false,
  opts = {
    extra_groups  = {
      "NvimTreeNormal", "NvimTreeWinSeparator",
      "LualineNormal", "LualineInsert", "LualineVisual",
      "LualineReplace", "LualineCommand", "LualineTerminal",
      "StatusLine", "StatusLineNC" 
    },
    exclude_groups = { "CursorLine" },
  },
},

  })



require("user.plugins.lsp")
require("user.plugins.cmp")
require("user.plugins.treesitter")
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#000000", blend = 20 })
vim.api.nvim_set_hl(0, "StatusLine",   { bg = "none", fg = nil })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none", fg = nil })
