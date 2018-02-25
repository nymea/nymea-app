import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
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

    Pane {
        id: infoPane
        visible: batteryState !== null || (connectedState !== null && connectedState.value === false)
        height: visible ? implicitHeight : 0
        anchors { left: parent.left; top: parent.top; right: parent.right }
        property var batteryState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryLevel").id) : null
//        property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
        property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null

        RowLayout {
            anchors { left: parent.left; top: parent.top; right: parent.right }
            Item {
                Layout.fillWidth: true
                height: app.iconSize
            }

            Label {
                text: qsTr("Thing is not connected!")
                visible: infoPane.connectedState !== null && infoPane.connectedState.value === false
            }

            ColorIcon {
                height: app.iconSize
                width: height
                visible: infoPane.connectedState !== null && infoPane.connectedState.value === false
                color: "red"
                name: "../images/dialog-warning-symbolic.svg"
            }

            ColorIcon {
                height: app.iconSize
                width: height * 1.23
                name: infoPane.batteryState !== null ? "../images/battery/battery-" + ("00" + (Math.floor(infoPane.batteryState.value / 10) * 10)).slice(-3) + ".svg" : ""
                visible: infoPane.batteryState !== null
            }
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.topMargin: infoPane.height
    }
}
