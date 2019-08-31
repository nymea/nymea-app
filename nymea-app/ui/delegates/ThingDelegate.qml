import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

NymeaListItemDelegate {
    id: root
    width: parent.width
    iconName: device.deviceClass ? app.interfacesToIcon(device.deviceClass.interfaces) : ""
    text: device ? device.name : ""
    progressive: true
    secondaryIconName: batteryCritical ? "../images/battery/battery-010.svg" : ""
    tertiaryIconName: disconnected ? "../images/dialog-warning-symbolic.svg" : ""
    tertiaryIconColor: "red"

    property Device device: null

    readonly property bool hasBatteryInterface: device && device.deviceClass.interfaces.indexOf("battery") > 0
    readonly property StateType batteryCriticalStateType: hasBatteryInterface ? device.deviceClass.stateTypes.findByName("batteryCritical") : null
    readonly property State batteryCriticalState: batteryCriticalStateType ? device.states.getState(batteryCriticalStateType.id) : null
    readonly property bool batteryCritical: batteryCriticalState && batteryCriticalState.value === true

    readonly property bool hasConnectableInterface: device && device.deviceClass.interfaces.indexOf("connectable") > 0
    readonly property StateType connectedStateType: hasConnectableInterface ? device.deviceClass.stateTypes.findByName("connected") : null
    readonly property State connectedState: connectedStateType ? device.states.getState(connectedStateType.id) : null
    readonly property bool disconnected: connectedState && connectedState.value === false ? true : false
}
