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
        leftButtonVisible: true
        leftButtonImageSource: {
            switch (engine.connection.currentConnection.bearerType) {
            case Connection.BearerTypeLan:
            case Connection.BearerTypeWan:
                if (engine.connection.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                    return "../images/network-wired.svg"
                }
                return "../images/network-wifi.svg";
            case Connection.BearerTypeBluetooth:
                return "../images/network-wifi.svg";
            case Connection.BearerTypeCloud:
                return "../images/cloud.svg"
            case Connection.BearerTypeLoopback:
                return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
            }
            return ""
        }
        onLeftButtonClicked: {
            var dialog = connectionDialogComponent.createObject(root, {headerIcon: leftButtonImageSource})
            dialog.open();
        }


        model: ListModel {
            ListElement { iconSource: "../images/share.svg"; text: qsTr("Configure things"); page: "thingconfiguration/EditThingsPage.qml" }
            ListElement { iconSource: "../images/magic.svg"; text: qsTr("Magic"); page: "MagicPage.qml" }
            ListElement { iconSource: "../images/stock_application.svg"; text: qsTr("App settings"); page: "appsettings/AppSettingsPage.qml" }
            ListElement { iconSource: "../images/settings.svg"; text: qsTr("System settings"); page: "SettingsPage.qml" }
        }

        onClicked: {
            pageStack.push(model.get(index).page)
        }
    }

    property int currentViewIndex: 0

    property bool swipeViewReady: false
    property bool tabsReady: false

    // FIXME: All this can go away when we require Controls 2.3 (Qt 5.10) or greater as TabBar got a major rework there.
    // Ideally we'd just list the 3 items and set visible to false if the server version isn't good enough but TabBar
    // has troubles dealing with that. For now, let's manually fill it and use a timer to initialize the currentIndex.
    Component.onCompleted: {
        // Fill SwipeView (The 2 static views things and scenes will already be there).
        if (engine.jsonRpcClient.ensureServerVersion(1.6)) {
            swipeView.insertItem(0, favoritesViewComponent.createObject(swipeView))
        }
        var experienceView = null;
        if (styleController.currentExperience != "Default") {
            experienceView = experienceViewComponent.createObject(swipeView, {source: "experiences/" + styleController.currentExperience + "/Main.qml" });
            swipeView.insertItem(0, experienceView)
        }
        root.swipeViewReady = true;


        var pi = 0;
        if (experienceView) {
            tabEntryComponent.createObject(tabBar, {text: experienceView.title, iconSource: experienceView.icon, pageIndex: pi++})
        }
        if (engine.jsonRpcClient.ensureServerVersion(1.6)) {
            tabEntryComponent.createObject(tabBar, {text: qsTr("Favorites"), iconSource: "../images/starred.svg", pageIndex: pi++})
        }
        tabEntryComponent.createObject(tabBar, {text: qsTr("Things"), iconSource: "../images/share.svg", pageIndex: pi++})
        tabEntryComponent.createObject(tabBar, {text: qsTr("Scenes"), iconSource: "../images/slideshow.svg", pageIndex: pi++})
        if (engine.jsonRpcClient.ensureServerVersion(1.6)) {
            tabEntryComponent.createObject(tabBar, {text: qsTr("Groups"), iconSource: "../images/view-grid-symbolic.svg", pageIndex: pi++})
        }

        root.tabsReady = true
    }

    readonly property bool viewReady: swipeViewReady && tabsReady
    onViewReadyChanged: {
        if (tabSettings.currentMainViewIndex > swipeView.count) {
            tabSettings.currentMainViewIndex = swipeView.count - 1;
        }

        // Load current index from settings
        currentViewIndex = tabSettings.currentMainViewIndex;

        // If setting is not initialized yet, init to "Things" page (might be 0 or 1, depending whether we have tags support)
        if (currentViewIndex === -1) {
            currentViewIndex = engine.jsonRpcClient.ensureServerVersion(1.6) ? 1 : 0
        }

        // and set up a binding to sync changes back to the settings
        tabSettings.currentMainViewIndex = Qt.binding(function() { return root.currentViewIndex; });

        // Tabbar gets a little confused if it's bound to it before the init happened, do it now
        tabBar.currentIndex = Qt.binding(function() { return root.currentViewIndex; });
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
        id: mainColumn
        anchors.fill: parent
        spacing: 0

        Pane {
            Layout.fillWidth: true
            Layout.preferredHeight: shownHeight
            property int shownHeight: shown ? contentRow.implicitHeight : 0
            property bool shown: updatesModel.count > 0 || engine.systemController.updateRunning
            visible: shownHeight > 0
            Behavior on shownHeight { NumberAnimation { easing.type: Easing.InOutQuad; duration: 150 } }
            Material.elevation: 2
            padding: 0

            MouseArea {
                anchors.fill: parent
                onClicked: pageStack.push(Qt.resolvedUrl("system/SystemUpdatePage.qml"))
            }

            Rectangle {
                color: app.accentColor
                anchors.fill: parent

                PackagesFilterModel {
                    id: updatesModel
                    packages: engine.systemController.packages
                    updatesOnly: true
                }

                RowLayout {
                    id: contentRow
                    anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins }
                    Item {
                        Layout.fillWidth: true
                        height: app.iconSize
                    }

                    Label {
                        text: engine.systemController.updateRunning ? qsTr("System update in progress...") : qsTr("%n system update(s) available", "", updatesModel.count)
                        color: "white"
                        font.pixelSize: app.smallFont
                    }
                    ColorIcon {
                        height: app.iconSize / 2
                        width: height
                        color: "white"
                        name: "../images/system-update.svg"
                        RotationAnimation on rotation { from: 0; to: 360; duration: 2000; loops: Animation.Infinite; running: engine.systemController.updateRunning }
                    }
                }
            }
        }


        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            SwipeView {
                id: swipeView
                anchors.fill: parent
                currentIndex: root.currentViewIndex

                onCurrentIndexChanged: {
                    root.currentViewIndex = currentIndex
                }

                Component {
                    id: experienceViewComponent
                    Loader {
                        width: swipeView.width
                        height: swipeView.height
                        clip: true
                        readonly property string title: item ? item.title : ""
                        readonly property string icon: item ? item.icon : ""
                    }
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
                            onButtonClicked: pageStack.push(Qt.resolvedUrl("thingconfiguration/NewThingPage.qml"))
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
                            showUncategorized: true
                        }
                    }

                    EmptyViewPlaceholder {
                        anchors { left: parent.left; right: parent.right; margins: app.margins }
                        anchors.verticalCenter: parent.verticalCenter
                        visible: engine.deviceManager.devices.count === 0 && !engine.deviceManager.fetchingData
                        title: qsTr("Welcome to %1!").arg(app.systemName)
                        // Have that split in 2 because we need those strings separated in EditDevicesPage too and don't want translators to do them twice
                        text: qsTr("There are no things set up yet.") + "\n" + qsTr("In order for your %1 system to be useful, go ahead and add some things.").arg(app.systemName)
                        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                        buttonText: qsTr("Add a thing")
                        onButtonClicked: pageStack.push(Qt.resolvedUrl("thingconfiguration/NewThingPage.qml"))
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
                        title: qsTr("There are no scenes set up yet.")
                        text: engine.deviceManager.devices.count === 0 ?
                                  qsTr("It appears there are no things set up either yet. In order to use scenes you need to add some things first.") :
                                  qsTr("Scenes provide a useful way to control your things with just one click.")
                        imageSource: "images/slideshow.svg"
                        buttonText: engine.deviceManager.devices.count === 0 ? qsTr("Add a thing") : qsTr("Add a scene")
                        onButtonClicked: {
                            if (engine.deviceManager.devices.count === 0) {
                                pageStack.push(Qt.resolvedUrl("thingconfiguration/NewThingPage.qml"))
                            } else {
                                var newRule = engine.ruleManager.createNewRule();
                                var editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: newRule });
                                editRulePage.startAddAction();
                                editRulePage.StackView.onRemoved.connect(function() {
                                    newRule.destroy();
                                })
                                editRulePage.onAccept.connect(function() {
                                    editRulePage.busy = true;
                                    engine.ruleManager.addRule(d.editRulePage.rule);
                                })
                                editRulePage.onCancel.connect(function() {
                                    pageStack.pop();
                                })
                            }
                        }
                    }
                }

                GroupsView {
                    id: groupsView
                    property string title: qsTr("My groups");
                    width: swipeView.width
                    height: swipeView.height

                    EmptyViewPlaceholder {
                        anchors { left: parent.left; right: parent.right; margins: app.margins }
                        anchors.verticalCenter: parent.verticalCenter
                        visible: groupsView.count == 0 && !engine.deviceManager.fetchingData && !engine.tagsManager.busy
                        title: qsTr("There are no groups set up yet.")
                        text: qsTr("Grouping things can be useful to control multiple devices at once, for example an entire room. Watch out for the group symbol when interacting with things and use it to add them to groups.")
                        imageSource: "images/view-grid-symbolic.svg"
                        buttonVisible: false
//                        buttonText: qsTr("Create a group")
//                        onButtonClicked: pageStack.push(Qt.resolvedUrl("thingconfiguration/NewThingPage.qml"))
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
        position: TabBar.Footer
        implicitHeight: 70 + (app.landscape ? -20 : 0)

        Component {
            id: tabEntryComponent
            MainPageTabButton {
                property int pageIndex: 0
//                    height: tabBar.height
                onClicked: root.currentViewIndex = pageIndex
                alignment: app.landscape ? Qt.Horizontal : Qt.Vertical
            }
        }
    }

    Component {
        id: connectionDialogComponent
        MeaDialog {
            id: connectionDialog
            title: engine.connection.currentHost.name
            standardButtons: Dialog.NoButton

            Label {
                Layout.fillWidth: true
                text: qsTr("Connected to")
                font.pixelSize: app.smallFont
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                Layout.fillWidth: true
                text: engine.connection.currentHost.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                Layout.fillWidth: true
                text: engine.connection.currentHost.uuid
                font.pixelSize: app.smallFont
                elide: Text.ElideRight
                color: Material.color(Material.Grey)
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                Layout.fillWidth: true
                text: engine.connection.currentConnection.url
                font.pixelSize: app.smallFont
                elide: Text.ElideRight
                color: Material.color(Material.Grey)
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: app.margins
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    id: cancelButton
                    text: qsTr("OK")
                    Layout.preferredWidth: Math.max(cancelButton.implicitWidth, disconnectButton.implicitWidth)
                    onClicked: connectionDialog.close()
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    id: disconnectButton
                    text: qsTr("Disconnect")
                    Layout.preferredWidth: Math.max(cancelButton.implicitWidth, disconnectButton.implicitWidth)
                    onClicked: {
                        tabSettings.lastConnectedHost = "";
                        engine.connection.disconnect();
                    }
                }
            }
        }
    }
}
