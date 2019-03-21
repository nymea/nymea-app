import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Web server")
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
                text: qsTr("Web server interfaces")
                wrapMode: Text.WordWrap
                color: app.accentColor
            }

            Repeater {
                model: engine.nymeaConfiguration.webServerConfigurations
                delegate: ConnectionInterfaceDelegate {
                    Layout.fillWidth: true
                    canDelete: true
                    onClicked: {
                        var component = Qt.createComponent(Qt.resolvedUrl("WebServerConfigurationDialog.qml"));
                        var popup = component.createObject(root, { serverConfiguration: engine.nymeaConfiguration.webServerConfigurations.get(index).clone() });
                        popup.accepted.connect(function() {
                            engine.nymeaConfiguration.setWebServerConfiguration(popup.serverConfiguration)
                            popup.serverConfiguration.destroy();
                        })
                        popup.rejected.connect(function() {
                            popup.serverConfiguration.destroy();
                        })
                        popup.open()
                    }
                    onDeleteClicked: {
                        print("should delete")
                        engine.nymeaConfiguration.deleteWebServerConfiguration(model.id)
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Add")
                onClicked: {
                    var config = engine.nymeaConfiguration.createWebServerConfiguration("0.0.0.0", 80 + engine.nymeaConfiguration.webServerConfigurations.count, false, false, "/var/www/");
                    var component = Qt.createComponent(Qt.resolvedUrl("WebServerConfigurationDialog.qml"));
                    var popup = component.createObject(root, { serverConfiguration: config });
                    popup.accepted.connect(function() {
                        engine.nymeaConfiguration.setWebServerConfiguration(popup.serverConfiguration)
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
