import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "components"
import Mea 1.0

Page {
    id: root
    header: GuhHeader {
        text: "Configure Things"
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: Engine.deviceManager.devices
        delegate: ItemDelegate {
            width: parent.width
            contentItem: RowLayout {
                spacing: app.margins
                ColorIcon {
                    height: app.iconSize
                    width: height
                    name: app.interfaceToIcon(model.interfaces[0])
                    color: app.guhAccent
                }

                Label {
                    Layout.fillWidth: true
                    text: model.name
                }
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("devicepages/ConfigureThingPage.qml"), {device: Engine.deviceManager.devices.get(index)})
            }
        }
    }
}
