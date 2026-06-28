-- =================================================
-- Bootstrap
-- =================================================

-- Enable the Lua module bytecode cache for faster startup (Neovim 0.9+).
vim.loader.enable()

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
      { clone_output,                   'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazy_path)

-- =================================================
-- Options
-- =================================================
-- See `:help vim.o`

-- Highlight all matches of the last search. Cleared on demand with <Esc>
-- (mapped in the keymaps section) so stale highlights don't linger.
vim.o.hlsearch = true

-- Make line numbers default
vim.o.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Keep context around the cursor when scrolling.
vim.o.scrolloff = 8

-- Smooth scrolling that works per screen-line, so <C-d>/<C-f> behave sanely
-- with wrapped lines instead of jumping by whole buffer lines.
vim.o.smoothscroll = true

-- Open new splits to the right and below, where the eye expects them.
vim.o.splitright = true
vim.o.splitbelow = true

-- Keep the text on screen stable when splits open or close above the cursor.
vim.o.splitkeep = 'screen'

-- Live preview of :substitute / :s in a split as you type.
vim.o.inccommand = 'split'

-- Highlight the line the cursor is on.
vim.o.cursorline = true

-- Prompt to save instead of erroring on :q with unsaved changes.
vim.o.confirm = true

-- Set the tab width
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Set nowrap
vim.o.wrap = false

-- Use the system clipboard. Deferred so clipboard-provider detection does not
-- run during startup.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.ttimeoutlen = 10 -- Faster terminal key code recognition (helps with Ctrl+Space, etc.)
vim.o.signcolumn = 'yes'

vim.o.termguicolors = true

-- Lualine shows mode; noice routes cmdline/messages away from the native row.
vim.o.showmode = false
vim.o.cmdheight = 0

-- Suppress the built-in intro message ("Type :qa and press <Enter> to exit
-- Nvim..."). With cmdheight = 0 it can leak into the statusline row instead of
-- clearing on first keystroke.
vim.opt.shortmess:append('I')

-- =================================================
-- Keymaps
-- =================================================
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader>w', "<cmd>w<cr>", { silent = true })
vim.keymap.set('i', 'jk', "<Esc>", { silent = true })

-- Clear search highlight (hlsearch) on <Esc> in normal mode.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Change the resize pane size
vim.keymap.set('n', '<C-w>>', '5<C-w>>', { noremap = true })
vim.keymap.set('n', '<C-w><', '5<C-w><', { noremap = true })

-- =================================================
-- Diagnostics
-- =================================================
-- Sort by severity so the worst problem wins the sign column and the float.
-- VSCode-style: no inline text cluttering lines or pushing them down. The gutter
-- signs and underline are the live signal; the full message shows on hover (float)
-- or via <leader>e, [d / ]d.
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E',
      [vim.diagnostic.severity.WARN] = 'W',
      [vim.diagnostic.severity.INFO] = 'I',
      [vim.diagnostic.severity.HINT] = 'H',
    },
  },
  virtual_text = false,
  virtual_lines = false,
  float = {
    border = 'rounded',
    source = true,
  },
})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>gd', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = '[G]oto next [D]iagnostic' })
vim.keymap.set('n', '<leader>gD', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = '[G]oto previous [D]iagnostic' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic float' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })

-- =================================================
-- Autocommands
-- =================================================

-- Highlight on yank.
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Nudge the statusline to redraw once the cursor settles so the gitsigns
-- current-line blame (shown in lualine_c) appears promptly. gitsigns sets
-- `b:gitsigns_blame_line` on a short debounce but emits no event, and lualine
-- otherwise only re-renders on cursor movement or its periodic timer. CursorHold
-- fires after `updatetime` (250ms), by which point the blame (delay 100ms) has
-- resolved.
local blame_status_group = vim.api.nvim_create_augroup('UserBlameStatus', { clear = true })
vim.api.nvim_create_autocmd('CursorHold', {
  group = blame_status_group,
  callback = function()
    if vim.b.gitsigns_blame_line_dict ~= nil then
      vim.cmd('redrawstatus')
    end
  end,
})

-- =================================================
-- Local constants
-- =================================================

local dark_rock_theme_path = vim.fn.expand('~/code/dark-rock-theme/nvim')
local has_dark_rock_theme = vim.fn.isdirectory(dark_rock_theme_path) == 1

-- Single source of truth for treesitter languages. Each entry maps a parser to
-- the filetypes that should enable treesitter features. `filetypes` is empty for
-- parsers that only appear as injected languages (e.g. markdown_inline). When a
-- filetype name differs from its parser (e.g. typescriptreact -> tsx) it is
-- registered with vim.treesitter in the treesitter config below. The install
-- list and the FileType autocmd pattern are derived from this table so adding a
-- language only requires editing one place.
local treesitter_languages = {
  { parser = 'c',               filetypes = { 'c' } },
  { parser = 'cpp',             filetypes = { 'cpp' } },
  { parser = 'css',             filetypes = { 'css' } },
  { parser = 'go',              filetypes = { 'go' } },
  { parser = 'graphql',         filetypes = { 'graphql' } },
  { parser = 'html',            filetypes = { 'html' } },
  { parser = 'javascript',      filetypes = { 'javascript', 'javascriptreact' } },
  { parser = 'json',            filetypes = { 'json', 'jsonc' } },
  { parser = 'lua',             filetypes = { 'lua' } },
  { parser = 'markdown',        filetypes = { 'markdown' } },
  { parser = 'markdown_inline', filetypes = {} },
  { parser = 'python',          filetypes = { 'python' } },
  { parser = 'rust',            filetypes = { 'rust' } },
  { parser = 'sql',             filetypes = { 'sql' } },
  { parser = 'tsx',             filetypes = { 'typescriptreact' } },
  { parser = 'typescript',      filetypes = { 'typescript' } },
  { parser = 'vimdoc',          filetypes = { 'vimdoc' } },
  { parser = 'yaml',            filetypes = { 'yaml' } },
}

local treesitter_parsers = {}
local treesitter_filetypes = {}
for _, language in ipairs(treesitter_languages) do
  table.insert(treesitter_parsers, language.parser)
  for _, filetype in ipairs(language.filetypes) do
    table.insert(treesitter_filetypes, filetype)
  end
end

-- Directories pruned from every file/grep picker source. Passed to fd/rg as
-- exclude globs by snacks.
local search_exclude_globs = {
  '.git',
  'node_modules',
  '.next',
  'dist',
  'build',
  'target',
  '.venv',
  '__pycache__',
}

-- LSP "go to references" returns whatever the language server finds, which for
-- TypeScript and friends includes hits inside node_modules (bundled .d.ts) and
-- build output. Reuse the same prune list as the file/grep pickers so `gr` only
-- surfaces references in real source. Matches a directory segment anywhere in
-- the path (so nested node_modules in monorepos are caught too), unlike snacks'
-- prefix-only `filter.paths`.
local function path_in_excluded_dir(path)
  for _, dir in ipairs(search_exclude_globs) do
    if path:find('/' .. dir .. '/', 1, true) then
      return true
    end
  end
  return false
end

local lsp_references_filter = {
  filter = function(item)
    return not path_in_excluded_dir(item.file or '')
  end,
}

-- Escape hatch for `gR`: include every reference the server returns, including
-- node_modules/build output (e.g. when editing a dependency directly). An empty
-- filter table wouldn't work here: snacks deep-merges it over the source default
-- so the default predicate would survive. An explicit allow-all predicate
-- overrides it.
local lsp_references_show_all = {
  filter = function()
    return true
  end,
}

-- =================================================
-- Local helpers
-- =================================================

-- A "real file" buffer is a listed, normal-buftype buffer that isn't one of the
-- snacks scratch buffers (dashboard, explorer, pickers).
local function buffer_is_real_file(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if not vim.bo[bufnr].buflisted then
    return false
  end
  if vim.bo[bufnr].buftype ~= '' then
    return false
  end
  -- Snacks windows (dashboard, explorer, pickers) all use a `snacks` filetype
  -- prefix; none of them are real files.
  return vim.bo[bufnr].filetype:find('snacks') == nil
end

-- True when a real file is actually displayed in some window right now. Unlike a
-- buffer-list scan, this ignores files that merely linger hidden, so closing the
-- explorer while only the dashboard (or nothing) is on screen counts as "empty".
local function has_displayed_file_buffer()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      if buffer_is_real_file(vim.api.nvim_win_get_buf(win)) then
        return true
      end
    end
  end
  return false
end

local function has_open_file_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if buffer_is_real_file(bufnr) then
      return true
    end
  end
  return false
end

local function find_main_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      local bufnr = vim.api.nvim_win_get_buf(win)
      -- Skip snacks windows (e.g. the explorer sidebar) so the dashboard never
      -- lands in them.
      if vim.bo[bufnr].filetype:find('snacks') == nil then
        return win
      end
    end
  end
  return nil
end

local function open_dashboard_in_window(win)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return
  end
  if not (Snacks and Snacks.dashboard) then
    return
  end
  Snacks.dashboard.open({ win = win })
end

-- Build the dashboard "Git Status" lines directly (via git, not a terminal
-- buffer) so the section never shows Neovim's "[Process exited 0]" notice and
-- sizes itself to the real output. Returns a list of snacks dashboard items,
-- one per line. Empty when not inside a git repository.
local dashboard_git_max_changed_files = 6

local function dashboard_git_status()
  if not (Snacks and Snacks.git and Snacks.git.get_root()) then
    return {}
  end

  local current_branch = vim.fn.systemlist({ 'git', 'branch', '--show-current' })[1]
  if vim.v.shell_error ~= 0 then
    return {}
  end

  local items = {}

  local branch_label = ' ' .. (current_branch ~= '' and current_branch or 'detached HEAD')
  local upstream_counts = vim.fn.systemlist({
    'git', 'rev-list', '--left-right', '--count', '@{upstream}...HEAD',
  })[1]
  if vim.v.shell_error == 0 and upstream_counts then
    local behind, ahead = upstream_counts:match('(%d+)%s+(%d+)')
    if ahead and tonumber(ahead) > 0 then
      branch_label = branch_label .. ' ↑' .. ahead
    end
    if behind and tonumber(behind) > 0 then
      branch_label = branch_label .. ' ↓' .. behind
    end
  end
  -- Top padding on the first row renders a small gap below the section title.
  items[#items + 1] = { text = { { branch_label, hl = 'special' } }, padding = { 0, 1 } }

  local changed_files = vim.fn.systemlist({ 'git', 'status', '--porcelain' })
  if vim.v.shell_error ~= 0 then
    return items
  end

  if #changed_files == 0 then
    items[#items + 1] = { text = { { '  working tree clean', hl = 'dir' } } }
    return items
  end

  for index, line in ipairs(changed_files) do
    if index > dashboard_git_max_changed_files then
      local remaining = #changed_files - dashboard_git_max_changed_files
      items[#items + 1] = { text = { { ('  +%d more'):format(remaining), hl = 'dir' } } }
      break
    end

    local status_code = line:sub(1, 2)
    local file_name = vim.fn.fnamemodify(line:sub(4), ':t')
    local status_hl = 'DiagnosticInfo'
    if status_code:find('?') then
      status_hl = 'dir'
    elseif status_code:find('D') then
      status_hl = 'DiagnosticError'
    elseif status_code:find('M') or status_code:find('U') then
      status_hl = 'DiagnosticWarn'
    end

    items[#items + 1] = {
      text = {
        { status_code, hl = status_hl, width = 3 },
        { file_name,   hl = 'file' },
      },
    }
  end

  return items
end

-- Menu items for the dashboard. Materialized directly (not via the built-in
-- `keys` section) so we can set explicit padding on the first item. The snacks
-- section render path overwrites the first child's padding with `{ 0, top }`
-- when the section has both `gap` and a top-padding component, which collapses
-- the gap between the first and second items. Returning the items with
-- per-item padding sidesteps that and gives an even rhythm between rows.
local dashboard_menu_items = {
  { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
  { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
  { icon = ' ', key = 'r', desc = 'Recent',    action = ":lua Snacks.dashboard.pick('oldfiles')" },
  { icon = ' ', key = 'e', desc = 'Explorer',  action = ':lua Snacks.explorer()' },
  { icon = ' ', key = 'q', desc = 'Quit',      action = ':qa' },
}

local function dashboard_menu_keys()
  local items = vim.deepcopy(dashboard_menu_items)
  -- Each item carries its own bottom padding so rows are evenly spaced. The
  -- first item also gets a top padding to leave a blank line between the
  -- section title and the first menu entry, matching the other sections.
  for index, item in ipairs(items) do
    item.padding = { index == #items and 0 or 1, index == 1 and 1 or 0 }
  end
  return items
end

-- Recent files for the dashboard, rendered with the select number to the LEFT
-- of the file name so each number is easy to associate with its row. The
-- snacks built-in right-aligns the key on the far edge instead. Reuses the
-- built-in oldfiles gathering, then rewrites each row's text and binds an
-- explicit numeric key (providing `text` bypasses the default icon/key layout,
-- while the keymap is still bound from `key`).
local dashboard_recent_files_limit = 8

local function dashboard_recent_files()
  if not (Snacks and Snacks.dashboard) then
    return {}
  end

  local gather = Snacks.dashboard.sections.recent_files({ cwd = true, limit = dashboard_recent_files_limit })
  local files = gather()

  for index, item in ipairs(files) do
    local icon = Snacks.dashboard.icon(item.file, 'file')
    item.text = {
      { tostring(index),                     hl = 'key' },
      { '  ' },
      { icon[1],                             hl = icon.hl, width = 2 },
      { vim.fn.fnamemodify(item.file, ':t'), hl = 'file' },
    }
    item.key = tostring(index)
    item.autokey = nil
    item.icon = nil
  end

  -- Top padding on the first row renders a small gap below the section title.
  if files[1] then
    files[1].padding = { 0, 1 }
  end

  return files
end

-- =================================================
-- Plugin specs
-- =================================================
-- Each plugin is a named local below; the `plugin_specs` list at the end of this
-- section assembles them (plus the optional local theme and machine-local
-- extras) into the table passed to lazy.nvim.

-- Colorscheme fallback. Loaded eagerly with high priority so the UI is themed
-- immediately, but only when the local dark-rock theme isn't present (which is
-- the active colorscheme when it exists). Otherwise it stays lazy and installed
-- purely as a fallback so it isn't sourced at startup for nothing.
local gruvbox_spec = {
  'sainnhe/gruvbox-material',
  lazy = has_dark_rock_theme,
  priority = 1000,
}

-- Snacks: core utility suite. Loaded eagerly (provides terminal, etc).
local snacks_spec = {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    -- Indent guides (replaces indent-blankline). Static guides to match the
    -- previous setup; set animate.enabled = true for the snacks scope animation.
    indent = {
      enabled = true,
      animate = { enabled = false },
    },
    -- Notification UI; also takes over vim.notify (replaces fidget's UI; LSP
    -- progress is fed in via the LspProgress autocmd in the LSP spec).
    notifier = { enabled = true },
    dashboard = {
      enabled = true,
      -- Narrow per-pane width so the two-column layout fits a normal window.
      -- snacks computes how many panes fit and collapses to a single centered
      -- column automatically when the window is too narrow, so this degrades
      -- gracefully in small splits.
      width = 40,
      pane_gap = 6,
      sections = {
        {
          pane = 1,
          icon = ' ',
          title = 'Menu',
          indent = 3,
          dashboard_menu_keys,
        },
        {
          pane = 2,
          icon = ' ',
          title = 'Recent Files',
          indent = 4,
          padding = 2,
          dashboard_recent_files,
        },
        {
          pane = 2,
          icon = ' ',
          title = 'Git Status',
          indent = 3,
          padding = 1,
          enabled = function()
            return Snacks and Snacks.git and Snacks.git.get_root() ~= nil
          end,
          dashboard_git_status,
        },
      },
    },
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
    -- File explorer (replaces nvim-tree). The explorer is a picker source, so
    -- its behavior is configured under `picker.sources.explorer`.
    explorer = {
      enabled = true,
      -- Do not hijack directory buffers. The explorer only opens on demand
      -- (via `<C-e>` or the dashboard menu), never automatically on launch.
      replace_netrw = false,
    },
    picker = {
      -- Directories searched/grepped everywhere are noise; keep them out of
      -- every file/grep source so results stay focused (mirrors the old
      -- Telescope `file_ignore_patterns` / `find_command` excludes).
      sources = {
        explorer = {
          -- Persistent left sidebar. `auto_hide` keeps the search/input bar
          -- tucked away until focused (press `/` to search), leaving a clean
          -- tree by default.
          layout = {
            auto_hide = { 'input' },
            layout = { position = 'left', width = 40, min_width = 40 },
          },
          -- Reveal and follow the focused file (was update_focused_file.enable).
          follow_file = true,
          git_status = true,
          -- Show aggregate git status on collapsed directories.
          git_status_open = true,
          diagnostics = true,
          -- Show dotfiles and gitignored files (nvim-tree filters were false),
          -- but hide the `.git` directory itself (nvim-tree custom filter).
          hidden = true,
          ignored = true,
          exclude = { '.git' },
          -- Keep the sidebar open after opening a file.
          auto_close = false,
          -- `q` closes the explorer. When no real file is on screen (just the
          -- dashboard, or nothing), quit Neovim instead of revealing a stale
          -- hidden buffer.
          win = {
            list = {
              keys = {
                ['q'] = 'explorer_close_or_quit',
              },
            },
          },
          actions = {
            explorer_close_or_quit = function(picker)
              local should_quit = not has_displayed_file_buffer()
              picker:close()
              if should_quit then
                vim.schedule(function()
                  vim.cmd('qa')
                end)
              end
            end,
          },
        },
        -- Show dotfiles and gitignored files (so build output, .env, etc. are
        -- searchable) while still pruning the heavy directories.
        files = {
          hidden = true,
          ignored = true,
          exclude = search_exclude_globs,
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = search_exclude_globs,
        },
        -- `gr` results come from the language server, not a file search, so the
        -- file/grep `exclude` globs don't apply. Drop node_modules/build output
        -- references here instead, leaving only real source. Scoped to
        -- references; lsp_definitions deliberately still jumps into library
        -- `.d.ts` files when that's where a symbol is defined.
        lsp_references = {
          filter = lsp_references_filter,
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
    {
      '<C-e>',
      function()
        -- reveal() opens the explorer (focused) and reveals the current file
        -- when closed, so toggle by closing any open explorer picker first.
        local explorer_pickers = Snacks.picker.get({ source = 'explorer' })
        if #explorer_pickers > 0 then
          explorer_pickers[1]:close()
        elseif has_displayed_file_buffer() then
          Snacks.explorer.reveal()
        else
          -- On the dashboard there's no real file to reveal; reveal() would fall
          -- back to a parent path, so root the explorer at the project cwd.
          Snacks.explorer({ cwd = vim.fn.getcwd() })
        end
      end,
      desc = 'Toggle Explorer',
    },
    {
      '<C-b>',
      function()
        for _, explorer_picker in ipairs(Snacks.picker.get({ source = 'explorer' })) do
          explorer_picker:close()
        end
      end,
      desc = 'Close Explorer',
    },
    -- Fuzzy finding (replaces Telescope). All sources share the snacks UI,
    -- matcher, and theme that the explorer/dashboard already use.
    { '<leader>sf',      function() Snacks.picker.files() end,              desc = '[S]earch [F]iles' },
    { '<leader>sg',      function() Snacks.picker.grep() end,               desc = '[S]earch by [G]rep' },
    { '<leader>sw',      function() Snacks.picker.grep_word() end,          mode = { 'n', 'x' },                          desc = '[S]earch current [W]ord' },
    { '<leader>sh',      function() Snacks.picker.help() end,               desc = '[S]earch [H]elp' },
    { '<leader>sd',      function() Snacks.picker.diagnostics() end,        desc = '[S]earch [D]iagnostics' },
    { '<leader>sD',      function() Snacks.picker.diagnostics_buffer() end, desc = '[S]earch buffer [D]iagnostics' },
    { '<leader>?',       function() Snacks.picker.recent() end,             desc = '[?] Find recently opened files' },
    { '<leader><space>', function() Snacks.picker.buffers() end,            desc = '[ ] Find existing buffers' },
    { '<leader>/',       function() Snacks.picker.lines() end,              desc = '[/] Fuzzily search in current buffer' },
    -- Git (replaces vim-fugitive / vim-rhubarb).
    { '<leader>gg',      function() Snacks.lazygit() end,                   desc = 'Lazygit' },
    { '<leader>gb',      function() Snacks.gitbrowse() end,                 mode = { 'n', 'x' },                          desc = '[G]it [B]rowse' },
    { '<leader>gB',      function() Snacks.git.blame_line() end,            desc = '[G]it [B]lame line' },
  },
}

-- Treesitter: must be available for the initial buffer, so it stays eager.
local treesitter_spec = {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  },
  config = function()
    local treesitter = require('nvim-treesitter')
    treesitter.install(treesitter_parsers)

    -- Register filetypes whose name differs from their parser so those buffers
    -- resolve to the right parser (e.g. typescriptreact -> tsx, jsonc -> json).
    for _, language in ipairs(treesitter_languages) do
      for _, filetype in ipairs(language.filetypes) do
        if filetype ~= language.parser then
          vim.treesitter.language.register(language.parser, filetype)
        end
      end
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = treesitter_filetypes,
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

    -- Select text objects: { lhs, textobject }.
    local treesitter_select = require('nvim-treesitter-textobjects.select')
    local select_mappings = {
      { 'aa', '@parameter.outer' },
      { 'ia', '@parameter.inner' },
      { 'af', '@function.outer' },
      { 'if', '@function.inner' },
      { 'ac', '@class.outer' },
      { 'ic', '@class.inner' },
    }
    for _, mapping in ipairs(select_mappings) do
      local lhs, textobject = mapping[1], mapping[2]
      vim.keymap.set({ 'x', 'o' }, lhs, function()
        treesitter_select.select_textobject(textobject, 'textobjects')
      end)
    end

    -- Move between text objects: { lhs, move_function, textobject }.
    local treesitter_move = require('nvim-treesitter-textobjects.move')
    local move_mappings = {
      { ']m', 'goto_next_start',     '@function.outer' },
      { ']]', 'goto_next_start',     '@class.outer' },
      { ']M', 'goto_next_end',       '@function.outer' },
      { '][', 'goto_next_end',       '@class.outer' },
      { '[m', 'goto_previous_start', '@function.outer' },
      { '[[', 'goto_previous_start', '@class.outer' },
      { '[M', 'goto_previous_end',   '@function.outer' },
      { '[]', 'goto_previous_end',   '@class.outer' },
    }
    for _, mapping in ipairs(move_mappings) do
      local lhs, move_function, textobject = mapping[1], mapping[2], mapping[3]
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
        treesitter_move[move_function](textobject, 'textobjects')
      end)
    end

    local treesitter_swap = require('nvim-treesitter-textobjects.swap')
    vim.keymap.set('n', '<leader>a', function()
      treesitter_swap.swap_next('@parameter.inner')
    end)
    vim.keymap.set('n', '<leader>A', function()
      treesitter_swap.swap_previous('@parameter.inner')
    end)
  end,
}

-- Flash: fast label-based navigation in visible buffers.
local flash_spec = {
  'folke/flash.nvim',
  event = 'VeryLazy',
  ---@type Flash.Config
  opts = {
    search = {
      exclude = {
        'notify',
        'cmp_menu',
        'flash_prompt',
        function(win)
          local bufnr = vim.api.nvim_win_get_buf(win)
          local filetype = vim.bo[bufnr].filetype
          return filetype:find('snacks') == 1 or not vim.api.nvim_win_get_config(win).focusable
        end,
      },
    },
    prompt = {
      prefix = { { 'Flash: ', 'FlashPromptIcon' } },
    },
    modes = {
      -- Keep normal / and ? search unchanged. <C-s> in command-line mode can
      -- toggle Flash search labels on when they are useful.
      search = {
        enabled = false,
      },
      char = {
        enabled = true,
        jump_labels = false,
      },
    },
  },
  keys = {
    { 's',     mode = { 'n', 'x', 'o' }, function() require('flash').jump() end,              desc = 'Flash jump' },
    { 'S',     mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end,        desc = 'Flash Treesitter' },
    { 'r',     mode = 'o',               function() require('flash').remote() end,            desc = 'Remote Flash' },
    { 'R',     mode = { 'o', 'x' },      function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
    { '<C-s>', mode = 'c',               function() require('flash').toggle() end,            desc = 'Toggle Flash search' },
  },
}

-- LSP stack: deferred until a real file buffer is opened.
local lsp_spec = {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  cmd = { 'Mason', 'LspInfo', 'LspStart' },
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
  },
  config = function()
    require('mason').setup()

    local servers = { 'basedpyright', 'ruff', 'tsgo', 'eslint', 'biome', 'lua_ls', 'gopls', 'emmet_ls', 'clangd',
      'rust_analyzer' }

    -- `automatic_enable = true` (the default) enables every installed server
    -- via vim.lsp.enable(), so `ensure_installed` is the single source of truth.
    require('mason-lspconfig').setup {
      ensure_installed = servers,
      automatic_enable = true,
    }

    -- blink.cmp supplies extra completion capabilities.
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- LSP progress (replaces fidget): feed vim.lsp.status() into vim.notify so
    -- the snacks notifier renders a spinner while servers are working.
    vim.api.nvim_create_autocmd('LspProgress', {
      group = vim.api.nvim_create_augroup('UserLspProgress', { clear = true }),
      callback = function(ev)
        local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
        vim.notify(vim.lsp.status(), 'info', {
          id = 'lsp_progress',
          title = 'LSP Progress',
          opts = function(notif)
            notif.icon = ev.data.params.value.kind == 'end' and ' '
                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })

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
    }

    local diagnostic_float_options = vim.tbl_extend('force', {}, lsp_float_options)

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

        -- These all jump directly on a single result and fall back to the
        -- snacks picker when there are several.
        nmap('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
        nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
        nmap('gR', function() Snacks.picker.lsp_references({ filter = lsp_references_show_all }) end,
          '[G]oto [R]eferences (incl. node_modules)')
        nmap('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
        nmap('<leader>D', function() Snacks.picker.lsp_type_definitions() end, 'Type [D]efinition')
        nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')

        -- Override the built-in `K` (default LSP hover on 0.11+) with the
        -- diagnostic-aware variant so the standard key gets the nicer behavior.
        nmap('gh', show_hover_help, 'Hover Help')
        nmap('K', show_hover_help, 'Hover Help')

        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          -- Route through conform so manual formatting picks the same
          -- formatter as save-time formatting (biome/prettier/oxfmt/ruff/...),
          -- falling back to the LSP only when conform has nothing.
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end, { desc = 'Format current buffer with conform' })
      end,
    })

    -- Make runtime files discoverable to the lua language server.
    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, 'lua/?.lua')
    table.insert(runtime_path, 'lua/?/init.lua')

    -- Capabilities apply to every server. Servers without extra settings
    -- (basedpyright, ruff, gopls, tsgo, eslint, biome) need nothing further.
    vim.lsp.config('*', {
      capabilities = capabilities,
    })

    vim.lsp.config('lua_ls', {
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

    vim.lsp.config('emmet_ls', {
      filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
      init_options = {
        html = {
          options = {
            ["bem.enabled"] = true,
          },
        },
      },
    })
  end,
}

-- Autocompletion: blink.cmp (replaces nvim-cmp). Loads on first insert.
local blink_spec = {
  'saghen/blink.cmp',
  version = '1.*', -- pulls the prebuilt Rust fuzzy-matcher binary; no toolchain needed
  event = 'InsertEnter',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'enter', -- <CR> accepts; <C-n>/<C-p> navigate items
      -- Preserve the previous inverted docs-scroll (<C-d> up, <C-f> down):
      ['<C-d>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      -- Manual trigger. <C-Space> is the tmux prefix, so use <C-l>, which is
      -- only mapped to pane-navigation in normal mode and free in insert mode.
      ['<C-l>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-space>'] = {},
      -- Toggle blink's native signature help (insert mode, while typing args).
      -- This is already the default in every preset, but it's spelled out here
      -- because it intentionally replaces the old normal-mode vim.lsp.buf
      -- .signature_help binding in the LSP spec.
      ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      -- Match the previous setup: no auto-popup of documentation.
      documentation = { auto_show = false },
    },
    -- Signature help shown as you type function arguments (replaces the old
    -- LSP <C-k> mapping). Toggled with <C-k> via the keymap above.
    signature = { enabled = true },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lsp = {},
      },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}

-- Git signs in the gutter.
local gitsigns_spec = {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    -- Blame for the current line. The annotation is surfaced in the lualine
    -- statusline (see the blame component in lualine_c) rather than inline, so
    -- the inline virtual text is disabled here. gitsigns still populates the
    -- `b:gitsigns_blame_line` / `b:gitsigns_blame_line_dict` buffer variables
    -- regardless of the virtual text. The short delay keeps the bar responsive;
    -- it must stay below `updatetime` so the CursorHold redraw nudge (in the
    -- autocommands section) fires after the blame resolves.
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = false,
      delay = 100,
    },
    -- Keep the blame terse: date and author only (the statusline has limited
    -- room and `<leader>gB` shows the full blame on demand).
    current_line_blame_formatter = '<author_time:%Y-%m-%d>, <author>',
  },
}

-- Floating cmdline + message routing. Replaces the native bottom row when
-- cmdheight=0; lualine below shows mode, partial commands, and echo text.
local noice_spec = {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim' },
  opts = {
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
    },
    presets = {
      command_palette = true,
    },
    views = {
      cmdline_popup = {
        position = {
          row = -2,
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
        },
      },
    },
    routes = {
      {
        filter = { event = 'msg_show', kind = '', find = 'written' },
        opts = { skip = true },
      },
      {
        filter = { event = 'msg_show', kind = 'search_count' },
        opts = { skip = true },
      },
    },
  },
}

-- Statusline.
local lualine_spec = {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'folke/noice.nvim' },
  opts = {
    options = {
      icons_enabled = false,
      -- Derive the statusline palette from the active colorscheme so it stays
      -- in sync whether gruvbox-material or a dark-rock variant is loaded.
      theme = 'auto',
      component_separators = '',
      section_separators = '',
      disabled_filetypes = {
        statusline = {
          'snacks_terminal',
          'snacks_picker_list',
          'snacks_picker_input',
          'snacks_picker_preview',
          'snacks_dashboard',
        },
      },
    },
    sections = {
      -- lualine_b owns branch / diff / diagnostics. Both diff and diagnostics
      -- need explicit configuration so they pull from in-process data rather
      -- than spawning shell processes and so their symbols stay in sync with
      -- the rest of the editor.
      lualine_b = {
        'branch',
        {
          -- Source the diff counts from gitsigns instead of letting lualine
          -- shell out to `git diff` on every redraw. gitsigns already has the
          -- numbers on `b:gitsigns_status_dict`, so this is a pure variable
          -- read with no I/O. Returning nil when the dict is missing lets
          -- lualine fall back to its own resolver (e.g. on the very first
          -- redraw before gitsigns attaches).
          'diff',
          source = function()
            local status = vim.b.gitsigns_status_dict
            if not status then
              return nil
            end
            return {
              added = status.added,
              modified = status.changed,
              removed = status.removed,
            }
          end,
        },
        {
          -- Match the diagnostic sign text configured in vim.diagnostic.config
          -- above (E/W/I/H) so the statusline counts read identically to the
          -- gutter signs.
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
        },
      },
      -- Filename on the far left of lualine_c so the active buffer is always
      -- visible. lualine's default `filename` component was lost when this
      -- section was overridden to host the noice indicators, so re-add it here.
      -- path = 1 shows the path relative to cwd; tweak to 0 for filename-only.
      -- Symbols are spelled out explicitly because icons_enabled is false and
      -- the defaults rely on nerd-font glyphs.
      lualine_c = {
        {
          'filename',
          path = 1,
          file_status = true,
          newfile_status = true,
          symbols = {
            modified = '[+]',
            readonly = '[ro]',
            unnamed = '[no name]',
            newfile = '[new]',
          },
        },
        {
          function()
            return require('noice').api.status.message.get_hl()
          end,
          cond = function()
            return require('noice').api.status.message.has()
          end,
        },
        {
          function()
            return require('noice').api.status.command.get()
          end,
          cond = function()
            return require('noice').api.status.command.has()
          end,
        },
        {
          function()
            return require('noice').api.status.mode.get()
          end,
          cond = function()
            return require('noice').api.status.mode.has()
          end,
        },
        {
          function()
            return require('noice').api.status.search.get()
          end,
          cond = function()
            return require('noice').api.status.search.has()
          end,
        },
      },
      -- Right side. Keep the lualine defaults (encoding/filetype) and prepend
      -- the current-line git blame so it sits on the right of the bar.
      lualine_x = {
        {
          -- Current-line git blame: date and author only. Fed by gitsigns'
          -- current_line_blame; its inline virtual text is disabled in the
          -- gitsigns spec, so this is the only place the annotation appears.
          -- gitsigns clears the dict on cursor move and repopulates it once the
          -- debounced blame resolves, so gating on the dict hides the blame while
          -- scrolling and shows it once the cursor settles.
          function()
            return vim.trim(vim.b.gitsigns_blame_line or '')
          end,
          cond = function()
            return vim.b.gitsigns_blame_line_dict ~= nil
          end,
          -- Override only the foreground so the component keeps the section's
          -- background. A string color group (e.g. 'Comment') would also pull in
          -- its background, which is transparent under this theme and makes the
          -- blame look detached from the footer. Resolved via a function so it
          -- re-evaluates on colorscheme changes. nvim_get_hl returns fg as a
          -- 24-bit integer; lualine expects a '#rrggbb' string (a bare number is
          -- read as a cterm color and rejected above 255).
          color = function()
            local comment_hl = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })
            if not comment_hl.fg then
              return nil
            end
            return { fg = string.format('#%06x', comment_hl.fg) }
          end,
        },
        'encoding',
        -- `fileformat` (unix/dos/mac) is dropped: on a macOS-only setup it's
        -- effectively always `unix` and just consumes space on the bar.
        'filetype',
      },
      -- Replace the default `progress` component (which shows Top/Bot/All) with a
      -- plain percentage through the file. lualine_z keeps the default `location`
      -- component (line:column) to its right. The `%%%%` collapses to a literal
      -- `%` once string.format and the statusline renderer have each consumed a
      -- level of escaping.
      lualine_y = {
        {
          function()
            local current_line = vim.fn.line('.')
            local total_lines = vim.fn.line('$')
            return string.format('%d%%%%', math.floor(current_line / total_lines * 100))
          end,
        },
      },
    },
  },
}

-- Detect tabstop / shiftwidth automatically.
local sleuth_spec = {
  'tpope/vim-sleuth',
  event = { 'BufReadPre', 'BufNewFile' },
}

-- Surround text objects.
local surround_spec = {
  'kylechui/nvim-surround',
  version = '*',
  event = 'VeryLazy',
  opts = {},
}

-- Seamless navigation between tmux panes and vim splits.
local tmux_navigator_spec = {
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
  },
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<cr>' },
    { '<C-j>', '<cmd>TmuxNavigateDown<cr>' },
    { '<C-k>', '<cmd>TmuxNavigateUp<cr>' },
    { '<C-l>', '<cmd>TmuxNavigateRight<cr>' },
  },
}

