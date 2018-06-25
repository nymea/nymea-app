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

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        spacing: app.margins * 2
        visible: Engine.deviceManager.devices.count === 0 && !Engine.deviceManager.fetchingData
        Label {
            text: qsTr("There are no things set up yet.")
            font.pixelSize: app.largeFont
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            color: app.guhAccent
        }
        Label {
            text: qsTr("In order for your %1 box to be useful, go ahead and add some things.").arg(app.systemName)
            Layout.fillWidth: true
            Layout.maximumWidth: 400
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        Image {
            source: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
            Layout.preferredWidth: app.iconSize * 5
            Layout.preferredHeight: width
            Layout.alignment: Qt.AlignHCenter
            sourceSize.width: app.iconSize * 5
            sourceSize.height: app.iconSize * 5
        }
        Button {
            Layout.fillWidth: true
            Layout.maximumWidth: 400
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Add a thing")
            onClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
        }
    }

}
