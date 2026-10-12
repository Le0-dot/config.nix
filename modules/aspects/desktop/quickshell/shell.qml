//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Controls
import QtQuick.Window

import "services"
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

    Item {
        anchors {
            fill: parent
            margins: 5
        }

        Workspaces {
            anchors {
                right: center.left
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
        }

        Item {
            id: center

            property bool pinned: false
            readonly property bool showTray: hover.hovered || pinned

            anchors.centerIn: parent
            height: parent.height
            width: showTray ? tray.implicitWidth : clock.implicitWidth

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            HoverHandler {
                id: hover
            }

            Clock {
                id: clock

                visible: !center.showTray
            }

            Tray {
                id: tray

                visible: center.showTray
                onMenuOpened: center.pinned = true
                onMenuClosed: center.pinned = false
            }
        }

        Pill {
            id: status

            anchors {
                left: center.right
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
    }
}
