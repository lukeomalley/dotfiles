vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazy_path) then
  local lazy_repo = 'https://github.com/folke/lazy.nvim.git'
  local clone_output = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazy_repo, lazy_path })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { clone_output, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazy_path)

local dark_rock_theme_path = vim.fn.expand('~/code/dark-rock-theme/nvim')
local has_dark_rock_theme = vim.fn.isdirectory(dark_rock_theme_path) == 1

local plugin_specs = {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    },
  },

  'christoomey/vim-tmux-navigator',

  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    }
  },

  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      terminal = {
        win = {
          position = 'bottom',
          height = 0.3,
          border = 'none',
          wo = {
            number = false,
            relativenumber = false,
            signcolumn = 'no',
            statuscolumn = '',
            winbar = '',
            winhighlight = 'Normal:Normal,NormalNC:Normal,EndOfBuffer:Normal,SignColumn:Normal',
          },
        },
      },
    },
    keys = {
      {
        '<leader>tt',
        function()
          Snacks.terminal.toggle()
        end,
        mode = { 'n', 't' },
        desc = 'Toggle Terminal',
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
  },

  { -- Additional text objects via treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'lewis6991/gitsigns.nvim',

  -- { "catppuccin/nvim", name = "catppuccin" },
  'sainnhe/gruvbox-material',
  'nvim-lualine/lualine.nvim',           -- Fancier statusline
  'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
  'numToStr/Comment.nvim',               -- "gc" to comment visual regions/lines
  'tpope/vim-sleuth',                    -- Detect tabstop and shiftwidth automatically

  'nvim-tree/nvim-tree.lua',
  'nvim-tree/nvim-web-devicons',

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = 'master', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable 'make' == 1 },

  -- Surround
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    config = function()
      local biome_config_files = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
      local prettier_config_files = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        ".prettierrc.ts",
        ".prettierrc.cts",
        ".prettierrc.mts",
        ".prettierrc.toml",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
        "prettier.config.ts",
        "prettier.config.cts",
        "prettier.config.mts",
      }

      local function get_buffer_directory(bufnr)
        local buffer_name = vim.api.nvim_buf_get_name(bufnr)
        if buffer_name == "" then
          return vim.uv.cwd()
        end

        return vim.fs.dirname(buffer_name)
      end

      local function has_root_file(bufnr, file_names)
        return vim.fs.root(get_buffer_directory(bufnr), file_names) ~= nil
      end

      local function has_package_json_prettier_config(bufnr)
        local package_json = vim.fs.find("package.json", {
          path = get_buffer_directory(bufnr),
          upward = true,
        })[1]
        if not package_json then
          return false
        end

        local ok, package_data = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), "\n"))
        return ok and package_data.prettier ~= nil
      end

      local function web_formatters(bufnr)
        if has_root_file(bufnr, biome_config_files) then
          return { "biome", lsp_format = "never" }
        end

        if has_root_file(bufnr, prettier_config_files) or has_package_json_prettier_config(bufnr) then
          return { "prettier", lsp_format = "never" }
        end

        return { "oxfmt", lsp_format = "never" }
      end

      require("conform").setup({
        -- Map of filetype to formatters
        formatters_by_ft = {
          javascript = web_formatters,
          javascriptreact = web_formatters,
          typescript = web_formatters,
          typescriptreact = web_formatters,
          json = web_formatters,
          jsonc = web_formatters,
          json5 = web_formatters,
          css = web_formatters,
          graphql = web_formatters,
          handlebars = web_formatters,
          html = web_formatters,
          less = web_formatters,
          markdown = web_formatters,
          scss = web_formatters,
          toml = web_formatters,
          vue = web_formatters,
          yaml = web_formatters,
          python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
          -- Use LSP for other languages
          go = { lsp_format = "prefer" },
          lua = { lsp_format = "prefer" },
        },
        -- Set default options - fallback to LSP for filetypes not listed above
        default_format_opts = {
          lsp_format = "fallback",
        },
        -- Format after save so slow formatters do not block editing.
        format_after_save = {
          lsp_format = "fallback",
        },
        -- Notify on errors
        notify_on_error = true,
      })
    end,
  },
}