-- Formatter: load just before the first write (and on :ConformInfo).
local conform_spec = {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end,
      mode = { 'n', 'v' },
      desc = '[F]ormat buffer',
    },
  },
  config = function()
    local biome_config_files = { 'biome.json', 'biome.jsonc', '.biome.json', '.biome.jsonc' }
    local prettier_config_files = {
      '.prettierrc',
      '.prettierrc.json',
      '.prettierrc.yml',
      '.prettierrc.yaml',
      '.prettierrc.json5',
      '.prettierrc.js',
      '.prettierrc.cjs',
      '.prettierrc.mjs',
      '.prettierrc.ts',
      '.prettierrc.cts',
      '.prettierrc.mts',
      '.prettierrc.toml',
      'prettier.config.js',
      'prettier.config.cjs',
      'prettier.config.mjs',
      'prettier.config.ts',
      'prettier.config.cts',
      'prettier.config.mts',
    }

    local function get_buffer_directory(bufnr)
      local buffer_name = vim.api.nvim_buf_get_name(bufnr)
      if buffer_name == '' then
        return vim.uv.cwd()
      end

      return vim.fs.dirname(buffer_name)
    end

    local function has_root_file(bufnr, file_names)
      return vim.fs.root(get_buffer_directory(bufnr), file_names) ~= nil
    end

    local function has_package_json_prettier_config(bufnr)
      local package_json = vim.fs.find('package.json', {
        path = get_buffer_directory(bufnr),
        upward = true,
      })[1]
      if not package_json then
        return false
      end

      local ok, package_data = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), '\n'))
      return ok and package_data.prettier ~= nil
    end

    local function web_formatters(bufnr)
      if has_root_file(bufnr, biome_config_files) then
        return { 'biome', lsp_format = 'never' }
      end

      if has_root_file(bufnr, prettier_config_files) or has_package_json_prettier_config(bufnr) then
        return { 'prettier', lsp_format = 'never' }
      end

      return { 'oxfmt', lsp_format = 'never' }
    end

    require('conform').setup({
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
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        go = { lsp_format = 'prefer' },
        lua = { lsp_format = 'prefer' },
      },
      default_format_opts = {
        lsp_format = 'fallback',
      },
      format_after_save = {
        lsp_format = 'fallback',
      },
      notify_on_error = true,
    })
  end,
}

