//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
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

    implicitHeight: 44

    component Pill: Rectangle {
        default required property Item content

        implicitHeight: parent.height
        implicitWidth: content.implicitWidth + Theme.font.pixelSize * 2
        radius: Theme.font.pixelSize * 2
        color: Theme.surface0
        clip: true
        onContentChanged: {
            content.parent = this;
            content.anchors.centerIn = this;
            content.visible = true;
        }
    }

    component HoverPill: Rectangle {
        required property Item primary
        required property Item secondary

        implicitHeight: parent.height
        implicitWidth: (primary.visible ? primary.implicitWidth : secondary.implicitWidth) + Theme.font.pixelSize * 2
        radius: Theme.font.pixelSize * 2
        color: Theme.surface0
        clip: true
        onPrimaryChanged: {
            primary.parent = this;
            primary.anchors.centerIn = this;
            primary.visible = true;
        }
        onSecondaryChanged: {
            secondary.parent = this;
            secondary.anchors.centerIn = this;
            secondary.visible = false;
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: [parent.primary.visible, parent.secondary.visible] = [false, true]
            onExited: [parent.primary.visible, parent.secondary.visible] = [true, false]
        }
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 5
        }

        Pill {
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
                        color: hoverArea.containsMouse ? Qt.rgba(0, 0, 0, 0.12) : "transparent"

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                        }

                        Text {
                            font: Theme.font
                            anchors.centerIn: parent
                            text: modelData.icon
                            color: {
                                if (modelData.id === Hyprland.focusedMonitor.activeWorkspace.id)
                                    return Theme.mauve;
                                const exists = Hyprland.workspaces.values.some(w => w.id === modelData.id);
                                return exists ? Theme.blue : Theme.subtext1;
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Pill {
            Row {
                spacing: 16 / 2

                Repeater {
                    model: SystemTray.items

                    Item {
                        id: trayItem
                        implicitHeight: Theme.font.pixelSize
                        implicitWidth: implicitHeight

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

        HoverPill {
            primary: Text {
                readonly property var icons: ["", "", ""]

                function icon(percentage) {
                    const index = Math.floor(percentage / 100 * icons.length);
                    return icons[index];
                }

                font: Theme.font
                text: icon(Audio.percentage)
                color: Theme.rosewater
            }
            secondary: Text {
                font: Theme.font
                text: Audio.percentage + "%"
                color: Theme.rosewater
            }
        }

        HoverPill {

            primary: Text {
                readonly property var icons: ["", "", "", "", "", "", "", "", "", "", ""]

                function icon(percentage) {
                    const index = Math.floor(percentage / 100 * icons.length);
                    return icons[index];
                }

                font: Theme.font
                text: icon(Backlight.percentage)
                color: Theme.yellow
            }
            secondary: Text {
                font: Theme.font
                text: Backlight.percentage + "%"
                color: Theme.yellow
            }
        }

        HoverPill {
            primary: Text {
                readonly property var chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
                readonly property var dischargingIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
                readonly property string fullIcon: "󰂅"

                function chargingIcon(percentage) {
                    const index = Math.floor(percentage / 100 * chargingIcons.length);
                    return chargingIcons[index];
                }

                function dischargingIcon(percentage) {
                    const index = Math.floor(percentage / 100 * dischargingIcons.length);
                    return dischargingIcons[index];
                }

                font: Theme.font
                text: {
                    if (Battery.full)
                        return fullIcon;
                    if (Battery.charging)
                        return chargingIcon(Battery.percentage);
                    return dischargingIcon(Battery.percentage);
                }
                color: {
                    if (Battery.charging)
                        return Theme.green;
                    if (Battery.critical)
                        return Theme.red;
                    return Theme.blue;
                }
            }
            secondary: Text {
                font: Theme.font
                text: Battery.percentage + "%"
                color: {
                    if (Battery.charging)
                        return Theme.green;
                    if (Battery.critical)
                        return Theme.red;
                    return Theme.blue;
                }
            }
        }

        Pill {
            Text {
                font: Theme.font
                color: Theme.teal
                text: HyprlandLayout.short
            }
        }

        HoverPill {
            primary: Text {
                font: Theme.font
                text: Datetime.time
                color: Theme.blue
            }
            secondary: Text {
                font: Theme.font
                text: Datetime.date
                color: Theme.blue
            }
        }
    }
}
