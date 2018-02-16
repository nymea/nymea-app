import QtQuick 2.7
import QtQuick.Controls 2.2
import "../components"
import QtQuick.Layouts 1.2
import Guh 1.0

Page {
    property var rule: null

    header: GuhHeader {
        text: "Add some magic"
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        Label {
            text: "When"
        }

        Repeater {
            model: rule.eventDescriptors
            ItemDelegate {
                property var device: Engine.deviceManager.devices.getDevice(model.deviceId)
                property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
                property var eventType: deviceClass ? deviceClass.eventTypes.getEventType(model.eventTypeId) : null
                contentItem: ColumnLayout {
                    Label {
                        text: device ? device.name : "Unknown device"
                        Layout.fillWidth: true
                    }
                    Label {
                        text: eventType ? eventType.name : "Unknown event"
                    }
                }
            }
        }
    }
}
