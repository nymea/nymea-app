import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../../components"
import Nymea 1.0

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Box information")
        onBackPressed: pageStack.pop()
    }

    property var networkManagerController: null

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        NymeaListItemDelegate {
            Layout.fillWidth: true
            progressive: false
            text: qsTr("System UUID")
            subText: networkManagerController.manager.modelNumber
        }
        NymeaListItemDelegate {
            Layout.fillWidth: true
            progressive: false
            text: qsTr("Manufacturer")
            subText: networkManagerController.manager.manufacturer
        }
        NymeaListItemDelegate {
            Layout.fillWidth: true
            progressive: false
            text: qsTr("Software revision")
            subText: networkManagerController.manager.softwareRevision
        }
        NymeaListItemDelegate {
            Layout.fillWidth: true
            progressive: false
            text: qsTr("Firmware revision")
            subText: networkManagerController.manager.firmwareRevision
        }
        NymeaListItemDelegate {
            Layout.fillWidth: true
            progressive: false
            text: qsTr("Hardware revision")
            subText: networkManagerController.manager.hardwareRevision
        }
    }
}
