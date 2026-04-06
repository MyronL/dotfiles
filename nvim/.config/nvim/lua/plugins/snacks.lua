return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
            ignored = true,
          },
          grep = {
            hidden = true,
            ignored = true,
          },
          registers = {
            confirm = { action = { "yank", "close" }, source = "registers", notify = false },
          },
        },
      },
    },
  },
}
