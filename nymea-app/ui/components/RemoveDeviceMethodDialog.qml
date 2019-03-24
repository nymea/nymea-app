import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

Dialog {
    id: root
    width: Math.min(parent.width * .8, contentLabel.implicitWidth + app.margins * 2)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true

    property var device: null
    property var rulesList: null

    ColumnLayout {
        width: parent.width
        Label {
            id: contentLabel
            text: qsTr("This thing is currently used in one or more rules:")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        ThinDivider {}
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: app.iconSize * Math.min(count, 5)
            model: rulesList
            interactive: contentHeight > height
            delegate: Label {
                height: app.iconSize
                width: parent.width
                elide: Text.ElideRight
                text: engine.ruleManager.rules.getRule(modelData).name
                verticalAlignment: Text.AlignVCenter
            }
        }
        ThinDivider {}

        MeaListItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Remove all those rules")
            progressive: false
            onClicked: {
                engine.deviceManager.removeDevice(root.device.id, DeviceManager.RemovePolicyCascade)
                root.close()
                root.destroy();
            }
        }

        MeaListItemDelegate {
            text: qsTr("Update rules, removing this thing")
            Layout.fillWidth: true
            progressive: false
            onClicked: {
                engine.deviceManager.removeDevice(root.device.id, DeviceManager.RemovePolicyUpdate)
                root.close()
                root.destroy();
            }
        }

        MeaListItemDelegate {
            text: qsTr("Don't remove this thing")
            Layout.fillWidth: true
            progressive: false
            onClicked: {
                root.close()
                root.destroy();
            }
        }
    }
}
