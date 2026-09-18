//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Window

import "widgets"

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

    Item {
        anchors {
            fill: parent
            margins: 5
        }

        Workspaces {
            anchors {
                right: clock.left
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
        }

        Pill {
            id: clock

            anchors.centerIn: parent

            Text {
                font: Theme.font
                text: Datetime.time
                color: Theme.blue
            }
        }

        Pill {
            id: status

            anchors {
                left: clock.right
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }

            Row {
                spacing: 16

                Text {
                    readonly property string off: "󰖪"
                    readonly property string wired: "󰛳"
                    readonly property string wiredVpn: "󰒄"
                    readonly property string wifi: "󰖩"
                    readonly property string wifiVpn: "󱚿"

                    font: Theme.font
                    text: {
                        if (Networking.wiredConnected && Networking.vpnConnected)
                            return wiredVpn;
                        if (Networking.wiredConnected)
                            return wired;
                        if (Networking.wifiConnected && Networking.vpnConnected)
                            return wifiVpn;
                        if (Networking.wifiConnected)
                            return wifi;
                        return off;
                    }
                    color: Theme.mauve
                }

                Text {
                    readonly property bool adapterEnabled: Bluetooth.defaultAdapter.enabled
                    readonly property bool adapterConnected: Bluetooth.defaultAdapter.devices.values.some(device => device.connected)

                    readonly property string iconOff: "󰂲"
                    readonly property string iconOn: "󰂯"
                    readonly property string iconConnected: "󰂱"

                    font: Theme.font
                    text: {
                        if (adapterEnabled && adapterConnected)
                            return iconConnected;
                        else if (adapterEnabled)
                            return iconOn;
                        return iconOff;
                    }
                    color: Theme.blue
                }

                Text {
                    readonly property string muted: "󰸈"
                    readonly property var icons: ["󰕿", "󰖀", ""]

                    function icon(percentage) {
                        const index = Math.floor(percentage / 100 * icons.length);
                        return icons[index];
                    }

                    font: Theme.font
                    text: {
                        if (Audio.muted)
                            return muted;
                        return icon(Audio.percentage);
                    }
                    color: Theme.rosewater
                }

                Text {
                    readonly property var icons: ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]

                    function icon(percentage) {
                        const index = Math.floor(percentage / 100 * icons.length);
                        return icons[index];
                    }

                    font: Theme.font
                    text: icon(Backlight.percentage)
                    color: Theme.yellow
                }

                Text {
                    readonly property var chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
                    readonly property var dischargingIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
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
                        if (Battery.full)
                            return Theme.blue;
                        if (Battery.charging)
                            return Theme.green;
                        if (Battery.critical)
                            return Theme.red;
                        return Theme.blue;
                    }
                }

                Text {
                    font: Theme.font
                    color: Theme.teal
                    text: HyprlandLayout.short
                }
            }
        }

        Pill {
            id: tray

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

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
    }
}
