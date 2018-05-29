import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Mea 1.0
import "components"
import "delegates"

Page {
    id: root

    header: GuhHeader {
        text: qsTr("My things")
        backButtonVisible: false
        menuButtonVisible: true
        onMenuPressed: mainMenu.open()
    }

    // FIXME: Currently we don't have any feedback for executeAction
    // we don't want all the results, e.g. on looped calls like "all off"
    //    Connections {
    //        target: Engine.deviceManager
    //        onExecuteActionReply: {
    //            var text = params["deviceError"]
    //            switch(text) {
    //            case "DeviceErrorNoError":
    //                return;
    //            case "DeviceErrorHardwareNotAvailable":
    //                text = qsTr("Could not execute action. The thing is not available");
    //                break;
    //            }

    //            var errorDialog = Qt.createComponent(Qt.resolvedUrl("components/ErrorDialog.qml"))
    //            var popup = errorDialog.createObject(root, {text: text})
    //            popup.open()
    //        }
    //    }

    Menu {
        id: mainMenu
        width: implicitWidth + app.margins
        IconMenuItem {
            iconSource: "../images/share.svg"
            text: qsTr("Configure things")
            onTriggered: pageStack.push(Qt.resolvedUrl("EditDevicesPage.qml"))
        }
        IconMenuItem {
            iconSource: "../images/add.svg"
            text: qsTr("Add a new thing")
            onTriggered: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
        }
        MenuSeparator {}
        IconMenuItem {
            iconSource: "../images/magic.svg"
            text: qsTr("Magic")
            onTriggered: pageStack.push(Qt.resolvedUrl("MagicPage.qml"))
        }
        MenuSeparator {}
        IconMenuItem {
            iconSource: "../images/settings.svg"
            text: qsTr("System settings")
            onTriggered: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
        }
        MenuSeparator {}
        IconMenuItem {
            iconSource: "../images/stock_application.svg"
            text: qsTr("App settings")
            onTriggered: pageStack.push(Qt.resolvedUrl("AppSettingsPage.qml"))
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
            model: DevicesProxy {
                id: devicesProxy
                devices: Engine.deviceManager.devices
            }
            delegate: ThingDelegate {
                interfaces: model.interfaces
                name: model.name
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("devicepages/GenericDevicePage.qml"), {device: devicesProxy.get(index)})
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
                    text: qsTr("Loading data...")
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ColumnLayout {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
                spacing: app.margins
                visible: Engine.deviceManager.devices.count === 0 && !Engine.deviceManager.fetchingData
                Label {
                    text: qsTr("Welcome to %1!").arg(app.systemName)
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    color: app.guhAccent
                }
                Label {
                    text: qsTr("There are no things set up yet. You can start with adding your things by using the menu on the upper left and selecting \"Add a new thing\".")
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