if has_dark_rock_theme then
  table.insert(plugin_specs, {
    dir = dark_rock_theme_path,
    name = 'dark-rock-theme',
    lazy = false,
    priority = 1000,
  })
end

local has_custom_plugins, custom_plugins = pcall(require, 'custom.plugins')
if has_custom_plugins then
  local add_plugin_spec = function(plugin_spec)
    table.insert(plugin_specs, plugin_spec)
  end

  local custom_plugin_specs = custom_plugins(add_plugin_spec)
  if type(custom_plugin_specs) == 'table' then
    vim.list_extend(plugin_specs, custom_plugin_specs)
  end
end

require('lazy').setup({
  spec = plugin_specs,
  install = { colorscheme = { 'gruvbox-material' } },
  checker = { enabled = false },
  rocks = { enabled = false },
})


-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Set the tab width
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Set nowrap
vim.opt.wrap = false

-- Use the system clipboard
vim.opt.clipboard = "unnamedplus"

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.ttimeoutlen = 10  -- Faster terminal key code recognition (helps with Ctrl+Space, etc.)
vim.wo.signcolumn = 'yes'

-- Set colorscheme
vim.o.termguicolors = true
if has_dark_rock_theme then
  vim.g.dark_rock_transparent = true
  vim.cmd.colorscheme('night-rock')
else
  vim.g.gruvbox_material_transparent_background = 2
  vim.cmd.colorscheme('gruvbox-material')
end

local function set_dark_rock_float_highlights()
  local ok, palette = pcall(require, 'dark-rock.palettes.' .. vim.g.colors_name)
  if not ok then
    return
  end

  local colors = palette.colors
  vim.api.nvim_set_hl(0, 'NormalFloat', { fg = colors.fg, bg = colors.bgLine })
  vim.api.nvim_set_hl(0, 'FloatBorder', { fg = colors.border })
  vim.api.nvim_set_hl(0, 'FloatTitle', { fg = colors.green, bold = true })
end
set_dark_rock_float_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = { 'dark-rock', 'night-rock', 'light-rock' },
  callback = set_dark_rock_float_highlights,
})

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader>w', "<cmd>w<cr>", { silent = true })
vim.keymap.set('i', 'jk', "<Esc>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Change the resize pane size
vim.api.nvim_set_keymap('n', '<C-w>>', '5<C-w>>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w><', '5<C-w><', { noremap = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'gruvbox-material',
    component_separators = '',
    section_separators = '',
    disabled_filetypes = {
      statusline = { 'snacks_terminal' },
    },
  },
}

-- Enable Comment.nvim
require('Comment').setup()

-- Enable `lukas-reineke/indent-blankline.nvim`
-- See :help ibl.config
require('ibl').setup({
  scope = {
    show_start = false
  }
})

-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    hidden = true,
    file_ignore_patterns = {
      "%.git/",
      "node_modules/",
      "%.next/",
      "dist/",
      "build/",
      "target/",
      "%.venv/",
      "__pycache__/",
    },
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--no-ignore-vcs",
      "--glob", "!.git/",
      "--glob", "!node_modules/",
      "--glob", "!.next/",
      "--glob", "!dist/",
      "--glob", "!build/",
      "--glob", "!target/",
    },
  },
}

-- [[ Configure Nvim Tree ]]
local function nvim_tree_on_attach(bufnr)
  local api = require "nvim-tree.api"
  local opts = function(desc)
    return { buffer = bufnr, desc = desc }
  end

  -- Default mappings
  api.config.mappings.default_on_attach(bufnr)
  vim.keymap.set('n', '<C-e>', api.tree.toggle, opts('Toggle Nvim Tree'))
end

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  on_attach = nvim_tree_on_attach,
  update_focused_file = {
    enable = true,
    update_root = true,
    ignore_list = { "help" },
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
    highlight_git = "name",
    icons = {
      show = {
        git = false,
      },
    },
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
    custom = { "^.git$" },
  },
  git = {
    enable = true,
    show_on_dirs = true,
  },
})

local function set_nvim_tree_git_highlights()
  vim.api.nvim_set_hl(0, "NvimTreeGitFileIgnoredHL", { fg = "#6c6c6c", italic = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitFolderIgnoredHL", { fg = "#6c6c6c", italic = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", { fg = "#6c6c6c", italic = true })
end
set_nvim_tree_git_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_nvim_tree_git_highlights,
})

