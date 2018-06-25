import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

    default property alias data: contentItem.data

    header: GuhHeader {
        text: device.name
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/magic.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device})
        }

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("GenericDeviceStateDetailsPage.qml"), {device: root.device})
        }
    }

    Rectangle {
        id: infoPane
        visible: batteryState !== null || (connectedState !== null && connectedState.value === false)
        height: visible ? contentRow.implicitHeight : 0
        anchors { left: parent.left; top: parent.top; right: parent.right }
        property var batteryState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryLevel").id) : null
        property var batteryCriticalState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryCritical").id) : null
//        property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
        property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
        property bool alertState: (connectedState !== null && connectedState.value === false) ||
                                  (batteryCriticalState !== null && batteryCriticalState.value === true)
        color: alertState ? "red" : "transparent"
        z: 1000

        RowLayout {
            id: contentRow
            anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins }
            Item {
                Layout.fillWidth: true
                height: app.iconSize
            }

            Label {
                text: (infoPane.connectedState !== null && infoPane.connectedState.value === false) ?
                          qsTr("Thing is not connected!")
                        : qsTr("Thing runs out of battery!")
                visible: infoPane.alertState
                font.pixelSize: app.smallFont
                color: "white"
            }

            ColorIcon {
                height: app.iconSize / 2
                width: height
                visible: infoPane.connectedState !== null && infoPane.connectedState.value === false
                color: "white"
                name: "../images/dialog-warning-symbolic.svg"
            }

            ColorIcon {
                height: app.iconSize / 2
                width: height * 1.23
                name: infoPane.batteryState !== null ? "../images/battery/battery-" + ("00" + (Math.floor(infoPane.batteryState.value / 10) * 10)).slice(-3) + ".svg" : ""
                visible: infoPane.batteryState !== null
                color: infoPane.alertState ? "white" : keyColor
            }
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.topMargin: infoPane.height
        clip: true
    }
}
