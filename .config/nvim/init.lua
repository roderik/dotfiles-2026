-- Sensible defaults
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Plugin manager (lazy.nvim) - auto-installs itself
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- File explorer as a buffer (just press - to open)
  { "stevearc/oil.nvim", opts = {} },

  -- Fuzzy finder (space+f to find files, space+g to grep)
  { "ibhagwan/fzf-lua", opts = {},
    keys = {
      { "<space>f", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<space>g", "<cmd>FzfLua live_grep<cr>", desc = "Grep in files" },
      { "<space>b", "<cmd>FzfLua buffers<cr>", desc = "Open buffers" },
    },
  },

  -- Colorscheme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    config = function() vim.cmd.colorscheme("catppuccin") end },
})
