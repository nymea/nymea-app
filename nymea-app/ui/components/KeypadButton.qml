import QtQuick 2.5
import Nymea 1.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Item {
    id: root

    property alias imageSource: icon.name

    property color activeColor: app.accentColor

    function activate() {
        t.start();
    }

    ColorIcon {
        id: icon
        anchors.fill: parent
        color: active ? root.activeColor : keyColor
        Behavior on color { ColorAnimation { duration: 200 } }

        property bool active: t.running

        Timer {
            id: t;
            interval: 200
        }
    }
}

