import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.2

Page {
    id: root
    footer: TabBar {
        Material.elevation: 2
        TabButton {
            text: "Things"
            onClicked: mainSwipeView.currentIndex = 0
        }
        TabButton {
            text: "Magic"
            onClicked: mainSwipeView.currentIndex = 1
        }
        TabButton {
            text: "Settings"
            onClicked: mainSwipeView.currentIndex = 2
        }
    }

    SwipeView {
        id: mainSwipeView
        anchors.fill: parent
        interactive: false

        DevicesPage {

        }

        Item {

        }

        SettingsPage {

        }
    }
}
