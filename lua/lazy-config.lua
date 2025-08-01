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


require("lazy").setup({
    require("plugins.tree"),
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "neovim/nvim-lspconfig" },
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
    {
        "williamboman/mason.nvim",
        cmd = "Mason",            -- load on :Mason
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end,
    },


    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        after = "mason.nvim",
        lazy = false,
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "pylsp", "rust_analyzer" },   -- ← use pylsp instead of pyright
                handlers = {
                    ["pylsp"] = function()
                        require("lspconfig").pylsp.setup({
                            on_attach    = require("plugins.lsp").on_attach,
                            capabilities = require("plugins.lsp").capabilities,
                            settings = {
                                pylsp = {
                                    plugins = {
                                        pycodestyle = { enabled = false },  -- disable PEP8
                                        black       = { enabled = true   },  -- enable Black
                                        ruff        = { enabled = true   },  -- enable Ruff
                                    },
                                },
                            },
                        })
                    end,
                    ["rust_analyzer"] = function()
                        require("lspconfig").rust_analyzer.setup({
                            on_attach    = require("plugins.lsp").on_attach,
                            capabilities = require("plugins.lsp").capabilities,
                            -- here you can add any rust-analyzer–specific settings if you like:
                            -- settings = { ["rust-analyzer"] = { cargo = { allFeatures = true } } },
                        })
                    end,
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            on_attach    = require("plugins.lsp").on_attach,
                            capabilities = require("plugins.lsp").capabilities,
                        })
                    end,
                },
            })
        end,
    },})

vim.opt.undofile   = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 1000
local undo_root = vim.fn.stdpath('state') .. '/undo'
vim.opt.undodir = undo_root .. '//'



vim.api.nvim_set_hl(0, "StatusLine",   { bg = "none", fg = nil })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none", fg = nil })

require("plugins.lsp")
require("plugins.treesitter")
