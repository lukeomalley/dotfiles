-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Omarchy normally uses Caps Lock as Compose. This machine delegates Caps Lock
-- to keyd instead (Escape when tapped, Control when held).
hl.config({
  input = {
    kb_options = "shift:both_capslock_cancel",
    repeat_rate = 50,
    repeat_delay = 200,
  },
})

-- Additional examples from Omarchy's input template:
-- hl.config({
--   input = {
--     kb_layout = "us,dk,eu",
--     kb_variant = "intl",
--     repeat_rate = 40,
--     repeat_delay = 250,
--     numlock_by_default = true,
--     sensitivity = 0.35,
--     accel_profile = "flat",
--     touchpad = {
--       natural_scroll = true,
--       clickfinger_behavior = true,
--       scroll_factor = 0.4,
--       disable_while_typing = false,
--       drag_3fg = 1,
--     },
--   },
-- })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
