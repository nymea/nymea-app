import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Box settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        id: settingsColumn
        anchors { left: parent.left; right: parent.right; top: parent.top }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            spacing: app.margins
            Label {
                text: qsTr("Name")
            }
            TextField {
                id: nameTextField
                Layout.fillWidth: true
                text: engine.nymeaConfiguration.serverName
            }
            Button {
                text: qsTr("OK")
                visible: nameTextField.displayText !== engine.nymeaConfiguration.serverName
                onClicked: engine.nymeaConfiguration.serverName = nameTextField.displayText
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            spacing: app.margins

            Label {
                Layout.fillWidth: true
                text: qsTr("Language")
            }
            ComboBox {
                id: languageBox
                Layout.fillWidth: true
                model: engine.nymeaConfiguration.availableLanguages
                currentIndex: model.indexOf(engine.nymeaConfiguration.language)
                contentItem: Label {
                    leftPadding: app.margins / 2
                    text: Qt.locale(languageBox.displayText).nativeLanguageName + " (" + Qt.locale(languageBox.displayText).nativeCountryName + ")"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                delegate: ItemDelegate {
                    width: languageBox.width
                    contentItem: Label {
                        text: Qt.locale(modelData).nativeLanguageName + " (" + Qt.locale(modelData).nativeCountryName + ")"
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: languageBox.highlightedIndex === index
                }
                onActivated: {
                    engine.nymeaConfiguration.language = currentText;
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            spacing: app.margins
            Label {
                Layout.fillWidth: true
                text: qsTr("Time zone")
            }
            ComboBox {
                Layout.minimumWidth: 200
                model: engine.nymeaConfiguration.timezones
                currentIndex: model.indexOf(engine.nymeaConfiguration.timezone)
                onActivated: {
                    engine.nymeaConfiguration.timezone = currentText;
                }
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Reboot %1:core").arg(app.systemName)
            visible: engine.systemController.powerManagementAvailable
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                var text = qsTr("Are you sure you want to reboot your %1:core sytem now?").arg(app.systemName)
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "../images/dialog-warning-symbolic.svg",
                                                    title: qsTr("Reboot %1:core").arg(app.systemName),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    engine.systemController.reboot()
                })
            }
        }
        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Shutdown %1:core").arg(app.systemName)
            visible: engine.systemController.powerManagementAvailable
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                var text = qsTr("Are you sure you want to shut down your %1:core sytem now?").arg(app.systemName)
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "../images/dialog-warning-symbolic.svg",
                                                    title: qsTr("Shot down %1:core").arg(app.systemName),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    engine.systemController.shutdown()
                })
            }
        }
    }
}
