---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
      severity_sort = true,
      float = { border = "rounded" },
    },
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        -- Zed-like feel
        scrolloff = 8, -- keep 8 lines visible above/below cursor
        sidescrolloff = 8,
        cursorline = true, -- highlight current line
        termguicolors = true,
        showmode = false, -- statusline shows mode already
        clipboard = "unnamedplus", -- system clipboard (like Zed)
        undofile = true, -- persistent undo
        splitbelow = true, -- new splits go below
        splitright = true, -- new splits go right
        ignorecase = true, -- case insensitive search
        smartcase = true, -- unless uppercase used
        updatetime = 250, -- faster CursorHold
        timeoutlen = 300, -- faster which-key popup
        completeopt = "menu,menuone,noselect",
        pumheight = 10, -- popup menu height
        laststatus = 3, -- global statusline
        smoothscroll = true,
      },
      g = {},
    },
    -- Mappings: Space is leader (AstroNvim default)
    -- These add Zed/VSCode-familiar bindings on top
    mappings = {
      n = {
        -- Buffer navigation
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- Zed/VSCode-style bindings (Cmd key = D on macOS terminal)
        -- File finder (Cmd+P equivalent → Leader+ff already exists, add Ctrl-p too)
        ["<C-p>"] = { function() require("telescope.builtin").find_files() end, desc = "Find files" },

        -- Quick save
        ["<C-s>"] = { "<cmd>w<cr>", desc = "Save file" },

        -- Close buffer (like Cmd+W)
        ["<Leader>w"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },

        -- Split navigation (Ctrl+hjkl)
        ["<C-h>"] = { "<C-w>h", desc = "Move to left split" },
        ["<C-j>"] = { "<C-w>j", desc = "Move to below split" },
        ["<C-k>"] = { "<C-w>k", desc = "Move to above split" },
        ["<C-l>"] = { "<C-w>l", desc = "Move to right split" },

        -- Move lines up/down (Alt+j/k like VSCode)
        ["<A-j>"] = { "<cmd>m .+1<cr>==", desc = "Move line down" },
        ["<A-k>"] = { "<cmd>m .-2<cr>==", desc = "Move line up" },

        -- Quick actions
        ["<Leader>a"] = { desc = "AI/Actions" },
      },
      i = {
        -- Save from insert mode
        ["<C-s>"] = { "<esc><cmd>w<cr>", desc = "Save file" },

        -- Move lines in insert mode
        ["<A-j>"] = { "<esc><cmd>m .+1<cr>==gi", desc = "Move line down" },
        ["<A-k>"] = { "<esc><cmd>m .-2<cr>==gi", desc = "Move line up" },
      },
      v = {
        -- Move selected lines up/down
        ["<A-j>"] = { ":m '>+1<cr>gv=gv", desc = "Move selection down" },
        ["<A-k>"] = { ":m '<-2<cr>gv=gv", desc = "Move selection up" },

        -- Stay in visual mode after indenting
        ["<"] = { "<gv", desc = "Unindent" },
        [">"] = { ">gv", desc = "Indent" },
      },
      t = {
        -- Terminal escape
        ["<C-\\>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
      },
    },
    -- Auto commands
    autocmds = {
      -- Auto-save on focus lost (like Zed)
      autosave = {
        {
          event = { "FocusLost", "BufLeave" },
          desc = "Auto-save on focus lost",
          callback = function()
            -- Only save if buffer is modified and has a filename
            if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
              vim.api.nvim_command("silent! write")
            end
          end,
        },
      },
      -- Highlight yanked text briefly
      highlightyank = {
        {
          event = "TextYankPost",
          desc = "Highlight yanked text",
          callback = function() vim.highlight.on_yank { higroup = "Visual", timeout = 200 } end,
        },
      },
      -- Return to last edit position when opening files
      restore_cursor = {
        {
          event = "BufReadPost",
          desc = "Restore cursor position",
          callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end,
        },
      },
    },
  },
}
