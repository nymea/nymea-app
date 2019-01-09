import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root

    property bool selectInterface: false
    property alias showEvents: interfacesProxy.showEvents
    property alias showActions: interfacesProxy.showActions
    property alias showStates: interfacesProxy.showStates
    property alias shownInterfaces: devicesProxy.shownInterfaces
    property bool allowSelectAny: false

    signal backPressed();
    signal thingSelected(var device);
    signal interfaceSelected(string interfaceName);
    signal anySelected();

    header: GuhHeader {
        text: root.selectInterface ?
                  qsTr("Select a kind of things") :
                  root.shownInterfaces.length > 0 ? qsTr("Select a %1").arg(app.interfaceToDisplayName(root.shownInterfaces[0])) : qsTr("Select a thing")
        onBackPressed: root.backPressed()

        HeaderButton {
            imageSource: "../images/find.svg"
            color: filterInput.shown ? app.accentColor : keyColor
            onClicked: filterInput.shown = !filterInput.shown
        }
    }

    InterfacesProxy {
        id: interfacesProxy
        devicesFilter: engine.deviceManager.devices
    }

    DevicesProxy {
        id: devicesProxy
        engine: _engine
        groupByInterface: true
        nameFilter: filterInput.shown ? filterInput.text : ""
    }

    ColumnLayout {
        anchors.fill: parent

        ListFilterInput {
            id: filterInput
            Layout.fillWidth: true
        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Any %1").arg(app.interfaceToDisplayName(root.shownInterfaces[0]))
            visible: root.allowSelectAny
            onClicked: {
                root.anySelected();
            }
        }
        ThinDivider { visible: root.allowSelectAny }


        GroupedListView {
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
