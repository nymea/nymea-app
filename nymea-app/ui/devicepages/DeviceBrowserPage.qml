import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Browse %1").arg(root.device.name)
        onBackPressed: pageStack.pop()
    }
    property Device device: null
    property string nodeId: ""

    Component.onCompleted: {
        d.model = engine.deviceManager.browseDevice(root.device.id, root.nodeId);
    }

    QtObject {
        id: d
        property BrowserItems model: null
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: d.model
        ScrollBar.vertical: ScrollBar {}

        delegate: NymeaListItemDelegate {
            width: parent.width
            text: model.displayName
            progressive: model.browsable
            subText: model.description
            prominentSubText: false
            iconName: model.thumbnail
            fallbackIcon: "../images/browser/" + model.icon + ".svg"
            enabled: model.browsable || model.executable

            onClicked: {
                print("clicked:", model.id)
                if (model.executable) {
                    engine.deviceManager.executeBrowserItem(root.device.id, model.id)
                } else if (model.browsable) {
                    pageStack.push(Qt.resolvedUrl("DeviceBrowserPage.qml"), {device: root.device, nodeId: model.id})
                }
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: listView.model.busy
            visible: running
        }
    }

}
