import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Guh 1.0

Page {
    id: root

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }

        Label {
            Layout.fillWidth: true
            text: "Connected to:"
            color: Material.accent
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: Engine.connection.url
            }
            Button {
                text: "Disconnect"
                onClicked: {
                    settings.lastConnectedHost = "";
                    Engine.connection.disconnect();
                }
            }
        }
    }
}
