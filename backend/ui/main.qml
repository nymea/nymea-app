import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("guh control")

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            id: devicePage
            Label {
                text: qsTr("Devices list")
                anchors.centerIn: parent
            }
        }

        Page {
            Label {
                text: qsTr("Rules")
                anchors.centerIn: parent
            }
        }

        Page {
            Label {
                text: qsTr("Settings")
                anchors.centerIn: parent
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("Devices")
        }
        TabButton {
            text: qsTr("Rules")
        }
        TabButton {
            text: qsTr("Settings")
        }
    }
}
