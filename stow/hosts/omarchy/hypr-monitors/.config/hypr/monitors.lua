-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Acer XV272U above the laptop. Match the display rather than the HDMI port.
-- This connection advertises 1440p at 59.95 Hz; its preferred 4K mode is only 30 Hz.
local external = "desc:Acer Technologies XV272U 0x1082B6E7"
hl.monitor({ output = external, mode = "2560x1440@59.95", position = "0x0", scale = 1 })

-- Equal logical widths center the laptop directly below the external display.
-- The absolute position remains valid when the laptop is the only output.
hl.monitor({ output = "eDP-1", mode = "2560x1440@60.01", position = "0x1440", scale = 1 })

-- Prefer the Acer for the normal numbered workspaces (0 selects workspace 10).
-- Hyprland falls back to the remaining output when the Acer is disconnected.
for workspace = 1, 10 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = external, default = workspace == 1 })
end

-- Give the laptop its own workspace while docked, without taking one of 1-10.
hl.workspace_rule({ workspace = "11", monitor = "eDP-1", default = true })
