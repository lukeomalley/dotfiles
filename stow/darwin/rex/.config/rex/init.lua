-- Rex keybindings, mirroring tmux (prefix ctrl+space) and its defaults.
-- Cmd+digits and cmd+` belong to AeroSpace, so tabs are switched with the
-- prefix, as in tmux, or with alt and no prefix.

local prefix = "ctrl+space>"

-- Pressing the prefix twice sends ctrl+space through to the program.
rex.bind(prefix .. "ctrl+space", "pane.send_key", { key = "ctrl+space" })

-- Tabs (tmux windows)
rex.bind(prefix .. "c", "client.tab.new")
rex.bind(prefix .. "shift+7", "client.tab.close") -- &
rex.bind(prefix .. "n", "client.tab.next")
rex.bind(prefix .. "p", "client.tab.previous")
rex.bind(prefix .. "ctrl+n", "client.tab.next") -- tmux-sensible
rex.bind(prefix .. "ctrl+p", "client.tab.previous") -- tmux-sensible
rex.bind(prefix .. "l", "client.tab.recent.in_session") -- last-window
rex.bind(prefix .. ",", "client.tab.rename")
rex.bind(prefix .. "shift+1", "pane.move_to_new_tab") -- ! break-pane

-- tmux numbers windows from 0 and Rex numbers tabs from 1, so prefix 0 (and
-- prefix `) is the first tab, as in tmux. Alt does the same without the
-- prefix, like AeroSpace's cmd+` and cmd+N. Physical key names keep Option
-- from turning the key into a special character first.
rex.bind(prefix .. "`", "client.tab.goto", { index = 1 })
rex.bind("alt+[Backquote]", "client.tab.goto", { index = 1 })
for i = 0, 9 do
  rex.bind(prefix .. tostring(i), "client.tab.goto", { index = i + 1 })
  rex.bind("alt+[Digit" .. i .. "]", "client.tab.goto", { index = i + 1 })
end
rex.bind("alt+[BracketLeft]", "client.tab.previous")
rex.bind("alt+[BracketRight]", "client.tab.next")

-- Sessions
rex.bind(prefix .. "s", "session.switch")
rex.bind(prefix .. "w", "pane.go_to") -- choose-tree: every session, tab and pane
rex.bind(prefix .. "f", "pane.go_to") -- find-window
rex.bind(prefix .. "shift+4", "session.rename") -- $
rex.bind(prefix .. "shift+9", "session.previous") -- (
rex.bind(prefix .. "shift+0", "session.next") -- )
rex.bind(prefix .. "shift+l", "session.recent") -- L, last session

-- Panes
rex.bind(prefix .. "shift+5", "pane.split", { direction = "right" }) -- %
rex.bind(prefix .. "shift+'", "pane.split", { direction = "down" }) -- "
rex.bind(prefix .. "v", "pane.split", { direction = "right" }) -- like :vsplit
rex.bind(prefix .. "h", "pane.split", { direction = "down" }) -- like :split
-- Like kill-pane: closes the pane, or the tab when it is the last pane.
rex.bind(prefix .. "x", "client.close")
rex.bind(prefix .. "ctrl+x", "client.close") -- ctrl still held after the prefix
rex.bind(prefix .. "z", "pane.zoom")
rex.bind(prefix .. "o", "pane.focus_next")
rex.bind(prefix .. ";", "pane.focus_recent.in_tab") -- last-pane
for _, direction in ipairs({ "left", "right", "up", "down" }) do
  rex.bind(prefix .. direction, "pane.focus", { direction = direction })
  rex.bind(prefix .. "ctrl+" .. direction, "pane.resize", { direction = direction, amount = 2 })
  rex.bind(prefix .. "alt+" .. direction, "pane.resize", { direction = direction, amount = 10 })
end

-- prefix r enters resize mode: h/j/k/l (or arrows) resize until escape, and
-- shift resizes in bigger steps.
rex.bind(prefix .. "r", "client.mode.enter", { name = "resize" })
for vim_key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  for _, key in ipairs({ vim_key, direction }) do
    rex.bind("resize/" .. key, "pane.resize", { direction = direction, amount = 2 })
    rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction, amount = 10 })
  end
end

-- Copy mode uses vi keys (v, ctrl+v, y) by default, like mode-keys vi.
rex.bind(prefix .. "[", "pane.copy_mode.enter")
rex.bind(prefix .. "]", "pane.paste")

-- Misc
rex.bind(prefix .. "shift+;", "client.palette.toggle") -- :
rex.bind(prefix .. "shift+/", "client.palette.toggle") -- ? list-keys
rex.bind(prefix .. "shift+r", "client.config.reload") -- R, tmux-sensible
rex.bind("cmd+p", "pane.go_to") -- the app's default, made explicit

-- vim-tmux-navigator: ctrl+h/j/k/l move between panes, but go to the program
-- when it is vim or fzf so it can move between its own splits.
local passthrough = { vim = true, nvim = true, view = true, vimdiff = true, fzf = true }

rex.action({
  name = "navigate",
  title = "Navigate Pane or Vim Split",
  category = "Pane",
  args = { direction = "string", key = "string" },
  run = function(ctx, args)
    local ok, process = pcall(rex.block.call, "com.superlogical.terminal", "process", {
      block_id = ctx.block_id,
    })
    local foreground = ok and process and process.foreground
    if foreground and passthrough[foreground.name] then
      rex.client.queue("pane.send_key", { key = args.key })
    else
      rex.client.queue("pane.focus", { direction = args.direction })
    end
  end,
})

rex.bind("ctrl+h", "navigate", { direction = "left", key = "ctrl+h" })
rex.bind("ctrl+j", "navigate", { direction = "down", key = "ctrl+j" })
rex.bind("ctrl+k", "navigate", { direction = "up", key = "ctrl+k" })
rex.bind("ctrl+l", "navigate", { direction = "right", key = "ctrl+l" })
