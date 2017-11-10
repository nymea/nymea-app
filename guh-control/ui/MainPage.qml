import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Guh 1.0
import "components"

Page {
    id: root

    header: GuhHeader {
        text: "My things"
        backButtonVisible: false
        menuButtonVisible: true
        onMenuPressed: mainMenu.open()
    }

    Menu {
        id: mainMenu
        width: implicitWidth + app.margins
        IconMenuItem {
            iconSource: "../images/share.svg"
            text: "Configure things"
            onTriggered: pageStack.push(Qt.resolvedUrl("EditDevicesPage.qml"))
        }
        IconMenuItem {
            iconSource: "../images/add.svg"
            text: "Add a new thing"
            onTriggered: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
        }
        MenuSeparator {}
        IconMenuItem {
            iconSource: "../images/magic.svg"
            text: "Magic"
            onTriggered: pageStack.push(Qt.resolvedUrl("MagicPage.qml"))
        }
        MenuSeparator {}
        IconMenuItem {
            iconSource: "../images/settings.svg"
            text: "App settings"
            onTriggered: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
        }
        MenuSeparator {}
        IconMenuItem {
            iconSource: "../images/info.svg"
            text: "System information"
            onTriggered: pageStack.push(Qt.resolvedUrl("SystemInfoPage.qml"))
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: app.margins

        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true

            DevicesPage {
                width: parent.view.width
                height: parent.view.height
                shownInterfaces: ["light", "weather", "sensor", "media"]
            }

            DevicesPage {
                width: parent.view.width
                height: parent.view.height
                shownInterfaces: ["gateway", "button", "notifications"]
            }
        }

        PageIndicator {
            Layout.alignment: Qt.AlignHCenter
            count: swipeView.count
            currentIndex: swipeView.currentIndex
        }
    }




}
