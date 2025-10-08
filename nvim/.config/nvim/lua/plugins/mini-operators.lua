return {
  "nvim-mini/mini.operators",
  keys = {
    { "go=", desc = "Evaluate" },
    { "gox", desc = "Exchance" },
    { "gom", desc = "Multiply" },
    { "gor", desc = "Replace" },
    { "gos", desc = "Sort" },
  },
  opts = {
    evaluate = { prefix = "go=" }, -- disable
    exchange = { prefix = "gox", reindent_linewise = true },
    multiply = {
      prefix = "gom",
    },
    replace = { prefix = "gor", reindent_linewise = true },
    sort = { prefix = "gos" },
  },
  config = function(_, opts)
    require("mini.operators").setup(opts)
  end,
}
