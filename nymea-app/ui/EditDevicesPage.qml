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
            imageSource: "../images/add.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
        }
    }

    QtObject {
        id: d
        property var deviceToRemove: null
    }

    Connections {
        target: Engine.deviceManager
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

    ListView {
        anchors.fill: parent
        model: DevicesProxy {
            id: deviceProxy
            engine: Engine
            groupByInterface: true
        }
        section.property: "baseInterface"
        section.criteria: ViewSection.FullString
        section.delegate: ColumnLayout {
            width: parent.width
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: app.interfaceToString(section)
                horizontalAlignment: Text.AlignRight
            }
            ThinDivider {}
        }

        delegate: ThingDelegate {
            device: deviceProxy.get(index)
            canDelete: true
            onClicked: {
                pageStack.push(Qt.resolvedUrl("devicepages/ConfigureThingPage.qml"), {device: deviceProxy.get(index)})
            }
            onDeleteClicked: {
                d.deviceToRemove = deviceProxy.get(index);
                Engine.deviceManager.removeDevice(d.deviceToRemove.id)
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: Engine.deviceManager.devices.count === 0 && !Engine.deviceManager.fetchingData
        title: qsTr("There are no things set up yet.")
        text: qsTr("In order for your %1 box to be useful, go ahead and add some things.").arg(app.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        buttonText: qsTr("Add a thing")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
    }
}
