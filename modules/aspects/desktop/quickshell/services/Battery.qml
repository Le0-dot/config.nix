pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    property int percentage: parseInt(capacityFile.text())
    property bool online: onlineFile.text().trim() === "1"
    property bool charging: online && percentage < 100
    property bool full: online && percentage == 100
    property bool critical: !online && percentage <= 20

    // sysfs doesn't emit inotify events, so watchChanges never fires; poll instead.
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload();
            onlineFile.reload();
        }
    }

    FileView {
        id: capacityFile
        path: "/sys/class/power_supply/BAT0/capacity"
    }

    FileView {
        id: onlineFile
        path: "/sys/class/power_supply/AC/online"
    }
}
