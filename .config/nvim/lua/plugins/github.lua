return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {},
  keys = {
    { "<leader>gi", "<cmd>Octo issue list<cr>", desc = "GitHub Issues" },
    { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "GitHub PRs" },
  },
}
