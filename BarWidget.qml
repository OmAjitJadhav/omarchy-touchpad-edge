import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Status bar widget for Touchpad Edge Controls.
// Displays an interactive touchpad icon (󰍽) with quick-toggle and settings panel.
BarWidget {
    id: root
    moduleName: "omajitjadhav.touchpad-edge"

    property var config: Model.defaultConfig()

    function scriptPath() {
        return Qt.resolvedUrl("bin/touchpad-edge-daemon").toString().replace(/^file:\/\//, "")
    }

    function fetchStatus() {
        if (!statusProc.running) statusProc.running = true
    }

    function toggleMaster() {
        toggleProc.command = ["/usr/bin/python3", root.scriptPath(), "toggle"]
        toggleProc.running = true
    }

    Timer {
        interval: 3000
        running: true
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
        id: toggleProc
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

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() {
        if (panelLoader.item) panelLoader.item.open()
    }

    function close() {
        if (panelLoader.item) panelLoader.item.close()
    }

    function togglePanel() {
        if (panelLoader.item) panelLoader.item.toggle()
    }

    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

    function closeForPopoutSwitch() {
        if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
    }

    function injectPanel() {
        var target = panelLoader.item
        if (!target) return
        if ("bar" in target) target.bar = root.bar
        if ("settings" in target) target.settings = root.settings
        if ("anchorItem" in target) target.anchorItem = button
        if ("hostWidget" in target) target.hostWidget = root
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }

    IpcHandler {
        target: "omajitjadhav.touchpad-edge"

        function open(): void { root.open() }
        function close(): void { root.close() }
        function show(): void { root.open() }
        function hide(): void { root.close() }
        function toggle(): void { root.togglePanel() }
        function toggleMaster(): void { root.toggleMaster() }
    }

    BarIconButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: "󰍽"
        active: root.config.enabled === true
        tooltipText: Model.getTooltipText(root.config)
        onPressed: function(buttonCode) {
            if (buttonCode === Qt.RightButton) {
                root.toggleMaster()
            } else {
                root.togglePanel()
            }
        }
    }
}
