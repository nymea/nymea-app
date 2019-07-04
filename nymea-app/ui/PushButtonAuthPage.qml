import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("Welcome to %1!").arg(app.systemName)
        backButtonVisible: true
        onBackPressed: {
            root.backPressed();
        }
    }

    Component.objectName: {
        engine.jsonRpcClient.requestPushButtonAuth("");
    }

    Connections {
        target: engine.jsonRpcClient
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
        spacing: app.margins * 2

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: app.accentColor
            text: qsTr("Authentication required")
            wrapMode: Text.WordWrap
            font.pixelSize: app.largeFont
        }

        Image {
            Layout.preferredWidth: app.iconSize * 6
            Layout.preferredHeight: width
            source: "images/nymea-box-setup.svg"
            Layout.alignment: Qt.AlignHCenter
            sourceSize.width: width
            sourceSize.height: height
        }


        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
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
