import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "components"

Page {
    id: root
    signal backPressed();

    header: GuhHeader {
        text: qsTr("Welcome to %1!").arg(app.systemName)
        backButtonVisible: true
        onBackPressed: {
            root.backPressed();
        }
    }

    Component.objectName: {
        Engine.jsonRpcClient.requestPushButtonAuth("");
    }

    Connections {
        target: Engine.jsonRpcClient
        onPushButtonAuthFailed: {
            var popup = errorDialog.createObject(root)
            popup.text = qsTr("Sorry, something went wrong during the setup. Try again please.")
            popup.open();
            popup.accepted.connect(function() {root.backPressed()})
        }
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        anchors.margins: app.margins
        spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins

            ColorIcon {
                height: app.iconSize * 2
                width: height
                color: app.accentColor
                name: "../images/info.svg"
            }

            Label {
                color: app.accentColor
                text: qsTr("Authentication required")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font.pixelSize: app.largeFont
            }
        }


        Label {
            Layout.fillWidth: true
            text: qsTr("Please press the button on your %1 box to authenticate this device.").arg(app.systemName)
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {

        }
    }
}
