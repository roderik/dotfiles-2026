return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "solidity" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solidity_ls_nomicfoundation = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        solidity = { "forge_fmt" },
      },
    },
  },
}
