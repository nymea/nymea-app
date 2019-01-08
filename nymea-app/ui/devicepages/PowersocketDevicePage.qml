import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

DevicePageBase {
    id: root

    readonly property var powerStateType: deviceClass.stateTypes.findByName("power")
    readonly property var powerState: device.states.getState(powerStateType.id)
    readonly property var powerActionType: deviceClass.actionTypes.findByName("power");

    GridLayout {
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1
        rowSpacing: app.margins
        columnSpacing: app.margins
        Layout.alignment: Qt.AlignCenter

        Item {
            Layout.preferredWidth: Math.max(app.iconSize * 4, parent.width / 5)
            Layout.preferredHeight: width
            Layout.topMargin: app.margins
            Layout.bottomMargin: app.landscape ? app.margins : 0
            Layout.alignment: Qt.AlignCenter
            Layout.rowSpan: app.landscape ? 4 : 1
            Layout.fillHeight: true

            AbstractButton {
                height: Math.min(parent.height, parent.width)
                width: height
                anchors.centerIn: parent
                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    border.color: root.powerState.value === true ? app.accentColor : bulbIcon.keyColor
                    border.width: 4
                    radius: width / 2
                }

                ColorIcon {
                    id: bulbIcon
                    anchors.fill: parent
                    anchors.margins: app.margins * 1.5
                    name: "../images/powersocket.svg"
                    color: root.powerState.value === true ? app.accentColor : keyColor
                }
                onClicked: {
                    var params = []
                    var param = {}
                    param["paramTypeId"] = root.powerActionType.paramTypes.get(0).id;
                    param["value"] = !root.powerState.value;
                    params.push(param)
                    engine.deviceManager.executeAction(root.device.id, root.powerStateType.id, params);
                }
            }
        }
    }
}
