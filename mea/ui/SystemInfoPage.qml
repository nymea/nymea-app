import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "components"
import Mea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("System information")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins

            Label {
                Layout.fillWidth: true
                text: qsTr("Connected to:")
                color: Material.accent
            }
            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: Engine.connection.url
                }
                Button {
                    text: qsTr("Disconnect")
                    onClicked: {
                        settings.lastConnectedHost = "";
                        Engine.connection.disconnect();
                    }
                }
            }
        }

        ThinDivider {}

        ItemDelegate {
            Layout.fillWidth: true
            contentItem: RowLayout {
                Label {
                    text: qsTr("Log viewer")
                    Layout.fillWidth: true
                }
                Image {
                    source: "images/next.svg"
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: height
                }
            }

            onClicked: pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }
}
