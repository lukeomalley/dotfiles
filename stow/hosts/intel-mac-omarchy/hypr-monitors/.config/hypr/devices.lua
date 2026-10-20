-- Preserve the Apple trackpad's current pointer sensitivity.
hl.device({
  name = "apple-inc.-apple-internal-keyboard-/-trackpad-1",
  sensitivity = 0,
})

-- Command is already in the right place on this Mac: keep it as Super.
hl.config({ input = { kb_options = "shift:both_capslock_cancel" } })

