---@type LazySpec
return {
  -- Multi-cursor (Cmd+D / Ctrl+D equivalent from VSCode/Zed)
  {
    "mg979/vim-visual-multi",
    event = "BufEnter",
    init = function()
      vim.g.VM_theme = "neon"
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>", -- Cmd+D / Ctrl+D to select next occurrence
        ["Find Subword Under"] = "<C-d>",
      }
    end,
  },

  -- Better search & replace UI
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = {
      { "<Leader>sr", function() require("spectre").open() end, desc = "Search & Replace (project)" },
      {
        "<Leader>sw",
        function() require("spectre").open_visual { select_word = true } end,
        desc = "Search current word",
      },
    },
  },

  -- Catppuccin config
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = false,
      dim_inactive = { enabled = true, percentage = 0.15 },
      integrations = {
        cmp = true,
        flash = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        mason = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotree = true,
        noice = true,
        notify = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
      },
    },
  },

  -- Noice: better cmdline, messages, and notifications
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        view = "cmdline_popup", -- floating cmdline (Zed-like)
      },
      messages = {
        view_search = false, -- use native search counter
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true },
      },
      presets = {
        bottom_search = false,
        command_palette = true, -- Zed-like command palette feel
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- Todo comments highlighting
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<Leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    },
  },

  -- Better terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = {
      { "<C-`>", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle terminal", mode = { "n", "t" } },
      { "<Leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<Leader>th", "<cmd>ToggleTerm direction=horizontal size=15<cr>", desc = "Horizontal terminal" },
      { "<Leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Vertical terminal" },
    },
    opts = {
      float_opts = {
        border = "rounded",
        width = function() return math.floor(vim.o.columns * 0.85) end,
        height = function() return math.floor(vim.o.lines * 0.8) end,
      },
    },
  },
}
