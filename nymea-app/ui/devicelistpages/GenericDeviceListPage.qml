import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

DeviceListPageBase {
    id: root

    header: GuhHeader {
        text: {
            if (root.shownInterfaces.length === 1) {
                return qsTr("My %1").arg(app.interfaceToString(root.shownInterfaces[0]))
            } else if (root.shownInterfaces.length > 1 || root.hiddenInterfaces.length > 0) {
                return qsTr("My things")
            }
            return qsTr("All my things")
        }

        onBackPressed: {
            pageStack.pop()
        }
    }

    ListView {
        anchors.fill: parent
        model: root.devicesProxy

        delegate: ThingDelegate {
            width: parent.width
            device: engine.deviceManager.devices.getDevice(model.id);
            onClicked: {
                enterPage(index, false)
            }
        }
    }
}
