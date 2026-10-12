import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

import "../services"

Pill {
    id: root

    readonly property var panelWindow: QsWindow.window

    signal menuOpened
    signal menuClosed

    anchors.fill: parent

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

                QsMenuAnchor {
                    id: menuAnchor

                    menu: modelData.menu
                    anchor.window: root.panelWindow
                    onOpened: root.menuOpened()
                    onClosed: root.menuClosed()
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    onClicked: event => {
                        if (event.button === Qt.RightButton && modelData.hasMenu) {
                            const p = mapToItem(root.panelWindow.contentItem, event.x, event.y);
                            menuAnchor.anchor.rect.x = p.x;
                            menuAnchor.anchor.rect.y = p.y;
                            menuAnchor.open();
                        } else {
                            modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
