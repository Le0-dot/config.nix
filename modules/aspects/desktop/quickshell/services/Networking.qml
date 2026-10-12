pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Io

Singleton {
    id: root

    property bool vpnConnected: false
    readonly property bool wiredConnected: Networking.devices.values.some(device => device.connected && device.type === DeviceType.Wired)
    readonly property bool wifiConnected: Networking.devices.values.some(device => device.connected && device.type === DeviceType.Wifi)

    Process {
        id: activeConnections
        command: ["nmcli", "--get-value", "TYPE", "connection", "show", "--active"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.vpnConnected = text.split("\n").some(line => line.trim() === "vpn");
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: activeConnections.running = true
    }
}
