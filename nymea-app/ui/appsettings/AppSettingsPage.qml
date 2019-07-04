import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("App Settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight

        GridLayout {
            id: layout
            property bool isGrid: columns > 1
            anchors { left: parent.left; top: parent.top; right: parent.right; margins: isGrid ? app.margins : 0 }
            columns: Math.max(1, Math.floor(parent.width / 300))
            rowSpacing: isGrid ? app.margins : 0
            columnSpacing: isGrid ? app.margins : 0

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    text: qsTr("Look & feel")
                    subText: qsTr("Customize the app's look and behavior")
                    iconName: "../images/preferences-look-and-feel.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("LookAndFeelSettingsPage.qml"))
                }
            }

            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    text: qsTr("Cloud login")
                    subText: qsTr("Log into %1:cloud and manage connected %1:core systems").arg(app.systemName)
                    iconName: "../images/cloud.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("CloudLoginPage.qml"))
                }
            }
            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                visible: settings.showHiddenOptions
                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    text: qsTr("Developer options")
                    subText: qsTr("Yeehaaa!")
                    iconName: "../images/sdk.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("DeveloperOptionsPage.qml"))
                }
            }
            Pane {
                Layout.fillWidth: true
                Material.elevation: layout.isGrid ? 1 : 0
                padding: 0
                NymeaListItemDelegate {
                    width: parent.width
                    text: qsTr("About %1").arg(app.appName)
                    subText: qsTr("Find app versions and licence information")
                    iconName: "../images/info.svg"
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
        }
    }
}
