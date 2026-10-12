import QtQuick

import "../services"

Rectangle {
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
