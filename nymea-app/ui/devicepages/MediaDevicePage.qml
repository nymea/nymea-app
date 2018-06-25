import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)


    header: GuhHeader {
        text: device.name
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("GenericDeviceStateDetailsPage.qml"), {device: root.device})
        }
    }


    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: app.margins

        ExtendedVolumeController {
            Layout.fillWidth: true
            device: root.device
            deviceClass: root.deviceClass
//            visible: deviceClass.interfaces.indexOf("extendedvolumecontroller") >= 0
        }

        MediaControllerView {
            Layout.fillWidth: true
            device: root.device
            deviceClass: root.deviceClass
            visible: root.deviceClass.interfaces.indexOf("mediacontroller") >= 0
        }
    }
}
