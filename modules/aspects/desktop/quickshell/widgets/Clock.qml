import QtQuick

import "../services"

Pill {
    anchors.fill: parent

    Text {
        font: Theme.font
        text: Datetime.time
        color: Theme.blue
    }
}
