-- Preserve the built-in Apple display's current resolution and scale.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "3072x1920@60", position = "0x0", scale = 1 })
