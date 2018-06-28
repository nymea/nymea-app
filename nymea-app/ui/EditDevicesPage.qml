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

    ListView {
        anchors.fill: parent
        model: Engine.deviceManager.devices
        delegate: ThingDelegate {
            interfaces:model.interfaces
            name: model.name
            canDelete: true
            onClicked: {
                pageStack.push(Qt.resolvedUrl("devicepages/ConfigureThingPage.qml"), {device: Engine.deviceManager.devices.get(index)})
            }
            onDeleteClicked: {
                Engine.deviceManager.removeDevice(Engine.deviceManager.devices.get(index).id)
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
