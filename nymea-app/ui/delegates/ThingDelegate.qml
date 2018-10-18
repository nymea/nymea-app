import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

MeaListItemDelegate {
    id: root
    width: parent.width
    iconName: deviceClass ? app.interfacesToIcon(deviceClass.interfaces) : ""
    text: device ? device.name : ""
    progressive: true
    secondaryIconName: batteryCritical ? "../images/battery/battery-010.svg" : ""
    tertiaryIconName: disconnected ? "../images/dialog-warning-symbolic.svg" : ""
    tertiaryIconColor: "red"

    property var device: null

    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property bool batteryCritical: deviceClass && deviceClass.interfaces.indexOf("battery") >= 0 ? device.stateValue(deviceClass.stateTypes.findByName("batteryCritical").id) === true : false
    readonly property bool disconnected: deviceClass && deviceClass.interfaces.indexOf("connectable") >= 0 ? device.stateValue(deviceClass.stateTypes.findByName("connected").id) === false : false

}
