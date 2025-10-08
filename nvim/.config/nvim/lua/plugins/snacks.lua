return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          registers = {
            confirm = { action = { "yank", "close" }, source = "registers", notify = false },
          },
        },
      },
    },
  },
}
