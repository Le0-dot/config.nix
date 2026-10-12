pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    property int percentage: parseInt(capacityFile.text())
    property bool online: onlineFile.text().trim() === "1"
    property bool charging: online && percentage < 100
    property bool full: online && percentage == 100
    property bool critical: !online && percentage <= 20

    FileView {
        id: capacityFile
        path: "/sys/class/power_supply/BAT0/capacity"
        watchChanges: true
    }

    FileView {
        id: onlineFile
        path: "/sys/class/power_supply/AC/online"
        watchChanges: true
    }
}
