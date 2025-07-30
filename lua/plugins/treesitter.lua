require("nvim-treesitter.configs").setup({
    ensure_installed = { "python", "cpp", "lua", "bash", "json", "yaml", "javascript", "typescript", "tsx", "html", "css" },
    highlight = { enable = true },
    indent = { enable = true },
})
