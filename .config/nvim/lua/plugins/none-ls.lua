---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Biome for TS/JS (fast, used in DALP)
      null_ls.builtins.formatting.biome,
      -- Prettier as fallback for CSS, HTML, Markdown, etc.
      null_ls.builtins.formatting.prettier.with {
        filetypes = { "css", "scss", "html", "markdown", "yaml", "graphql" },
      },
    })
  end,
}
