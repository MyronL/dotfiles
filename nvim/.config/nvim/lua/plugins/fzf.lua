return {
  "ibhagwan/fzf-lua",
  opts = {
    files = {
      fd_opts = "--color=never --type f --hidden --follow --no-ignore --exclude .git --exclude node_modules",
    },
    grep = {
      rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --no-ignore --glob '!.git' --glob '!node_modules'",
    },
  },
  keys = {
    { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
  },
}
