//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

PanelWindow {
    id: panel
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Qt.application.font.pixelSize * 4

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    QtObject {
        id: clock

        property string value: ""

        property var proc: Process {
            command: ["date", "+%H:%M"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: clock.value = this.text.trim()
            }
        }

        property var timer: Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.proc.running = true
        }
    }

    QtObject {
        id: brightness

        property int current: 0
        property int max: 1
        property int value: max > 0 ? Math.round(current / max * 100) : 0

        property var currentProc: Process {
            command: ["brightnessctl", "get"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: brightness.current = parseInt(this.text)
            }
        }

        property var maxProc: Process {
            command: ["brightnessctl", "max"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: brightness.max = parseInt(this.text)
            }
        }

        property var timer: Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: brightness.currentProc.running = true
        }
    }

    QtObject {
        id: battery

        property int capacity: 0
        property bool isOnline: false
        property bool isCharging: isOnline && capacity < 100
        property bool isFull: isOnline && capacity == 100
        property bool isCritical: !isOnline && capacity <= 20

        property var capacityProc: Process {
            command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: battery.capacity = parseInt(this.text)
            }
        }

        property var onlineProc: Process {
            command: ["cat", "/sys/class/power_supply/AC/online"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: battery.isOnline = this.text.trim() === "1"
            }
        }

        property var timer: Timer {
            interval: 5000
            running: true
            repeat: true
            onTriggered: {
                battery.capacityProc.running = true;
                battery.onlineProc.running = true;
            }
        }
    }

    component PillWidget: Rectangle {
        id: pill

        default required property Item defaultContent
        property Item expandedContent: null

        readonly property bool interactive: expandedContent !== null
        readonly property bool expanded: interactive && expandedContent.visible
        property bool pinned: false

        signal clicked(var event)
        signal entered
        signal exited

        function pin() {
            pinned = true;
        }

        function unpin() {
            pinned = false;
        }

        function expand() {
            if (interactive && !pinned) {
                defaultContent.visible = false;
                expandedContent.visible = true;
            }
        }

        function collapse() {
            if (interactive && !pinned) {
                defaultContent.visible = true;
                expandedContent.visible = false;
            }
        }

        onDefaultContentChanged: {
            defaultContent.parent = pill;
            defaultContent.anchors.centerIn = pill;
            defaultContent.visible = true;
        }

        onExpandedContentChanged: {
            expandedContent.parent = pill;
            expandedContent.anchors.centerIn = pill;
            expandedContent.visible = false;
        }

        implicitHeight: parent.height
        implicitWidth: (expanded ? expandedContent.implicitWidth : defaultContent.implicitWidth) + Qt.application.font.pixelSize * 2
        radius: Qt.application.font.pixelSize * 2
        color: "white"
        clip: true

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            z: 1
            anchors.fill: parent
            enabled: interactive
            hoverEnabled: interactive && !pinned
            onEntered: {
                expand();
                pill.entered();
            }
            onExited: {
                collapse();
                pill.exited();
            }
            acceptedButtons: Qt.AllButtons
            onClicked: event => pill.clicked(event)
        }
    }

    RowLayout {
        anchors {
            fill: parent
            margins: Qt.application.font.pixelSize / 2
        }

        PillWidget {
            id: workspaces

            Row {
                Repeater {
                    model: [
                        {
                            id: 1,
                            icon: ""
                        },
                        {
                            id: 2,
                            icon: ""
                        },
                        {
                            id: 3,
                            icon: ""
                        },
                        {
                            id: 4,
                            icon: ""
                        },
                        {
                            id: 5,
                            icon: ""
                        }
                    ]

                    Rectangle {
                        implicitWidth: height
                        implicitHeight: workspaces.height
                        radius: width / 2
                        color: hoverArea.containsMouse ? "#20000000" : "transparent"

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            color: modelData.id === Hyprland.focusedMonitor.activeWorkspace.id ? "black" : "#aaaaaa"
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        PillWidget {
            Row {
                spacing: Qt.application.font.pixelSize / 2

                Repeater {
                    model: SystemTray.items

                    Item {
                        id: trayItem
                        implicitWidth: Qt.application.font.pixelSize * 1.5
                        implicitHeight: Qt.application.font.pixelSize * 1.5

                        Image {
                            anchors.centerIn: parent
                            source: modelData.icon
                            width: parent.width
                            height: width
                            smooth: true
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: true
                            onClicked: event => {
                                if (event.button === Qt.RightButton && modelData.hasMenu) {
                                    const p = mapToItem(panel.contentItem, event.x, event.y);
                                    modelData.display(panel, p.x, p.y);
                                } else {
                                    modelData.activate();
                                }
                            }
                        }
                    }
                }
            }
        }

        PillWidget {
            readonly property var activeDevice: Networking.devices.values.filter(d => d.connected).sort((a, b) => b.type - a.type)[0] ?? null
            onClicked: if (pinned)
                unpin()
            else
                pin()

            Text {
                text: Networking.devices.values.filter(d => d.connected).sort((a, b) => b.type - a.type)[0].name
                color: "black"
            }

            expandedContent: Text {
                text: "expanded"
                color: "black"
            }
        }

        PillWidget {
            Row {
                spacing: Qt.application.font.pixelSize / 2

                Text {
                    text: Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%"
                    color: "black"
                }
                Text {
                    text: brightness.value + "%"
                    color: "black"
                }
                Text {
                    text: {
                        if (battery.isFull)
                            return "Full";
                        if (battery.isCharging)
                            return battery.capacity + "% Charging";
                        if (battery.isCritical)
                            return battery.capacity + "% Critical";
                        return battery.capacity + "%";
                    }
                    color: "black"
                }
            }
        }

        PillWidget {
            Row {
                spacing: Qt.application.font.pixelSize / 2

                Text {
                    id: layout
                    text: "EN"
                    color: "black"

                    Connections {
                        target: Hyprland
                        function onRawEvent(event) {
                            if (event.name === "activelayout")
                                layout.text = event.parse(2)[1].slice(0, 2).toUpperCase();
                        }
                    }
                }

                Text {
                    text: clock.value
                    color: "black"
                }
            }
        }
    }
}