vim.keymap.set('n', '<C-b>', ":NvimTreeClose<cr>", { desc = 'Close Nvim Tree' })
vim.keymap.set('n', '<C-e>', function()
  require('nvim-tree.api').tree.toggle({
    find_file = true,
    focus = true,
  })
end, { desc = 'Toggle Nvim Tree' })

-- [[ Configure Telescope ]]
-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

vim.keymap.set('n', '<leader>sf', function()
  require('telescope.builtin').find_files(
    require('telescope.themes').get_dropdown({
      previewer = false,
      width = 0.5,
      find_command = {
        "fd",
        "--type", "f",
        "--hidden",
        "--no-ignore-vcs",
        "--exclude", ".git",
        "--exclude", "node_modules",
        "--exclude", ".next",
        "--exclude", "dist",
        "--exclude", "build",
        "--exclude", "target",
        "--exclude", ".venv",
        "--exclude", "__pycache__",
      },
    })
  )
end, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
local treesitter_parsers = {
  'c',
  'cpp',
  'css',
  'go',
  'graphql',
  'html',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'python',
  'rust',
  'sql',
  'tsx',
  'typescript',
  'vimdoc',
  'yaml',
}

local has_treesitter, treesitter = pcall(require, 'nvim-treesitter')
if has_treesitter and type(treesitter.install) == 'function' then
  treesitter.install(treesitter_parsers)

  vim.treesitter.language.register('javascript', 'javascriptreact')
  vim.treesitter.language.register('tsx', 'typescriptreact')

  vim.api.nvim_create_autocmd('FileType', {
    pattern = {
      'c',
      'cpp',
      'css',
      'go',
      'graphql',
      'html',
      'javascript',
      'javascriptreact',
      'json',
      'jsonc',
      'lua',
      'markdown',
      'python',
      'rust',
      'sql',
      'typescript',
      'typescriptreact',
      'vimdoc',
      'yaml',
    },
    callback = function(args)
    local has_parser = pcall(vim.treesitter.start, args.buf)
    if has_parser then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    end,
  })

  require('nvim-treesitter-textobjects').setup {
    select = {
      lookahead = true,
    },
    move = {
      set_jumps = true,
    },
  }

  local treesitter_select = require('nvim-treesitter-textobjects.select')
  vim.keymap.set({ 'x', 'o' }, 'aa', function()
    treesitter_select.select_textobject('@parameter.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ia', function()
    treesitter_select.select_textobject('@parameter.inner', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'af', function()
    treesitter_select.select_textobject('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'if', function()
    treesitter_select.select_textobject('@function.inner', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ac', function()
    treesitter_select.select_textobject('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ic', function()
    treesitter_select.select_textobject('@class.inner', 'textobjects')
  end)

  local treesitter_move = require('nvim-treesitter-textobjects.move')
  vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
    treesitter_move.goto_next_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
    treesitter_move.goto_next_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
    treesitter_move.goto_next_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
    treesitter_move.goto_next_end('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
    treesitter_move.goto_previous_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
    treesitter_move.goto_previous_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
    treesitter_move.goto_previous_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
    treesitter_move.goto_previous_end('@class.outer', 'textobjects')
  end)

  local treesitter_swap = require('nvim-treesitter-textobjects.swap')
  vim.keymap.set('n', '<leader>a', function()
    treesitter_swap.swap_next('@parameter.inner')
  end)
  vim.keymap.set('n', '<leader>A', function()
    treesitter_swap.swap_previous('@parameter.inner')
  end)
else
  require('nvim-treesitter.configs').setup {
    ensure_installed = treesitter_parsers,
    highlight = {
      enable = true,
      disable = { 'markdown' },
    },
    indent = { enable = true },
  }
end

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Enable the following language servers
-- Feel free to add/remove any LSPs that you want here. They will automatically be installed
-- Uncomment clangd and rust_analyzer if you need C/C++ or Rust support
local servers = { 'basedpyright', 'ruff', 'tsgo', 'eslint', 'biome', 'lua_ls', 'gopls', 'emmet_ls' }
-- local servers = { 'clangd', 'rust_analyzer', 'basedpyright', 'ruff', 'tsgo', 'eslint', 'biome', 'lua_ls', 'gopls', 'emmet_ls' }

-- Ensure the servers above are installed
require('mason-lspconfig').setup {
  ensure_installed = servers,
  automatic_enable = servers,
}

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Turn on lsp status information
require('fidget').setup({})

-- [[ Configure LSP using vim.lsp.config (Neovim 0.11+) ]]

if not vim.g.lsp_float_preview_without_treesitter then
  local original_open_floating_preview = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    if opts and opts.disable_treesitter then
      syntax = syntax == 'markdown' and 'plaintext' or syntax
    end

    return original_open_floating_preview(contents, syntax, opts)
  end
  vim.g.lsp_float_preview_without_treesitter = true
end

local lsp_float_padding_border = {
  { ' ', 'NormalFloat' },
  { ' ', 'NormalFloat' },
  { ' ', 'NormalFloat' },
  { ' ', 'NormalFloat' },
  { ' ', 'NormalFloat' },
  { ' ', 'NormalFloat' },
  { ' ', 'NormalFloat' },
  { ' ', 'NormalFloat' },
}

local lsp_float_options = {
  border = lsp_float_padding_border,
  focusable = true,
  max_width = 80,
  max_height = 20,
  disable_treesitter = true,
}

local diagnostic_float_options = vim.tbl_extend('force', {}, lsp_float_options)
diagnostic_float_options.disable_treesitter = nil

-- LspAttach autocmd - replaces the old on_attach function
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end
    if client and vim.tbl_contains({ 'tsgo', 'eslint', 'biome' }, client.name) then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    -- Helper function for LSP keymaps
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    local show_hover_help = function()
      local cursor_position = vim.api.nvim_win_get_cursor(0)
      local cursor_diagnostics = vim.diagnostic.get(bufnr, {
        lnum = cursor_position[1] - 1,
      })

      if #cursor_diagnostics > 0 then
        vim.diagnostic.open_float(nil, vim.tbl_extend('force', diagnostic_float_options, {
          scope = 'cursor',
          prefix = '  ',
        }))
        return
      end

      vim.lsp.buf.hover(lsp_float_options)
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('gh', show_hover_help, 'Hover Help')
    nmap('<C-k>', function()
      vim.lsp.buf.signature_help(lsp_float_options)
    end, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end,
})

-- Example custom configuration for lua
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

-- Configure LSP servers using vim.lsp.config (Neovim 0.11+)

-- Default config for all servers
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- clangd (uncomment if needed)
-- vim.lsp.config('clangd', {
--   capabilities = capabilities,
-- })

-- rust_analyzer (uncomment if needed)
-- vim.lsp.config('rust_analyzer', {
--   capabilities = capabilities,
-- })

-- basedpyright
vim.lsp.config('basedpyright', {
  capabilities = capabilities,
})

-- ruff
vim.lsp.config('ruff', {
  capabilities = capabilities,
})

-- gopls
vim.lsp.config('gopls', {
  capabilities = capabilities,
})

-- tsgo (TypeScript/JavaScript)
vim.lsp.config('tsgo', {
  capabilities = capabilities,
})

-- eslint
vim.lsp.config('eslint', {
  capabilities = capabilities,
})

-- biome
vim.lsp.config('biome', {
  capabilities = capabilities,
})

-- lua_ls
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      telemetry = { enable = false },
    },
  },
})

-- emmet_ls
vim.lsp.config('emmet_ls', {
  capabilities = capabilities,
  filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
  init_options = {
    html = {
      options = {
        ["bem.enabled"] = true,
      },
    },
  },
})

-- Enable all the servers
-- vim.lsp.enable('clangd')
-- vim.lsp.enable('rust_analyzer')
vim.lsp.enable('basedpyright')
vim.lsp.enable('ruff')
vim.lsp.enable('tsgo')
vim.lsp.enable('eslint')
vim.lsp.enable('biome')
vim.lsp.enable('gopls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('emmet_ls')

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged },
    completeopt = 'menu,menuone,noselect',
    keyword_length = 1,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() and cmp.get_selected_entry() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp', keyword_length = 1 },
    { name = 'luasnip' },
  },
}

-- Format on save is now handled by conform.nvim (see plugin config above)

-- Trouble (error viewer) settings
vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end)
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end)
-- vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end)
