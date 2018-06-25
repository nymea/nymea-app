import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    ListView {
        anchors { fill: parent }
        spacing: app.margins
        model: ListModel {
            Component.onCompleted: {
                var supportedInterfaces = ["temperaturesensor", "humiditysensor"]
                for (var i = 0; i < supportedInterfaces.length; i++) {
                    if (root.deviceClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
                        append({name: supportedInterfaces[i]});
                    }
                }
            }
        }
        delegate: SensorView {
            width: parent.width
            interfaceName: modelData
            device: root.device
            deviceClass: root.deviceClass
        }
    }
}
