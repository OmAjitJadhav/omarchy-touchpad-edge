import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Settings popup panel for Touchpad Edge Controls.
// Allows configuring master state, individual sliders, step sizes, and edge width.
Panel {
    id: root
    moduleName: "omshankara.touchpad-edge"
    ipcTarget: "omshankara.touchpad-edge"
    manageIpc: false

    property var anchorItem: null
    property var hostWidget: null
    readonly property var barIdentity: hostWidget || root

    readonly property color foreground: bar ? bar.foreground : Color.foreground
    readonly property color dim: Qt.darker(foreground, 1.55)
    readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
    readonly property color accent: Color.accent

    property var config: Model.defaultConfig()

    function scriptPath() {
        return Qt.resolvedUrl("bin/touchpad-edge-daemon").toString().replace(/^file:\/\//, "")
    }

    function fetchStatus() {
        if (!statusProc.running) statusProc.running = true
    }

    function applySetting(patch) {
        var updated = {}
        for (var k in root.config) updated[k] = root.config[k]
        for (var p in patch) updated[p] = patch[p]
        root.config = updated

        applyProc.command = [
            "/usr/bin/python3",
            root.scriptPath(),
            "apply",
            "--json-data",
            JSON.stringify(patch)
        ]
        applyProc.running = true
    }

    Timer {
        interval: 2000
        running: root.opened
        repeat: true
        onTriggered: root.fetchStatus()
    }

    Process {
        id: statusProc
        command: ["/usr/bin/python3", root.scriptPath(), "status"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data && typeof data === "object") {
                        root.config = data
                    }
                } catch(e) {}
            }
        }
    }

    Process {
        id: applyProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    if (data && typeof data === "object") {
                        root.config = data
                    }
                } catch(e) {}
            }
        }
    }

    Component.onCompleted: {
        root.fetchStatus()
    }

    // Settings Card Popup
    PopupCard {
        id: popup
        anchorItem: root.anchorItem
        bar: root.bar
        owner: root
        open: root.opened
        contentWidth: Style.space(380)
        contentHeight: Style.space(670)

        ColumnLayout {
            anchors.fill: parent
            spacing: Style.space(10)

            // ── Header Row ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.space(12)

                Text {
                    text: "󰍽"
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.space(32)
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Style.space(1)

                    Text {
                        text: "Touchpad Edge Controls"
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.title
                        font.bold: true
                    }

                    Text {
                        text: Model.formatDeviceName(root.config.device_name)
                        color: root.dim
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                    }
                }

                // Active Badge
                BorderSurface {
                    implicitWidth: Style.space(64)
                    implicitHeight: Style.space(26)
                    radius: Style.cornerRadius
                    color: root.config.enabled ? Style.selectedFillFor(root.foreground, root.accent) : Style.normalFillFor(root.foreground, root.accent)
                    borderSpec: Border.controlSpec(root.config.enabled ? "selected" : "normal", root.foreground, root.accent)
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: root.config.enabled ? "Active" : "Disabled"
                        color: root.config.enabled ? root.foreground : root.dim
                        font.family: root.fontFamily
                        font.pixelSize: Style.space(10)
                        font.bold: true
                    }
                }
            }

            // ── Master Switch ──────────────────────────────────────────────────
            Toggle {
                Layout.fillWidth: true
                label: "Master Edge Controls"
                description: "Turn all touchpad edge sliders on or off"
                checked: root.config.enabled === true
                onClicked: {
                    root.applySetting({ "enabled": !root.config.enabled })
                }
            }

            PanelSeparator { Layout.fillWidth: true }

            // ── Section 1: Sliders & Direction ─────────────────────────────────
            PanelSectionHeader {
                text: "EDGE GESTURE FEATURES"
                foreground: root.foreground
            }

            Toggle {
                Layout.fillWidth: true
                label: "Right Edge — Volume 🔊"
                description: "Swipe vertically along right edge for audio"
                checked: root.config.volume_enabled === true
                opacity: root.config.enabled ? 1.0 : 0.5
                onClicked: {
                    if (root.config.enabled) {
                        root.applySetting({ "volume_enabled": !root.config.volume_enabled })
                    }
                }
            }

            Toggle {
                Layout.fillWidth: true
                label: "Left Edge — Brightness ☀️"
                description: "Swipe vertically along left edge for display brightness"
                checked: root.config.brightness_enabled === true
                opacity: root.config.enabled ? 1.0 : 0.5
                onClicked: {
                    if (root.config.enabled) {
                        root.applySetting({ "brightness_enabled": !root.config.brightness_enabled })
                    }
                }
            }

            Toggle {
                Layout.fillWidth: true
                label: "Invert Swipe Direction ⇅"
                description: "Swipe down to increase, up to decrease"
                checked: root.config.invert_direction === true
                opacity: root.config.enabled ? 1.0 : 0.5
                onClicked: {
                    if (root.config.enabled) {
                        root.applySetting({ "invert_direction": !root.config.invert_direction })
                    }
                }
            }

            PanelSeparator { Layout.fillWidth: true }

            // ── Section 2: Volume Step Size ────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.space(4)

                RowLayout {
                    Layout.fillWidth: true
                    PanelSectionHeader {
                        text: "VOLUME STEP PER SWIPE"
                        foreground: root.foreground
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "±" + (root.config.volume_step || 2) + "%"
                        color: root.accent
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }
                }

                // Preset Pills
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(6)

                    Repeater {
                        model: [1, 2, 3, 5, 10]
                        delegate: BorderSurface {
                            required property int modelData
                            Layout.fillWidth: true
                            implicitHeight: Style.space(24)
                            radius: Style.cornerRadius
                            readonly property bool isSelected: (root.config.volume_step || 2) === modelData
                            color: isSelected ? Style.selectedFillFor(root.foreground, root.accent) : Style.normalFillFor(root.foreground, root.accent)
                            borderSpec: Border.controlSpec(isSelected ? "selected" : "normal", root.foreground, root.accent)

                            Text {
                                anchors.centerIn: parent
                                text: modelData + "%"
                                color: parent.isSelected ? root.foreground : root.dim
                                font.family: root.fontFamily
                                font.pixelSize: Style.space(11)
                                font.bold: parent.isSelected
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applySetting({ "volume_step": parent.modelData })
                            }
                        }
                    }
                }

                PanelSlider {
                    Layout.fillWidth: true
                    bar: root.bar
                    minimum: 1
                    maximum: 10
                    step: 1
                    integer: true
                    value: root.config.volume_step || 2
                    onReleased: function(v) {
                        root.applySetting({ "volume_step": Math.round(v) })
                    }
                }
            }

            PanelSeparator { Layout.fillWidth: true }

            // ── Section 3: Brightness Step Size ────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.space(4)

                RowLayout {
                    Layout.fillWidth: true
                    PanelSectionHeader {
                        text: "BRIGHTNESS STEP PER SWIPE"
                        foreground: root.foreground
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "±" + (root.config.brightness_step || 2) + "%"
                        color: root.accent
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }
                }

                // Preset Pills
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(6)

                    Repeater {
                        model: [1, 2, 3, 5, 10]
                        delegate: BorderSurface {
                            required property int modelData
                            Layout.fillWidth: true
                            implicitHeight: Style.space(24)
                            radius: Style.cornerRadius
                            readonly property bool isSelected: (root.config.brightness_step || 2) === modelData
                            color: isSelected ? Style.selectedFillFor(root.foreground, root.accent) : Style.normalFillFor(root.foreground, root.accent)
                            borderSpec: Border.controlSpec(isSelected ? "selected" : "normal", root.foreground, root.accent)

                            Text {
                                anchors.centerIn: parent
                                text: modelData + "%"
                                color: parent.isSelected ? root.foreground : root.dim
                                font.family: root.fontFamily
                                font.pixelSize: Style.space(11)
                                font.bold: parent.isSelected
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applySetting({ "brightness_step": parent.modelData })
                            }
                        }
                    }
                }

                PanelSlider {
                    Layout.fillWidth: true
                    bar: root.bar
                    minimum: 1
                    maximum: 10
                    step: 1
                    integer: true
                    value: root.config.brightness_step || 2
                    onReleased: function(v) {
                        root.applySetting({ "brightness_step": Math.round(v) })
                    }
                }
            }

            PanelSeparator { Layout.fillWidth: true }

            // ── Section 4: Edge Width Strip ────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.space(4)

                RowLayout {
                    Layout.fillWidth: true
                    PanelSectionHeader {
                        text: "EDGE DETECTION STRIP WIDTH"
                        foreground: root.foreground
                        Layout.fillWidth: true
                    }
                    Text {
                        text: Math.round((root.config.edge_start_percent || 0.10) * 100) + "%"
                        color: root.accent
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }
                }

                // Width Preset Pills
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(6)

                    Repeater {
                        model: [
                            { label: "Slim 8%", val: 0.08 },
                            { label: "Default 10%", val: 0.10 },
                            { label: "Wide 14%", val: 0.14 }
                        ]
                        delegate: BorderSurface {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: Style.space(24)
                            radius: Style.cornerRadius
                            readonly property bool isSelected: Math.abs((root.config.edge_start_percent || 0.10) - modelData.val) < 0.01
                            color: isSelected ? Style.selectedFillFor(root.foreground, root.accent) : Style.normalFillFor(root.foreground, root.accent)
                            borderSpec: Border.controlSpec(isSelected ? "selected" : "normal", root.foreground, root.accent)

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: parent.isSelected ? root.foreground : root.dim
                                font.family: root.fontFamily
                                font.pixelSize: Style.space(10)
                                font.bold: parent.isSelected
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applySetting({ "edge_start_percent": parent.modelData.val, "edge_cancel_percent": parent.modelData.val + 0.06 })
                            }
                        }
                    }
                }

                PanelSlider {
                    Layout.fillWidth: true
                    bar: root.bar
                    minimum: 6
                    maximum: 16
                    step: 1
                    integer: true
                    value: Math.round((root.config.edge_start_percent || 0.10) * 100)
                    onReleased: function(v) {
                        var frac = Math.round(v) / 100.0
                        root.applySetting({ "edge_start_percent": frac, "edge_cancel_percent": frac + 0.06 })
                    }
                }
            }
        }
    }
}
