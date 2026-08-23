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

-- Add workspace 0 on the physical grave/backtick key. Hyprland reserves the
-- numeric workspace ID 0, so use a named workspace that is displayed as "0".
-- Using the keycode keeps the same physical key when Shift produces a tilde.
o.bind("SUPER + code:49", "Switch to workspace 0", hl.dsp.focus({ workspace = "name:0" }))
o.bind("SUPER + SHIFT + code:49", "Move window to workspace 0", hl.dsp.window.move({ workspace = "name:0" }))
o.bind(
  "SUPER + SHIFT + ALT + code:49",
  "Move window silently to workspace 0",
  hl.dsp.window.move({ workspace = "name:0", follow = false })
)

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
