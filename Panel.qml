import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Settings panel for Touchpad Edge Controls.
Panel {
    id: root
    moduleName: "omshankara.touchpad-edge"
    ipcTarget: "omshankara.touchpad-edge"
    manageIpc: false

    property var anchorItem: null
    property var hostWidget: null
    readonly property var barIdentity: hostWidget || root

    readonly property color contentForeground: bar ? bar.foreground : Color.foreground
    readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

    readonly property string configPath: Quickshell.env("HOME") + "/.config/omarchy/touchpad-edge.json"

    property bool edgeEnabled: true
    property bool volEnabled: true
    property bool briEnabled: true
    property bool invertDir: false
    property int volStep: 2
    property int briStep: 2
    property real edgePercent: 0.10

    function loadConfig() {
        readConfigProc.running = true
    }

    function saveConfig() {
        var payload = {
            "enabled": root.edgeEnabled,
            "volume_enabled": root.volEnabled,
            "brightness_enabled": root.briEnabled,
            "invert_direction": root.invertDir,
            "volume_step": root.volStep,
            "brightness_step": root.briStep,
            "edge_start_percent": root.edgePercent,
            "edge_cancel_percent": root.edgePercent + 0.06,
            "step_travel_px": 45,
            "min_interval_sec": 0.03
        }
        writeConfigProc.command = [
            "python3", "-c",
            "import os, json, sys; p=os.path.expanduser('~/.config/omarchy/touchpad-edge.json'); os.makedirs(os.path.dirname(p), exist_ok=True); f=open(p, 'w'); f.write(sys.argv[1]); f.close()",
            JSON.stringify(payload, null, 2)
        ]
        writeConfigProc.running = true
    }

    Process {
        id: readConfigProc
        command: [
            "python3", "-c",
            "import os, json; p=os.path.expanduser('~/.config/omarchy/touchpad-edge.json'); print(open(p).read() if os.path.isfile(p) else '{}')"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data.enabled !== undefined) root.edgeEnabled = data.enabled
                    if (data.volume_enabled !== undefined) root.volEnabled = data.volume_enabled
                    if (data.brightness_enabled !== undefined) root.briEnabled = data.brightness_enabled
                    if (data.invert_direction !== undefined) root.invertDir = data.invert_direction
                    if (data.volume_step !== undefined) root.volStep = data.volume_step
                    if (data.brightness_step !== undefined) root.briStep = data.brightness_step
                    if (data.edge_start_percent !== undefined) root.edgePercent = data.edge_start_percent
                } catch(e) {}
            }
        }
    }

    Process {
        id: writeConfigProc
    }

    Component.onCompleted: {
        root.loadConfig()
    }

    ColumnLayout {
        spacing: Style.space(12)
        width: Math.min(Screen.width - Style.space(32), Style.space(320))

        Text {
            text: "Touchpad Edge Controls"
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.heading
            font.bold: true
            Layout.fillWidth: true
        }

        Text {
            text: "Swipe along the edges of your touchpad:"
            color: Color.subtleText
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
            Layout.fillWidth: true
        }

        Rectangle {
            height: 1
            color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.12)
            Layout.fillWidth: true
        }

        // Master toggle
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Enable Gestures"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
                Layout.fillWidth: true
            }
            Button {
                text: root.edgeEnabled ? "ON" : "OFF"
                onClicked: {
                    root.edgeEnabled = !root.edgeEnabled
                    root.saveConfig()
                }
            }
        }

        // Right Edge Volume
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Right Edge (Volume 🔊)"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
                Layout.fillWidth: true
            }
            Button {
                text: root.volEnabled ? "ON" : "OFF"
                onClicked: {
                    root.volEnabled = !root.volEnabled
                    root.saveConfig()
                }
            }
        }

        // Left Edge Brightness
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Left Edge (Brightness ☀️)"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
                Layout.fillWidth: true
            }
            Button {
                text: root.briEnabled ? "ON" : "OFF"
                onClicked: {
                    root.briEnabled = !root.briEnabled
                    root.saveConfig()
                }
            }
        }

        // Invert Direction
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Invert Direction"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
                Layout.fillWidth: true
            }
            Button {
                text: root.invertDir ? "YES" : "NO"
                onClicked: {
                    root.invertDir = !root.invertDir
                    root.saveConfig()
                }
            }
        }

        Rectangle {
            height: 1
            color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.12)
            Layout.fillWidth: true
        }

        // Edge Width
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Edge Width: " + Math.round(root.edgePercent * 100) + "%"
                color: Color.subtleText
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.caption
                Layout.fillWidth: true
            }
            Button {
                text: "Cycle"
                onClicked: {
                    if (root.edgePercent <= 0.08) root.edgePercent = 0.10
                    else if (root.edgePercent <= 0.10) root.edgePercent = 0.14
                    else root.edgePercent = 0.08
                    root.saveConfig()
                }
            }
        }
    }
}
