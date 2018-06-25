import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: subPage
    property alias filterInterface: devicesProxy.filterInterface

    Component.onCompleted: {
        if (devicesProxy.count == 1) {
            enterPage(0, true)
        }
    }

    header: GuhHeader {
        text: {
            if (subPage.filterInterface.length > 0) {
                return qsTr("My %1 things").arg(interfaceToString(subPage.filterInterface))
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
        var page;
        if (deviceClass.interfaces.indexOf("media") >= 0) {
            page = "MediaDevicePage.qml";
        } else if (deviceClass.interfaces.indexOf("button") >= 0) {
            page = "ButtonDevicePage.qml";
        } else if (deviceClass.interfaces.indexOf("weather") >= 0) {
            page = "WeatherDevicePage.qml";
        } else if (deviceClass.interfaces.indexOf("sensor") >= 0) {
            page = "SensorDevicePage.qml";
        } else if (deviceClass.interfaces.indexOf("inputtrigger") >= 0) {
            page = "InputTriggerDevicePage.qml";
        } else if (deviceClass.interfaces.indexOf("shutter") >= 0 ) {
            page = "ShutterDevicePage.qml";
        } else if (deviceClass.interfaces.indexOf("garagegate") >= 0 ) {
            page = "GarageGateDevicePage.qml";
        } else {
            page = "GenericDevicePage.qml";
        }
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
