import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: content.implicitHeight
        ColumnLayout {
            id: content
            width: parent.width
            WeatherView {
                Layout.fillWidth: true
                device: root.device
                deviceClass: root.deviceClass
            }
            SensorView {
                Layout.fillWidth: true
                device: root.device
                deviceClass: root.deviceClass
                interfaceName: "temperaturesensor"
            }
            SensorView {
                Layout.fillWidth: true
                device: root.device
                deviceClass: root.deviceClass
                interfaceName: "humiditysensor"
            }
        }
    }
}
