pragma Singleton
import Quickshell
import QtQuick

Singleton {
    property string date: Qt.formatDate(new Date(), "dd-MM-yyyy")
    property string time: Qt.formatTime(new Date(), "HH:mm")

    property var timer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            parent.date = Qt.formatDate(new Date(), "dd-MM-yyyy");
            parent.time = Qt.formatTime(new Date(), "HH:mm");
        }
    }
}
