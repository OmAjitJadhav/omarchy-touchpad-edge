import QtQuick
import Quickshell
import Quickshell.Io

// Omarchy shell service entry point for Touchpad Edge Controls.
// Keeps the background event listener running smoothly inside the user session.
Item {
  id: root

  property bool active: true
  readonly property string daemonPath: String(Qt.resolvedUrl("bin/touchpad-edge-daemon")).replace(/^file:\/\//, "")
  readonly property string pythonBin: "/usr/bin/python3"

  Process {
    id: daemonProc
    command: [root.pythonBin, root.daemonPath]
    running: root.active

    onExited: function(code) {
      if (root.active) {
        restartTimer.start()
      }
    }
  }

  Timer {
    id: restartTimer
    interval: 2500
    repeat: false
    onTriggered: {
      if (root.active && !daemonProc.running) {
        daemonProc.running = true
      }
    }
  }

  Component.onDestruction: {
    root.active = false
    daemonProc.running = false
  }
}
