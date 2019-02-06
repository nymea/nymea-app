import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Dialog {
    id: certDialog
    width: Math.min(parent.width * .9, 400)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    standardButtons: Dialog.Yes | Dialog.No

    property string url
    property var fingerprint
    property var issuerInfo
    property var pem

    readonly property bool hasOldFingerprint: engine.connection.isTrusted(url)

    ColumnLayout {
        id: certLayout
        anchors.fill: parent
        //                spacing: app.margins

        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            ColorIcon {
                Layout.preferredHeight: app.iconSize * 2
                Layout.preferredWidth: height
                name: certDialog.hasOldFingerprint ? "../images/lock-broken.svg" : "../images/info.svg"
                color: certDialog.hasOldFingerprint ? "red" : app.accentColor
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: certDialog.hasOldFingerprint ? qsTr("Warning") : qsTr("Hi there!")
                color: certDialog.hasOldFingerprint ? "red" : app.accentColor
                font.pixelSize: app.largeFont
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: certDialog.hasOldFingerprint ? qsTr("The certificate of this %1 box has changed!").arg(app.systemName) : qsTr("It seems this is the first time you connect to this %1 box.").arg(app.systemName)
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: certDialog.hasOldFingerprint ? qsTr("Did you change the box's configuration? Verify if this information is correct.") : qsTr("This is the box's certificate. Once you trust it, an encrypted connection will be established.")
        }

        ThinDivider {}
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: certGridLayout.implicitHeight
            Flickable {
                anchors.fill: parent
                contentHeight: certGridLayout.implicitHeight
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: contentHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                }

                GridLayout {
                    id: certGridLayout
                    columns: 2
                    width: parent.width

                    Repeater {
                        model: certDialog.issuerInfo

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: modelData
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("Fingerprint: ") + certDialog.fingerprint
                    }
                }
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: certDialog.hasOldFingerprint ? qsTr("Do you want to connect nevertheless?") : qsTr("Do you want to trust this device?")
            font.bold: true
        }
    }

    onAccepted: {
        engine.connection.acceptCertificate(certDialog.url, certDialog.pem)
    }
}
