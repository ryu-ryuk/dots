-- Setup plugins
require 'core.options'
require 'core.keymaps'
require 'core.snippets'

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require('lazy').setup {
  { import = 'plugins.telescope' },
  { import = 'plugins.treesitter' },
  { import = 'plugins.lsp' },
  { import = 'plugins.autocompletion' },
  { import = 'plugins.none-ls' },
  --  { import = 'plugins.lualine' },
  { import = 'plugins.bufferline' },
  { import = 'plugins.neo-tree' },
  -- { import = 'plugins.alpha' },
  { import = 'plugins.indent-blackline' },
  { import = 'plugins.lazygit' },
  { import = 'plugins.comment' },
  { import = 'plugins.debug' },
  { import = 'plugins.gitsigns' },
  { import = 'plugins.misc' },
  { import = 'plugins.catppuccin' },
  { import = 'plugins.harpoon' },
  --  { import = "plugins.aerial" },
  { import = 'plugins.ui' },
  { import = 'plugins.snacks' },
  { import = 'plugins.conform' },
  { import = 'plugins.diffview' },
  { import = 'plugins.yanky' },
  { import = 'plugins.vim-tmux-navigator' },
}

-- Function to check if a file exists
local function file_exists(file)
  local f = io.open(file, 'r')
  if f then
    f:close()
    return true
  else
    return false
  end
end

-- Path to the session file
local session_file = '.session.vim'

-- Check if the session file exists in the current directory
if file_exists(session_file) then
  vim.cmd('source ' .. session_file)
end
