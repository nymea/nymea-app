import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root

    property alias shownInterfaces: devicesProxyInternal.shownInterfaces
    property alias hiddenInterfaces: devicesProxyInternal.hiddenInterfaces

    Component.onCompleted: {
        if (devicesProxyInternal.count === 1) {
            enterPage(0, true)
        }
    }

    property var devicesProxy: devicesProxyInternal

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

    DevicesProxy {
        id: devicesProxyInternal
        engine: Engine
    }
}
