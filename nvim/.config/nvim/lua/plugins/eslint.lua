return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = { eslint = {} },
    setup = {
      eslint = function()
        Snacks.util.lsp.on({ name = "eslint" }, function(_, client)
          client.server_capabilities.documentFormattingProvider = true
        end)
        Snacks.util.lsp.on({ name = "vtsls" }, function(_, client)
          client.server_capabilities.documentFormattingProvider = false
        end)
      end,
    },
  },
}
