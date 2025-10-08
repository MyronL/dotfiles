-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.g.vscode then
  -- VSCode Neovim
  vim.opt.clipboard:append("unnamedplus")
  require("config.vscode")
else
  -- Ordinary Neovim
  require("config.lazy")
end
