import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.3
import Nymea 1.0
import "qrc:/ui/components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Charging session settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property ChargingSessions chargingSessions: ChargingSessions {
        engine: _engine
    }

    function exit() {
        pageStack.pop(root, StackView.Immediate);
        pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        TextField {
            id: nameTextField
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            placeholderText: qsTr("Please enter your name")
        }

        TextField {
            id: emailTextField
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            placeholderText: qsTr("Please enter your email")
            validator: RegExpValidator { regExp:/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            ColorIcon {
                size: Style.smallIconSize
                name: "dialog-warning-symbolic"
                color: Style.yellow
            }
            Label {
                Layout.fillWidth: true
                text: qsTr("Please make sure your email address is entered correctly.")
                wrapMode: Text.WordWrap
                font: Style.smallFont
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            text: qsTr("Attached emails:")
            wrapMode: Text.WordWrap

        }

        ListView {
            id: attachedEmails
            Layout.fillHeight: true
            Layout.fillWidth: true

            model: chargingSessions ? chargingSessions.configuration.emails : null

            delegate: NymeaSwipeDelegate {
                width: parent.width
                text: modelData
                progressive: false
                canDelete: true

                onDeleteClicked: {
                    chargingSessions.removeEmail(modelData)
                }
            }
        }

        Button {
            id: addEmailButton
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            text: qsTr("Attach email address")
            onClicked: chargingSessions.addEmail(emailTextField.text)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins

        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            Layout.bottomMargin: Style.margins
            enabled: emailTextField.acceptableInput && textArea.text != "" && nameTextField.text != ""
            text: qsTr("Send")
            onClicked: {

                //sendMail.sendMail(nameTextField.text, emailTextField.text, "nymea:energy support request", body, attachmentsButton.attachments)
                busyOverlay.shown = true
            }
        }
    }

    Component {
        id: resultPageComponent
        Page {
            id: resultPage
            property string text: ""
            property bool backButtonVisible: false
            header: NymeaHeader {
                text: qsTr("Support request")
                backButtonVisible: resultPage.backButtonVisible
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - Style.margins * 2
                spacing: Style.margins

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultPage.text
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Close")
                    onClicked: {
                        root.exit()
                    }
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
