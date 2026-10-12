pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property int current: 0
    property int max: 1
    readonly property int percentage: Math.round(current / max * 100)

    property var currentProc: Process {
        command: ["brightnessctl", "get", "--class=backlight"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: current = parseInt(text)
        }
    }

    property var maxProc: Process {
        command: ["brightnessctl", "max", "--class=backlight"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: max = parseInt(text)
        }
    }

    property var timer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentProc.running = true
    }
}
