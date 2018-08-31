import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtQuick.Window 2.3
import Nymea 1.0
import "components"
import "delegates"
import "mainviews"

Page {
    id: root

    header: FancyHeader {
        title: swipeView.currentItem.title

        model: ListModel {
            ListElement { iconSource: "../images/share.svg"; text: qsTr("Configure things"); page: "EditDevicesPage.qml" }
            ListElement { iconSource: "../images/magic.svg"; text: qsTr("Magic"); page: "MagicPage.qml" }
            ListElement { iconSource: "../images/stock_application.svg"; text: qsTr("App settings"); page: "appsettings/AppSettingsPage.qml" }
            ListElement { iconSource: "../images/settings.svg"; text: qsTr("Box settings"); page: "SettingsPage.qml" }
        }

        onClicked: {
            pageStack.push(model.get(index).page)
        }
    }

    // FIXME: Currently we don't have any feedback for executeAction
    // we don't want all the results, e.g. on looped calls like "all off"
    //    Connections {
    //        target: engine.deviceManager
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


    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            SwipeView {
                id: swipeView
                anchors.fill: parent
                anchors.leftMargin: (systemProductType === "ios" && Screen.width === 812) ? 25 : 0
                anchors.rightMargin: anchors.leftMargin
                opacity: engine.deviceManager.fetchingData ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 300 } }

                onCurrentIndexChanged: {
                    settings.currentMainViewIndex = currentIndex
                }

                Component.onCompleted:  {
                    if (engine.jsonRpcClient.ensureServerVersion(1.6)) {
                        swipeView.insertItem(0, favoritesViewComponent.createObject(swipeView))
                    }
                    if (settings.currentMainViewIndex > swipeView.count) {
                        settings.currentMainViewIndex = swipeView.count - 1;
                    }
                    swipeView.currentIndex = Qt.binding(function() { return settings.currentMainViewIndex; })
                }

                Component {
                    id: favoritesViewComponent
                    FavoritesView {
                        id: favoritesView
                        objectName: "favorites"
                        width: swipeView.width
                        height: swipeView.height
                        property string title: qsTr("My favorites")

                        EmptyViewPlaceholder {
                            anchors { left: parent.left; right: parent.right; margins: app.margins }
                            anchors.verticalCenter: parent.verticalCenter
                            visible: favoritesView.count === 0 && !engine.deviceManager.fetchingData
                            title: qsTr("There are no favorite things yet.")
                            text: engine.deviceManager.devices.count === 0 ?
                                      qsTr("It appears there are no things set up either yet. In order to use favorites you need to add some things first.") :
                                      qsTr("Favorites allow you to keep track of your most important things when you have lots of them. Watch out for the star when interacting with things and use it to mark them as your favorites.")
                            imageSource: "images/starred.svg"
                            buttonVisible: engine.deviceManager.devices.count === 0
                            buttonText: qsTr("Add a thing")
                            onButtonClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
                        }

                    }
                }

                DevicesPage {
                    property string title: qsTr("My things")
                    width: swipeView.width
                    height: swipeView.height
                    model: InterfacesSortModel {
                        interfacesModel: InterfacesModel {
                            deviceManager: engine.deviceManager
                            shownInterfaces: app.supportedInterfaces
                        }
                    }

                    EmptyViewPlaceholder {
                        anchors { left: parent.left; right: parent.right; margins: app.margins }
                        anchors.verticalCenter: parent.verticalCenter
                        visible: engine.deviceManager.devices.count === 0 && !engine.deviceManager.fetchingData
                        title: qsTr("Welcome to %1!").arg(app.systemName)
                        // Have that split in 2 because we need those strings separated in EditDevicesPage too and don't want translators to do them twice
                        text: qsTr("There are no things set up yet.") + "\n" + qsTr("In order for your %1 box to be useful, go ahead and add some things.").arg(app.systemName)
                        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                        buttonText: qsTr("Add a thing")
                        onButtonClicked: pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
                    }
                }

                ScenesView {
                    id: scenesView
                    property string title: qsTr("My scenes");
                    width: swipeView.width
                    height: swipeView.height

                    EmptyViewPlaceholder {
                        anchors { left: parent.left; right: parent.right; margins: app.margins }
                        anchors.verticalCenter: parent.verticalCenter
                        visible: scenesView.count === 0 && !engine.deviceManager.fetchingData
                        title: qsTr("There are no scenes set up yet")
                        text: engine.deviceManager.devices.count === 0 ?
                                  qsTr("It appears there are no things set up either yet. In order to use scenes you need to add some things first.") :
                                  qsTr("Scenes provide a useful way to control your things with just one click.")
                        imageSource: "images/slideshow.svg"
                        buttonText: engine.deviceManager.devices.count === 0 ? qsTr("Add a thing") : qsTr("Add a scene")
                        onButtonClicked: {
                            if (engine.deviceManager.devices.count === 0) {
                                pageStack.push(Qt.resolvedUrl("NewDeviceWizard.qml"))
                            } else {
                                var page = pageStack.push(Qt.resolvedUrl("MagicPage.qml"))
                                page.addRule()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
                spacing: app.margins
                visible: engine.deviceManager.fetchingData
                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
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
        }

    }
    footer: TabBar {
        id: tabBar
        Material.elevation: 3
        currentIndex: settings.currentMainViewIndex
        position: TabBar.Footer
        implicitHeight: 70 + (app.landscape ?
                                          ((systemProductType === "ios" && Screen.height === 375) ? -10 : -20) :
                                          (systemProductType === "ios" && Screen.height === 812) ? 14 : 0)


        // FIXME: All this can go away when we require Controls 2.3 (Qt 5.10) or greater as TabBar got a major rework there.
        // Ideally we'd just list the 3 items and set visible to false if the server version isn't good enough but TabBar
        // has troubles dealing with that. For now, let's manually fill it and use a timer to initialize the currentIndex.
        Component.onCompleted: {
            var pi = 0;
            if (engine.jsonRpcClient.ensureServerVersion(1.6)) {
                tabEntryComponent.createObject(tabBar, {text: qsTr("Favorites"), iconSource: "../images/starred.svg", pageIndex: pi++})
            }
            tabEntryComponent.createObject(tabBar, {text: qsTr("Things"), iconSource: "../images/share.svg", pageIndex: pi++})
            tabEntryComponent.createObject(tabBar, {text: qsTr("Scenes"), iconSource: "../images/slideshow.svg", pageIndex: pi++})
            initTimer.start()
        }
        Timer { id: initTimer; interval: 1; repeat: false; onTriggered: tabBar.currentIndex = Qt.binding(function() {return settings.currentMainViewIndex;})}

        Component {
            id: tabEntryComponent
            MainPageTabButton {
                property int pageIndex: 0
//                    height: tabBar.height
                onClicked: settings.currentMainViewIndex = pageIndex
                alignment: app.landscape ? Qt.Horizontal : Qt.Vertical
            }
        }
    }
}
