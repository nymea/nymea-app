import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: subPage
    property alias shownInterfaces: devicesProxy.shownInterfaces
    property alias hiddenInterfaces: devicesProxy.hiddenInterfaces

    Component.onCompleted: {
        if (devicesProxy.count == 1) {
            enterPage(0, true)
        }
    }

    header: GuhHeader {
        text: {
            if (subPage.shownInterfaces.length === 1) {
                return qsTr("My %1").arg(interfaceToString(subPage.shownInterfaces[0]))
            } else if (subPage.shownInterfaces.length > 1 || subPage.hiddenInterfaces.length > 0) {
                return qsTr("My things")
            }
            return qsTr("All my things")
        }

        onBackPressed: {
            print("popping")
            pageStack.pop()
        }
    }

    function enterPage(index, replace) {
        var device = devicesProxy.get(index);
        var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
        var page = app.interfaceListToDevicePage(deviceClass.interfaces);
        if (replace) {
            pageStack.replace(Qt.resolvedUrl("../devicepages/" + page), {device: devicesProxy.get(index)})
        } else {
            pageStack.push(Qt.resolvedUrl("../devicepages/" + page), {device: devicesProxy.get(index)})
        }
    }

    ListView {
        anchors.fill: parent
        model: DevicesProxy {
            id: devicesProxy
            devices: Engine.deviceManager.devices
        }
        delegate: ThingDelegate {
            width: parent.width
            name: model.name
            interfaces: Engine.deviceManager.deviceClasses.getDeviceClass(model.deviceClassId).interfaces
            onClicked: {
                enterPage(index, false)
            }
        }
    }
}