local plugin_specs = {
  gruvbox_spec,
  snacks_spec,
  treesitter_spec,
  flash_spec,
  lsp_spec,
  blink_spec,
  gitsigns_spec,
  noice_spec,
  lualine_spec,
  sleuth_spec,
  surround_spec,
  tmux_navigator_spec,
  conform_spec,
}

if has_dark_rock_theme then
  table.insert(plugin_specs, {
    dir = dark_rock_theme_path,
    name = 'dark-rock-theme',
    lazy = false,
    priority = 1000,
  })
end

-- Optional machine-local extension point: drop a `lua/custom/plugins.lua` that
-- returns a list of lazy.nvim plugin specs and they get appended here. Absent on
-- most machines, so the require is wrapped in pcall.
local has_custom_plugins, custom_plugins = pcall(require, 'custom.plugins')
if has_custom_plugins and type(custom_plugins) == 'table' then
  vim.list_extend(plugin_specs, custom_plugins)
end

-- =================================================
-- Plugin manager setup
-- =================================================

require('lazy').setup({
  spec = plugin_specs,
  defaults = { lazy = true },
  install = { colorscheme = { 'gruvbox-material' } },
  checker = { enabled = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      -- Disable built-in runtime plugins we never use to trim startup. netrw is
      -- already disabled earlier via vim.g.loaded_netrw{,Plugin}, which fires
      -- before lazy runs, so it's intentionally not repeated here.
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})

-- =================================================
-- Colorscheme and highlights
-- =================================================
-- Runs after lazy.setup so the colorscheme plugin is on the runtimepath.

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
local float_highlight_group = vim.api.nvim_create_augroup('UserFloatHighlights', { clear = true })
set_dark_rock_float_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = float_highlight_group,
  pattern = { 'dark-rock', 'night-rock', 'light-rock' },
  callback = set_dark_rock_float_highlights,
})

