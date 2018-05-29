import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "components"
import "delegates"
import Mea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Configure Things")
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: Engine.deviceManager.devices
        delegate: ThingDelegate {
            interfaces:model.interfaces
            name: model.name
            onClicked: {
                pageStack.push(Qt.resolvedUrl("devicepages/ConfigureThingPage.qml"), {device: Engine.deviceManager.devices.get(index)})
            }
        }
    }
}
