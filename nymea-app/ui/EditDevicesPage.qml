import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "components"
import "delegates"
import Nymea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Configure Things")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/find.svg"
            color: filterInput.shown ? app.accentColor : keyColor
            onClicked: filterInput.shown = !filterInput.shown

        }

        HeaderButton {
            imageSource: "../images/add.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
        }
    }

    QtObject {
        id: d
        property var deviceToRemove: null
    }

    Connections {
        target: engine.deviceManager
        onRemoveDeviceReply: {
            if (!d.deviceToRemove) {
                return;
            }

            switch (params.deviceError) {
            case "DeviceErrorNoError":
                d.deviceToRemove = null;
                return;
            case "DeviceErrorDeviceInRule":
                var removeMethodComponent = Qt.createComponent(Qt.resolvedUrl("components/RemoveDeviceMethodDialog.qml"))
                var popup = removeMethodComponent.createObject(root, {device: d.deviceToRemove, rulesList: params["ruleIds"]});
                popup.open();
                return;
            default:
                var popup = errorDialog.createObject(root, {errorCode: params.deviceError})
                popup.open();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListFilterInput {
            id: filterInput
            Layout.fillWidth: true
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: DevicesProxy {
                id: deviceProxy
                engine: _engine
                groupByInterface: true
                nameFilter: filterInput.shown ? filterInput.text : ""
            }
            section.property: "baseInterface"
            section.criteria: ViewSection.FullString
            section.delegate: ListSectionHeader {
                text: app.interfaceToString(section)
            }

            delegate: ThingDelegate {
                device: deviceProxy.get(index)
                canDelete: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("devicepages/ConfigureThingPage.qml"), {device: deviceProxy.get(index)})
                }
                onDeleteClicked: {
                    d.deviceToRemove = deviceProxy.get(index);
                    engine.deviceManager.removeDevice(d.deviceToRemove.id)
                }
            }
        }
    }


    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: engine.deviceManager.devices.count === 0 && !engine.deviceManager.fetchingData
        title: qsTr("There are no things set up yet.")
        text: qsTr("In order for your %1 box to be useful, go ahead and add some things.").arg(app.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        buttonText: qsTr("Add a thing")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
    }
}
