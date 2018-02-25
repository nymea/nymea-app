import QtQuick 2.0

Item {
    property ListModel eventTemplateModel: ListModel {
        ListElement { interfaceName: "battery"; stateName: "batteryLevel"; stateDisplayName: "Battery level"; eventDisplayName: "Battery level changed" }
        ListElement { interfaceName: "battery"; stateName: "batteryCritical"; stateDisplayName: "Battery critical"; eventDisplayName: "Battery critical changed" }
    }
}
