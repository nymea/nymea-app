import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Mea 1.0
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
            text: "Settings"
            onTriggered: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
        }
        MenuSeparator {}
        IconMenuItem {
            iconSource: "../images/info.svg"
            text: "System information"
            onTriggered: pageStack.push(Qt.resolvedUrl("SystemInfoPage.qml"))
        }
    }

    InterfacesModel {
        id: page1Model
        devices: Engine.deviceManager.devices
        shownInterfaces: ["light", "weather", "sensor", "media", "garagegate"]
        property var view: null
        onCountChanged: buildView()
    }
    InterfacesModel {
        id: page2Model
        devices: Engine.deviceManager.devices
        shownInterfaces: ["gateway", "button", "notifications", "inputtrigger", "outputtrigger"]
        property var view: null
        onCountChanged: buildView()
    }

    Component {
        id: devicePageComponent
        DevicesPage {
            width: swipeView.width
            height: swipeView.height
            visible: count > 0
        }
    }

    Component {
        id: allDevicesComponent
        ListView {
            width: swipeView.width
            height: swipeView.height
            model: Engine.deviceManager.devices
            delegate: ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    spacing: app.margins
                    ColorIcon {
                        height: app.iconSize
                        width: height
                        name: app.interfacesToIcon(model.interfaces)
                        color: app.guhAccent
                    }

                    Label {
                        Layout.fillWidth: true
                        text: model.name
                    }
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("devicepages/GenericDevicePage.qml"), {device: Engine.deviceManager.devices.get(index)})
                }
            }

            ColumnLayout {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
                spacing: app.margins
                visible: Engine.deviceManager.fetchingData
                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: parent.visible
                }
                Label {
                    text: "Loading data..."
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ColumnLayout {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
                spacing: app.margins
                visible: Engine.deviceManager.devices.count === 0 && !Engine.deviceManager.fetchingData
                Label {
                    text: "Welcome to nymea!"
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    color: app.guhAccent
                }
                Label {
                    text: "There are no things set up yet. You can start with adding your things by using the menu on the upper left and selecting \"Add a new thing\"."
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    function buildView() {
        var shownViews = []
        if (page1Model.count > 0) {
            shownViews.push(0)
        }
        if (page2Model.count > 0) {
            shownViews.push(1)
        }
        shownViews.push(2)

        if (swipeView.count === shownViews.length) {
            return;
        }

        while (swipeView.count > 0) {
            swipeView.removeItem(0)
        }
        if (shownViews.indexOf(0) >= 0) {
            swipeView.addItem(devicePageComponent.createObject(swipeView, {model: page1Model}))
        }
        if (shownViews.indexOf(1) >= 0) {
            swipeView.addItem(devicePageComponent.createObject(swipeView, {model: page2Model}))
        }
        swipeView.addItem(allDevicesComponent.createObject(swipeView))
    }


    ColumnLayout {
        anchors.fill: parent

        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: pageIndicator.currentIndex
            clip: true
        }

        PageIndicator {
            id: pageIndicator
            Layout.alignment: Qt.AlignHCenter
            count: swipeView.count
            currentIndex: swipeView.currentIndex
            interactive: true
        }
    }
}
