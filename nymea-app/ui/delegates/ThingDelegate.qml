import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

MeaListItemDelegate {
    id: root
    width: parent.width
    iconName: deviceClass ? app.interfacesToIcon(deviceClass.interfaces) : ""
    text: device.name
    progressive: true
    batteryCritical: deviceClass && deviceClass.interfaces.indexOf("battery") >= 0 ? device.stateValue(deviceClass.stateTypes.findByName("batteryCritical").id) === true : false
    disconnected: deviceClass && deviceClass.interfaces.indexOf("connectable") >= 0 ? device.stateValue(deviceClass.stateTypes.findByName("connected").id) === false : false

    property var device: null

    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

}
