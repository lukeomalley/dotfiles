-- Host-specific pointer sensitivity. Device names come from `hyprctl devices`.
hl.device({
  name = "elan-touchpad",
  sensitivity = 0.25,
})

hl.device({
  name = "elan-trackpoint",
  sensitivity = -0.35,
  accel_profile = "flat",
})

hl.device({
  name = "logitech-m720-triathlon-multi-device-mouse-1",
  sensitivity = -0.30,
  accel_profile = "flat",
})

-- keyd may re-emit pointer input through this virtual device.
hl.device({
  name = "keyd-virtual-pointer",
  sensitivity = -0.30,
  accel_profile = "flat",
})
