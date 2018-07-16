import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root

    property bool selectInterface: false
    signal backPressed();
    signal thingSelected(var device);
    signal interfaceSelected(string interfaceName);
    property alias showEvents: interfacesProxy.showEvents
    property alias showActions: interfacesProxy.showActions
    property alias showStates: interfacesProxy.showStates
    property alias shownInterfaces: devicesProxy.shownInterfaces

    header: GuhHeader {
        text: root.selectInterface ?
                  qsTr("Select a kind of things") :
                  root.shownInterfaces.length > 0 ? qsTr("Select a %1").arg(app.interfaceToDisplayName(root.shownInterfaces[0])) : qsTr("Select a thing")
        onBackPressed: root.backPressed()
    }

    InterfacesProxy {
        id: interfacesProxy
        devicesFilter: Engine.deviceManager.devices
    }

    DevicesProxy {
        id: devicesProxy
        devices: Engine.deviceManager.devices
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.selectInterface ? interfacesProxy : devicesProxy
            clip: true
            delegate: MeaListItemDelegate {
                width: parent.width
                text: root.selectInterface ? model.displayName : model.name
                iconName: root.selectInterface ? app.interfaceToIcon(model.name) : app.interfacesToIcon(model.interfaces)
                onClicked: {
                    if (root.selectInterface) {
                        root.interfaceSelected(interfacesProxy.get(index).name)
                    } else {
                        root.thingSelected(devicesProxy.get(index))
                    }
                }
            }
        }
    }
}
