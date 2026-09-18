import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import ".."

Rectangle {
    implicitWidth: layout.implicitWidth + Theme.font.pixelSize / 2
    implicitHeight: layout.height
    radius: height / 2
    color: Theme.surface0
    clip: true

    Row {
        id: layout
        anchors.centerIn: parent

        Repeater {
            model: [1, 2, 3, 4, 5]

            Rectangle {
                implicitWidth: workspace.width + Theme.font.pixelSize * 1.5
                implicitHeight: Theme.font.pixelSize * 2
                radius: height / 2
                color: hoverArea.containsMouse ? Qt.rgba(0, 0, 0, 0.2) : "transparent"

                Rectangle {
                    id: workspace

                    readonly property bool focused: modelData === Hyprland.focusedMonitor.activeWorkspace.id
                    readonly property bool exists: Hyprland.workspaces.values.some(w => w.id === modelData)

                    anchors.centerIn: parent
                    implicitHeight: Theme.font.pixelSize / 2
                    implicitWidth: focused ? height * 4 : height
                    radius: height / 2
                    color: focused ? Theme.mauve : (exists ? Theme.blue : Theme.subtext1)

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData + " })")
                }
            }
        }
    }
}
