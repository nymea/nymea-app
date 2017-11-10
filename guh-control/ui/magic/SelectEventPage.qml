import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root
    property alias text: header.text
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

    header: GuhHeader {
        id: header
        onBackPressed: pageStack.pop()
    }

    ListModel {
        id: eventModel
        ListElement { interfaceName: "temperaturesensor"; text: "When it's freezing..."; event: "freeze"}
        ListElement { interfaceName: "battery"; text: "When the device runs out of battery..."; event: "lowBattery"}
        ListElement { interfaceName: "weather"; text: "When it starts raining..."; event: "rain" }
    }

    onDeviceClassChanged: {
        actualModel.clear()
        print("device supports interfaces", deviceClass.interfaces)
        for (var i = 0; i < eventModel.count; i++) {
            print("event is for interface", eventModel.get(i).interfaceName)
            if (deviceClass.interfaces.indexOf(eventModel.get(i).interfaceName) >= 0) {
                actualModel.append(eventModel.get(i))
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: ListModel {
            id: actualModel
        }

        delegate: ItemDelegate {
            text: model.text
        }

    }
}
