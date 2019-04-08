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
                engine.systemController.startUpdate()
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
                    engine.systemController.selectChannel(model[index])
                }
            }
        }
    }

    BusyOverlay {
        visible: engine.systemController.updateInProgress
    }
}
