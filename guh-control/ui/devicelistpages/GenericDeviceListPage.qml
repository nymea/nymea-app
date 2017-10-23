import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "../components"

Page {
    id: subPage
    property alias filterTag: devicesProxy.filterTag
    property alias filterInterface: devicesProxy.filterInterface

    header: GuhHeader {
        text: {
            if (subPage.filterTag != DeviceClass.BasicTagNone) {
                return qsTr("My %1 things").arg(devicesBasicTagsModel.basicTagToString(subPage.filterTag))
            } else if (subPage.filterInterface.length > 0) {
                return qsTr("My %1 things").arg(interfaceToString(subPage.filterInterface))
            }
            return qsTr("All my things")
        }

        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: DevicesProxy {
            id: devicesProxy
            devices: Engine.deviceManager.devices
        }
        delegate: ItemDelegate {
            width: parent.width
            Label {
                anchors { fill: parent; leftMargin: app.margins; rightMargin: app.margins }
                text: model.name
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                var device = devicesProxy.get(index);
                var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                print("clicked", deviceClass.interfaces)
                if (deviceClass.interfaces.indexOf("media") >= 0) {
                    pageStack.push(Qt.resolvedUrl("../devicepages/MediaDevicePage.qml"), {device: devicesProxy.get(index)})
                } else {
                    pageStack.push(Qt.resolvedUrl("../devicepages/GenericDevicePage.qml"), {device: devicesProxy.get(index)})
                }
            }
        }
    }
}
