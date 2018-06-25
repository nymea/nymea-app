import QtQuick 2.0

Item {
    property ListModel eventTemplateModel: ListModel {
        ListElement { interfaceName: "battery"; stateName: "batteryLevel"; stateDisplayName: qsTr("Battery level"); eventDisplayName: qsTr("Battery level changed") }
        ListElement { interfaceName: "battery"; stateName: "batteryCritical"; stateDisplayName: qsTr("Battery critical"); eventDisplayName: qsTr("Battery critical changed") }
    }
}
