---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      -- Core
      "lua",
      "vim",
      "vimdoc",
      "query",

      -- DALP stack
      "typescript",
      "tsx",
      "javascript",
      "json",
      "json5",
      "jsonc",
      "html",
      "css",
      "scss",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
      "sql",
      "graphql",
      "solidity",

      -- Infra
      "dockerfile",
      "helm",
      "bash",

      -- Config
      "regex",
      "gitignore",
      "diff",
      "git_rebase",
    },
  },
}
