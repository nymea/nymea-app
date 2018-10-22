import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../../components"
import Nymea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Network settings")
        onBackPressed: pageStack.pop()
    }

    property var networkManagerController: null

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        SwitchDelegate {
            Layout.fillWidth: true
            text: qsTr("Networking")
            checked: networkManagerController.manager.networkingEnabled
            onClicked: networkManagerController.manager.enableNetworking(checked)
        }

        SwitchDelegate {
            Layout.fillWidth: true
            enabled: networkManagerController.manager.networkingEnabled
            text: qsTr("Wireless network")
            checked: networkManagerController.manager.wirelessEnabled
            onClicked: {
                networkManagerController.manager.enableWireless(checked)
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Trigger a wireless scan on the device.")
            onClicked: networkManagerController.manager.performWifiScan()
        }
    }
}
