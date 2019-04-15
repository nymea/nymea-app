import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Look and feel")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width

        RowLayout {
            Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            visible: !kioskMode
            Label {
                Layout.fillWidth: true
                text: qsTr("View mode")
            }
            ComboBox {
                model: [qsTr("Windowed"), qsTr("Maximized"), qsTr("Fullscreen")]
                currentIndex: {
                    switch (settings.viewMode) {
                    case ApplicationWindow.Windowed:
                        return 0;
                    case ApplicationWindow.Maximized:
                        return 1;
                    case ApplicationWindow.FullScreen:
                        return 2;
                    }
                }

                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0:
                        settings.viewMode = ApplicationWindow.Windowed;
                        break;
                    case 1:
                        settings.viewMode = ApplicationWindow.Maximized;
                        break;
                    case 2:
                        settings.viewMode = ApplicationWindow.FullScreen;
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true; Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            visible: appBranding.length === 0
            Label {
                Layout.fillWidth: true
                text: "Style"
            }
            ComboBox {
                model: styleController.allStyles
                currentIndex: styleController.allStyles.indexOf(styleController.currentStyle)

                onActivated: {
                    styleController.currentStyle = model[index]
                }
            }

            Connections {
                target: styleController
                onCurrentStyleChanged: {
                    var popup = styleChangedDialog.createObject(root)
                    popup.open()
                }
            }
        }

        CheckDelegate {
            Layout.fillWidth: true
            text: qsTr("Return to home on idle")
            checked: settings.returnToHome
            onClicked: settings.returnToHome = checked
        }
        CheckDelegate {
            Layout.fillWidth: true
            text: qsTr("Show connection tabs")
            checked: settings.showConnectionTabs
            onClicked: settings.showConnectionTabs = checked
        }
    }

    Component {
        id: styleChangedDialog
        Dialog {
            width: Math.min(parent.width * .8, contentLabel.implicitWidth)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            title: qsTr("Style changed")

            standardButtons: Dialog.Ok

            ColumnLayout {
                id: content
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Label {
                    id: contentLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr("The application needs to be restarted for style changes to take effect.")
                }
            }
        }
    }
}
