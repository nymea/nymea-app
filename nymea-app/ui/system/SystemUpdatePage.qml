import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("System update")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

//        HeaderButton {
//            imageSource: "../images/configure.svg"
//            color: pluginsProxy.showOnlyConfigurable ? app.accentColor : keyColor
//            onClicked: {
//                pluginsProxy.showOnlyConfigurable = !pluginsProxy.showOnlyConfigurable
//            }
//        }
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Your %1 system is up to date.").arg(app.systemName)
            visible: !engine.systemController.updateAvailable
        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            progressive: false
            text: qsTr("Installed version")
            subText: engine.systemController.currentVersion
        }
        MeaListItemDelegate {
            Layout.fillWidth: true
            progressive: false
            text: qsTr("Candidate version")
            subText: engine.systemController.candidateVersion
            visible: engine.systemController.updateAvailable
        }

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: qsTr("Update system")
            visible: engine.systemController.updateAvailable
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                var text = settings.showHiddenOptions
                        ? qsTr("Developer options are now enabled. If you have found this by accident, it is most likely not of any use for you. It will just enable some nerdy developer gibberish in the app. Tap the icon another 10 times to disable it again.")
                        : qsTr("Developer options are now disabled.")
                var popup = dialog.createObject(app, {headerIcon: "../images/dialog-warning-symbolic.svg", title: qsTr("Howdy cowboy!"), text: text})
                popup.open();
                popup.accepted.connect(function() {
                    engine.systemController.startUpdate()
                })
            }
        }

        ThinDivider {
            visible: settings.showHiddenOptions
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            spacing: app.margins
            visible: settings.showHiddenOptions
            Label {
                Layout.fillWidth: true
                text: qsTr("Update channel")
            }
            ComboBox {
                Layout.minimumWidth: 200
                model: engine.systemController.availableChannels
                currentIndex: model.indexOf(engine.systemController.currentChannel)
                onActivated: {
                    var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                    var text = qsTr("Changing the update channel allows to install unreleased software. This can potentially harm your system and lead to problems. Please only use this if you are sure you want this and consider reporting the issues you find when testing unreleased channels. Thank you.")
                    var popup = dialog.createObject(app,
                                                    {
                                                        headerIcon: "../images/dialog-warning-symbolic.svg",
                                                        title: qsTr("Switch update channel"),
                                                        text: text,
                                                        standardButtons: Dialog.Ok | Dialog.Cancel
                                                    });
                    popup.open();
                    popup.accepted.connect(function() {
                        engine.systemController.selectChannel(model[index])
                    })
                    popup.rejected.connect(function() {
                        currentIndex = model.indexOf(engine.systemController.currentChannel)
                    })

                }
            }
        }
    }

    BusyOverlay {
        visible: engine.systemController.updateInProgress
    }

}
