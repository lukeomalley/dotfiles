-- Register Ghostty's global quick-terminal shortcut before the first terminal
-- launch. The desktop app ID is required by the Wayland global-shortcuts portal;
-- launching through xdg-terminal-exec alone gives it that helper's app ID.
o.exec_on_start("uwsm app -a com.mitchellh.ghostty -- ghostty --initial-window=false")
