import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root

    signal backPressed();
    signal thingSelected(var device);
    signal interfaceSelected(string interfaceName);

    header: GuhHeader {
        text: "Select a thing"
        onBackPressed: root.backPressed()
    }
    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            RadioButton {
                id: thingButton
                text: "A specific thing"
                checked: true
            }
            RadioButton {
                id: interfacesButton
                text: "A group of things"
            }
        }

        ListModel {
            id: supportedInterfacesModel
            ListElement { interfaceName: "battery"; name: "Battery powered devices" }
            ListElement { interfaceName: "temperatureSensor"; name: "Temperature sensors" }
            ListElement { interfaceName: "light"; name: "Lights" }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: thingButton.checked ? Engine.deviceManager.devices : supportedInterfacesModel
            clip: true
            delegate: ItemDelegate {
                text: model.name
                width: parent.width
                onClicked: {
                    if (thingButton.checked) {
                        root.thingSelected(Engine.deviceManager.devices.get(index))
                    } else {
                        root.interfaceSelected(supportedInterfacesModel.get(index).interfaceName)
                    }
                }
            }
        }
    }
}
