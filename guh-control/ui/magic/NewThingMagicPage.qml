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
        ListElement { interfaceName: "temperaturesensor"; text: "When it's freezing..."; identifier: "freeze"}
        ListElement { interfaceName: "battery"; text: "When the device runs out of battery..."; identifier: "lowBattery"}
        ListElement { interfaceName: "weather"; text: "When it starts raining..."; identifier: "rain" }
    }

    ListModel {
        id: actionModel
        ListElement { interfaceName: "light"; text: "Switch light when..."; identifier: "switchLight"}
        ListElement { interfaceName: "dimmablelight"; text: "Dim light when..."; identifier: "dimLight"}
        ListElement { interfaceName: "colorlight"; text: "Set light color when..."; identifier: "colorLight" }
        ListElement { interfaceName: "mediacontroller"; text: "Pause playback when..."; identifier: "pausePlayback" }
        ListElement { interfaceName: "mediacontroller"; text: "Resume playback when..."; identifier: "resumePlayback" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: "Set volume..."; identifier: "setVolume" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: "Mute when..."; identifier: "mute" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: "Unmute when..."; identifier: "unmute" }
        ListElement { interfaceName: "notifications"; text: "Notify me when..."; identifier: "notify" }
    }

    function entrySelected(identifier) {
        switch (identifier) {
        case "freeze":
            pageStack.push(Qt.resolvedUrl("SelectActionPage.qml"), {device: root.device })
        }
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
        print("huh")
        for (var i = 0; i < actionModel.count; i++) {
            print("action is for interface", actionModel.get(i).interfaceName)
            if (deviceClass.interfaces.indexOf(actionModel.get(i).interfaceName) >= 0) {
                actualModel.append(actionModel.get(i))
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: ListModel {
            id: actualModel
        }

        delegate: ItemDelegate {
            width: parent.width
            text: model.text

            onClicked: root.entrySelected(model.identifier)
        }
    }
}
