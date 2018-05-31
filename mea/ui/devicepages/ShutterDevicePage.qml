import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root


    ShutterControls {
        anchors {
            top: parent.top
            topMargin: app.iconSize
            horizontalCenter: parent.horizontalCenter
        }
        device: root.device
    }
}
