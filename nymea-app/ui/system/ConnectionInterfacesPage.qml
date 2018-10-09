import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Connection interfaces")
        onBackPressed: pageStack.pop();
    }

    Flickable {
        anchors.fill: parent
        contentHeight: connectionsColumn.implicitHeight
        interactive: contentHeight > height

        ColumnLayout {
            id: connectionsColumn
            anchors { left: parent.left; top: parent.top; right: parent.right }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: qsTr("TCP Server Interfaces")
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: engine.basicConfiguration.tcpServerConfigurations
                delegate: ConnectionInterfaceDelegate {
                    Layout.fillWidth: true
                    onDeleteClicked: {
                        print("should delete")
                        engine.basicConfiguration.deleteTcpServerConfiguration(model.id)
                    }
                }
            }
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: qsTr("WebSocket Server Interfaces")
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: engine.basicConfiguration.websocketServerConfigurations
                delegate: ConnectionInterfaceDelegate {
                    Layout.fillWidth: true
                    onDeleteClicked: {
                        print("should delete", model.id)
                        engine.basicConfiguration.deleteWebsocketServerConfiguration(model.id)
                    }
                }
            }
        }
    }
}
