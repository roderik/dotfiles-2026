-- Telescope customization for monorepo performance
---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      -- Zed-like: clean, minimal
      prompt_prefix = "  ",
      selection_caret = "  ",
      path_display = { "truncate" },
      sorting_strategy = "ascending",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.5,
        },
        width = 0.87,
        height = 0.80,
      },
      -- Monorepo performance: ignore heavy dirs
      file_ignore_patterns = {
        "node_modules/",
        ".git/",
        "dist/",
        "build/",
        ".next/",
        "coverage/",
        "drizzle/",
        ".turbo/",
        "artifacts/",
        "cache/",
        "typechain-types/",
      },
    },
  },
}
