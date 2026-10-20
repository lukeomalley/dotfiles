import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Omarchy 4.0.5 equivalent of the newer OverlayWindow used by oma-cast.
PanelWindow {
  id: window
  property bool shown: false

  function focusedScreen() {
    var monitor = Hyprland.focusedMonitor
    for (var i = 0; i < Quickshell.screens.length; i++) {
      if (monitor && Quickshell.screens[i].name === monitor.name)
        return Quickshell.screens[i]
    }
    return Quickshell.screens.length ? Quickshell.screens[0] : null
  }

  onShownChanged: if (shown) screen = focusedScreen()
  visible: shown
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
}
