-- Physical Alt keys become Super; physical Super keys become Alt.
-- Caps Lock is intentionally omitted: keyd owns its tap/hold behavior.
hl.config({
  input = {
    kb_options = "shift:both_capslock_cancel,altwin:swap_alt_win",
  },
})
