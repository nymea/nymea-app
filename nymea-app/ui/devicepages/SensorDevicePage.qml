import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    Loader {
        anchors.fill: parent
        Component.onCompleted: {
            var src
            if (engine.jsonRpcClient.ensureServerVersion("1.10")) {
                src = "SensorDevicePagePost110.qml"
            } else {
                src = "SensorDevicePagePre110.qml"
            }
            setSource(Qt.resolvedUrl(src), {device: root.device, deviceClass: root.deviceClass})
        }
    }
}