-- =================================================
-- Dashboard
-- =================================================
-- The snacks dashboard (configured in its plugin spec) opens automatically for
-- a bare `nvim`. Snacks handles `nvim <dir>` natively: with the explorer enabled
-- and `replace_netrw`, the dashboard is kept and the explorer is opened for the
-- directory. The BufDelete autocmd below brings the dashboard back whenever the
-- last real file buffer closes. It lives after lazy.setup because it depends on
-- both the snacks plugin and the window helpers above.
local dashboard_group = vim.api.nvim_create_augroup('UserDashboard', { clear = true })

-- Bring the dashboard back into the main window once no file buffer remains.
vim.api.nvim_create_autocmd('BufDelete', {
  group = dashboard_group,
  callback = function(event)
    if vim.v.vim_did_enter == 0 then
      return
    end
    if vim.bo[event.buf].buftype ~= '' or vim.api.nvim_buf_get_name(event.buf) == '' then
      return
    end

    vim.schedule(function()
      if has_open_file_buffer() then
        return
      end
      local main_window = find_main_window()
      if not main_window then
        return
      end
      local current_buffer = vim.api.nvim_win_get_buf(main_window)
      -- Already showing a snacks window (e.g. the dashboard); nothing to do.
      if vim.bo[current_buffer].filetype:find('snacks') ~= nil then
        return
      end
      open_dashboard_in_window(main_window)
    end)
  end,
})
