-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Put workspace 1 on the physical grave/backtick key instead of 1.
-- Using the keycode keeps the same physical key when Shift produces a tilde.
hl.unbind("SUPER + code:10")
hl.unbind("SUPER + SHIFT + code:10")
hl.unbind("SUPER + SHIFT + ALT + code:10")
o.bind("SUPER + code:49", "Switch to workspace 1", hl.dsp.focus({ workspace = "1" }))
o.bind("SUPER + SHIFT + code:49", "Move window to workspace 1", hl.dsp.window.move({ workspace = "1" }))
o.bind(
  "SUPER + SHIFT + ALT + code:49",
  "Move window silently to workspace 1",
  hl.dsp.window.move({ workspace = "1", follow = false })
)

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
