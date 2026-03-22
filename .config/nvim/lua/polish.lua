-- Final polish — runs last in setup

-- Disable some built-in providers for faster startup
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Solidity filetype detection
vim.filetype.add {
  extension = {
    sol = "solidity",
  },
}
