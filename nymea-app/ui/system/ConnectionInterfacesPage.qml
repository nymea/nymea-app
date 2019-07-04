import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
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
                text: qsTr("TCP server interfaces")
                wrapMode: Text.WordWrap
                color: app.accentColor
            }

            Repeater {
                model: engine.nymeaConfiguration.tcpServerConfigurations
                delegate: ConnectionInterfaceDelegate {
                    Layout.fillWidth: true
                    canDelete: true
                    onClicked: {
                        var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
                        var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.tcpServerConfigurations.get(index).clone() });
                        popup.accepted.connect(function() {
                            engine.nymeaConfiguration.setTcpServerConfiguration(popup.serverConfiguration)
                            popup.serverConfiguration.destroy();
                        })
                        popup.rejected.connect(function() {
                            popup.serverConfiguration.destroy();
                        })
                        popup.open()
                    }
                    onDeleteClicked: {
                        print("should delete")
                        engine.nymeaConfiguration.deleteTcpServerConfiguration(model.id)
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Add")
                onClicked: {
                    var config = engine.nymeaConfiguration.createServerConfiguration("0.0.0.0", 2222 + engine.nymeaConfiguration.tcpServerConfigurations.count, false, false);
                    var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
                    var popup = component.createObject(root, { serverConfiguration: config });
                    popup.accepted.connect(function() {
                        engine.nymeaConfiguration.setTcpServerConfiguration(popup.serverConfiguration)
                        popup.serverConfiguration.destroy();
                    })
                    popup.rejected.connect(function() {
                        popup.serverConfiguration.destroy();
                    })
                    popup.open()
                }
            }

            ThinDivider {}
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                text: qsTr("WebSocket server interfaces")
                wrapMode: Text.WordWrap
                color: app.accentColor
            }

            Repeater {
                model: engine.nymeaConfiguration.webSocketServerConfigurations
                delegate: ConnectionInterfaceDelegate {
                    Layout.fillWidth: true
                    canDelete: true
                    onClicked: {
                        var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
                        var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.webSocketServerConfigurations.get(index).clone() });
                        popup.accepted.connect(function() {
                            print("configuring:", popup.serverConfiguration.port)
                            engine.nymeaConfiguration.setWebSocketServerConfiguration(popup.serverConfiguration)
                            popup.serverConfiguration.destroy();
                        })
                        popup.rejected.connect(function() {
                            popup.serverConfiguration.destroy();
                        })
                        popup.open()
                    }
                    onDeleteClicked: {
                        print("should delete", model.id)
                        engine.nymeaConfiguration.deleteWebSocketServerConfiguration(model.id)
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Add")
                onClicked: {
                    var config = engine.nymeaConfiguration.createServerConfiguration("0.0.0.0", 4444 + engine.nymeaConfiguration.webSocketServerConfigurations.count, false, false);
                    var component = Qt.createComponent(Qt.resolvedUrl("ServerConfigurationDialog.qml"));
                    var popup = component.createObject(root, { serverConfiguration: config });
                    popup.accepted.connect(function() {
                        engine.nymeaConfiguration.setWebSocketServerConfiguration(popup.serverConfiguration)
                        popup.serverConfiguration.destroy();
                    })
                    popup.rejected.connect(function() {
                        popup.serverConfiguration.destroy();
                    })
                    popup.open()
                }
            }
        }
    }
}
