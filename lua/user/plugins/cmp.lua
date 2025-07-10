local cmp     = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  completion = {
    autocomplete = false,
  },

  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
  },

  sources = {
    { name = "luasnip" },
  },
})