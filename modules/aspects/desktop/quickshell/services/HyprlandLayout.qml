pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    property string name: "English"
    property string short: name.slice(0, 2).toUpperCase()

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout")
                name = event.parse(2)[1];
        }
    }
}
