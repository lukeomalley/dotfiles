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

-- Send a single shortcut to the focused surface while Super remains held.
-- Splitting key-down and key-up avoids synthetic keys becoming stuck or
-- repeating, matching Omarchy's universal clipboard shortcut behavior.
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

-- Mac-style Command shortcuts using the keyboard's Super/Command key.
o.bind("SUPER + A", "Universal select all", send_shortcut_once("CTRL", "A"))
o.bind("SUPER + Z", "Universal undo", send_shortcut_once("CTRL", "Z"))
o.bind("SUPER + SHIFT + Z", "Universal redo", send_shortcut_once("CTRL + SHIFT", "Z"))
hl.unbind("SUPER + T")
o.bind("SUPER + T", "Universal new tab", send_shortcut_once("CTRL", "T"))

-- Use Command-style window/tab shortcuts: SUPER+W is handled by the focused
-- application, while SUPER+Q retains Omarchy's compositor-level close action.
hl.unbind("SUPER + W")
o.bind("SUPER + W", "Universal close tab", send_shortcut_once("CTRL", "W"))
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Fast local dictation with the Parakeet model. Hyprland owns the shortcut;
-- Voxtype's built-in evdev hotkey is disabled in its managed config.
o.bind("INSERT", "Start dictation (push-to-talk)", "voxtype record start")
o.bind("INSERT", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true })

-- Put Omarchy's workspace 10 (displayed as "0" in the bar) on the physical
-- grave/backtick key as well as its default SUPER+0 binding.
-- Using the keycode keeps the same physical key when Shift produces a tilde.
o.bind("SUPER + code:49", "Switch to workspace 0", hl.dsp.focus({ workspace = "10" }))
o.bind("SUPER + SHIFT + code:49", "Move window to workspace 0", hl.dsp.window.move({ workspace = "10" }))
o.bind(
  "SUPER + SHIFT + ALT + code:49",
  "Move window silently to workspace 0",
  hl.dsp.window.move({ workspace = "10", follow = false })
)

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
