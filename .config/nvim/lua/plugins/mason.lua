---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "lua-language-server",
        "vtsls", -- TypeScript (fast, monorepo-friendly)
        "tailwindcss-language-server",
        "json-lsp",
        "yaml-language-server",
        "html-lsp",
        "css-lsp",
        "dockerfile-language-server",
        "helm-ls",
        "solidity", -- Solidity LSP (nomicfoundation)
        "taplo", -- TOML

        -- Formatters
        "stylua",
        "biome", -- fast TS/JS formatter + linter
        "prettier", -- fallback for non-biome files (CSS, HTML, MD)

        -- Linters
        "eslint-lsp",

        -- Tools
        "tree-sitter-cli",
      },
    },
  },
}
