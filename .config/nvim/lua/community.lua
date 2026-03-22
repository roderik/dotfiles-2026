---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- Theme
  { import = "astrocommunity.colorscheme.catppuccin" },

  -- Language packs (LSP + treesitter + formatter in one)
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.helm" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.sql" },

  -- Motion — jump anywhere with 2 keystrokes
  { import = "astrocommunity.motion.flash-nvim" },

  -- Smooth scrolling
  { import = "astrocommunity.scrolling.nvim-scrollbar" },

  -- Indent guides with scope awareness
  { import = "astrocommunity.indent.indent-blankline-nvim" },

  -- Better diagnostics list
  { import = "astrocommunity.diagnostics.trouble-nvim" },

  -- Git integration
  { import = "astrocommunity.git.diffview-nvim" },

  -- Surround (cs"' to change quotes, etc.)
  { import = "astrocommunity.editing-support.nvim-treesitter-endwise" },

  -- Rainbow delimiters for nested brackets
  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },

  -- Better yanking
  { import = "astrocommunity.editing-support.yanky-nvim" },
}
