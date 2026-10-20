-- Change the default Omarchy look'n'feel.

-- Roughly three times faster than Omarchy's defaults. Despite its name,
-- "speed" is a duration in tenths of a second: smaller values finish sooner.
hl.animation({ leaf = "global", enabled = true, speed = 3.3, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 1.8, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 1.25, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.35, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.5, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 0.6, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.5, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.25, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.3, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.6, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.45, bezier = "almostLinear" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1, bezier = "easeOutQuint", style = "slidevert" })

-- Compact spacing and borderless windows.
hl.config({
  general = {
    border_size = 0,
    gaps_in = 2,
    gaps_out = 5,
  },
  -- Omarchy shell panels, menus, and notifications share this corner radius.
  decoration = {
    rounding = 10,
    shadow = {
      enabled = true,
      range = 18,
      render_power = 3,
      color = "rgba(00000033)",
    },
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
    },
  },
})

-- Frost shell surfaces while excluding transparent margins and dim scrims.
hl.layer_rule({
  match = { namespace = "^(omarchy-notifications|omarchy-bar|omarchy-menu|omarchy-clipboard|omarchy-keyboard-panel|omarchy-emojis)$" },
  blur = true,
  ignore_alpha = 0.6,
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
