local M = {}

M.capabilities = vim.lsp.protocol.make_client_capabilities()
function M.on_attach(client, bufnr)
  local bufmap = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  vim.diagnostic.config({ virtual_text = true }, { buffer = bufnr })

  bufmap("n", "gd", vim.lsp.buf.definition,       "Go to definition")
  bufmap("n", "gD", vim.lsp.buf.declaration,      "Go to declaration")
end

return M
