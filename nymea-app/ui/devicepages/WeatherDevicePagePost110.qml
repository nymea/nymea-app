import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Flickable {
    anchors.fill: parent
    clip: true
    contentHeight: content.implicitHeight

    property var device
    property var deviceClass

    ColumnLayout {
        id: content
        width: parent.width
        WeatherView {
            Layout.fillWidth: true
            device: root.device
            deviceClass: root.deviceClass
        }
        GenericTypeGraph {
            Layout.fillWidth: true
            device: root.device
            stateType: root.deviceClass.stateTypes.findByName("temperature")
            iconSource: app.interfaceToIcon("temperaturesensor")
            color: app.interfaceToColor("temperaturesensor")
        }
        GenericTypeGraph {
            Layout.fillWidth: true
            device: root.device
            stateType: root.deviceClass.stateTypes.findByName("humidity")
            iconSource: app.interfaceToIcon("humiditysensor")
            color: app.interfaceToColor("humiditysensor")
        }
        GenericTypeGraph {
            Layout.fillWidth: true
            device: root.device
            stateType: root.deviceClass.stateTypes.findByName("pressure")
            iconSource: app.interfaceToIcon("pressuresensor")
            color: app.interfaceToColor("pressuresensor")
        }
    }
}
