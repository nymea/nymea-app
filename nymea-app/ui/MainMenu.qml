import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0
import "components"
import Nymea 1.0
import NymeaApp.Utils 1.0

Drawer {
    id: root
    dragMargin: 4

    property ConfiguredHostsModel configuredHosts: null
    readonly property Engine currentEngine: configuredHosts.count > 0 ? configuredHosts.get(configuredHosts.currentIndex).engine : null

    signal openThingSettings();
    signal openMagicSettings();
    signal openAppSettings();
    signal openSystemSettings();
    signal openCustomPage(string page);
    signal configureMainView();

    signal startWirelessSetup();
    signal startManualConnection();

    background: Item {
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.leftPadding
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.tint(Style.backgroundColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.05)) }
                GradientStop { position: 0.3; color: Qt.tint(Style.backgroundColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.03)) }
            }
        }
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: root.leftPadding
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: Style.backgroundColor
        }
    }

    onClosed: topSectionLayout.configureConnections = false;

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: upperPart
            Layout.fillWidth: true
            Layout.preferredHeight: topSectionLayout.implicitHeight
            color: Qt.tint(Style.backgroundColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.05))

            ColumnLayout {
                id: topSectionLayout
                anchors { left: parent.left; top: parent.top; right: parent.right }
                spacing: 0

                property bool configureConnections: false

                RowLayout {
                    Layout.margins: Style.margins
                    spacing: Style.bigMargins
                    Image {
                        Layout.preferredHeight: Style.hugeIconSize
                        sourceSize.height: Style.hugeIconSize
                        Layout.fillWidth: true
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignLeft
                        source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
                    }
                    ProgressButton {
                        imageSource: "/ui/images/configure.svg"
                        longpressEnabled: false
                        Layout.alignment: Qt.AlignBottom
                        color: topSectionLayout.configureConnections ? Style.accentColor : Style.iconColor
                        onClicked: {
                            topSectionLayout.configureConnections = !topSectionLayout.configureConnections
                        }
                    }
                }

                ListView {
                    id: hostsListView
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }
                    Layout.fillWidth: true
                    Layout.preferredHeight: count * Style.smallDelegateHeight
                    Layout.maximumHeight: 5 * Style.smallDelegateHeight 
                    model: root.configuredHosts
                    clip: true
                    interactive: contentHeight > height
                    moveDisplaced: Transition {
                        NumberAnimation { property: "y"; duration: Style.animationDuration; easing.type: Easing.InOutQuad }
                    }

                    delegate: NymeaItemDelegate {
                        id: hostDelegate
                        width: hostsListView.width
                        visible: !dndArea.dragging || dndArea.draggedIndex !== index

                        readonly property ConfiguredHost configuredHost: root.configuredHosts.get(index)

                        text: model.name.length > 0 ? model.name : qsTr("New connection")
                        subText: configuredHost.engine.jsonRpcClient.currentConnection ? configuredHost.engine.jsonRpcClient.currentConnection.url : ""
                        prominentSubText: false
                        progressive: false
                        additionalItem: RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !dndArea.dragging
                            Rectangle {
                                height: Style.smallIconSize
                                width: height
                                radius: height / 2
                                color: Style.accentColor
                                Layout.alignment: Qt.AlignVCenter
                                visible: index === configuredHostsModel.currentIndex && !topSectionLayout.configureConnections
                            }

                            ProgressButton {
                                id: closeButton
                                imageSource: "/ui/images/close.svg"
                                visible: topSectionLayout.configureConnections && (autoConnectHost.length === 0 || index > 0)
                                longpressEnabled: false

                                Settings {
                                    id: tokenSettings
                                    category: "jsonTokens"
                                }
                            }
                        }

                        // ItemDelegates apparently fail to receive mouse events when hidden behind another mouse area with propagateComposedEvents
                        // As we keep the dnd area above this, use a standard MouseArea which works.
                        MouseArea {
                            id: itemArea
                            anchors.fill: parent
                            propagateComposedEvents: true

                            onClicked: {
                                print("clicked", itemArea.mouseX)
                                var mappedToCloseButton = mapToItem(closeButton, mouseX, mouseY)
                                print("mapped to close", mouseX, mouseY, mappedToCloseButton.x, mappedToCloseButton.y)
                                if (mappedToCloseButton.x > 0 && mappedToCloseButton.x < closeButton.width && mappedToCloseButton.y > 0 && mappedToCloseButton.y < closeButton.height) {
                                    print("on close button!")
                                }

                                if (topSectionLayout.configureConnections) {
                                    var nymeaHost = nymeaDiscovery.nymeaHosts.find(hostDelegate.configuredHost.uuid);
                                    if (nymeaHost) {
                                        var connectionInfoDialog = Qt.createComponent("/ui/components/ConnectionInfoDialog.qml")
                                        var popup = connectionInfoDialog.createObject(app,{nymeaEngine: configuredHost.engine, nymeaHost: nymeaHost})
                                        popup.open()
                                        popup.connectionSelected.connect(function(connection) {
                                            print("...")
                                            configuredHost.engine.jsonRpcClient.disconnectFromHost();
                                            configuredHost.engine.jsonRpcClient.connectToHost(nymeaHost, connection)
                                            configuredHostsModel.currentIndex = index
                                            root.close()
                                        })
                                    }
                                } else {
                                    configuredHostsModel.currentIndex = index
                                    root.close()
                                }
                            }

                            MouseArea {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: Style.margins }
                                width: Style.iconSize + Style.margins
                                height: width
                                enabled: topSectionLayout.configureConnections
                                onClicked: {
                                    tokenSettings.setValue(hostDelegate.configuredHost.uuid, "")
                                    configuredHostsModel.removeHost(index)
                                }
                            }
                        }
                    }

                    NymeaItemDelegate {
                        id: fakeDragItem
                        visible: dndArea.dragging
                        width: hostsListView.width
                        prominentSubText: false
                        progressive: false
                        background: Rectangle {
                            color: Style.tileBackgroundColor
                        }
                        additionalItem: ColorIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            size: Style.iconSize
                            name: "list-move"
                        }
                    }

                    MouseArea {
                        id: dndArea
                        enabled: false
                        anchors.fill: parent
                        propagateComposedEvents: true
                        preventStealing: dragging
                        property int draggedIndex: -1
                        property bool dragging: false
                        property int startY: 0
                        property int originY: 0

                        onPressed: {
                            startY = mouseY
                        }

                        onPressAndHold: {
                            if (hostsListView.count < 2) {
                                return;
                            }

                            draggedIndex = hostsListView.indexAt(mouseX, startY)
                            var draggedItem = hostsListView.itemAt(mouseX, startY)
                            fakeDragItem.text = draggedItem.text
                            fakeDragItem.subText = draggedItem.subText
                            fakeDragItem.y = draggedItem.y
                            originY = draggedItem.y
                            dragging = true
                        }

                        onMouseYChanged: {
                            if (!dragging) {
                                return;
                            }
                            var diff = startY - mouseY
                            fakeDragItem.y = Math.max(0, Math.min(hostsListView.height - fakeDragItem.height, originY - diff))

                            var hoveredIdx = hostsListView.indexAt(mouseX, mouseY)
                            if (hoveredIdx >= 0 && draggedIndex != hoveredIdx) {
                                print("moved", draggedIndex, "to", hoveredIdx)
                                root.configuredHosts.move(draggedIndex, hoveredIdx)
                                draggedIndex = hoveredIdx;
                            }
                        }

                        onReleased: {
                            dragging = false
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: topSectionLayout.configureConnections ? childrenRect.height : 0
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: Style.animationDuration; easing.type: Easing.InOutQuad }}
                    clip: true
                    NymeaItemDelegate {
                        width: parent.width
                        text: qsTr("Set up another...")
                        iconName: "add"
                        progressive: false
                        onClicked: {
                            var host = configuredHostsModel.createHost()
                            configuredHostsModel.currentIndex = configuredHosts.indexOf(host)
                            root.close();
                        }
                    }
                }
            }
        }


        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentColumn.implicitHeight
            interactive: contentHeight > height
            clip: true

            ScrollBar.vertical: ScrollBar {}

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 0

                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Configure things")
                    iconName: "../images/things.svg"
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                             && NymeaUtils.hasPermissionScope(root.currentEngine.jsonRpcClient.permissions, UserInfo.PermissionScopeConfigureThings)
                             && root.currentEngine.jsonRpcClient.connected && settings.showHiddenOptions
                    progressive: false
                    onClicked: {
                        root.openThingSettings()
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Magic")
                    iconName: "../images/magic.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                                 && NymeaUtils.hasPermissionScope(root.currentEngine.jsonRpcClient.permissions, UserInfo.PermissionScopeConfigureRules)
                                 && root.currentEngine.jsonRpcClient.connected && Configuration.magicEnabled && settings.showHiddenOptions
                    onClicked: {
                        root.openMagicSettings();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Configure main view")
                    iconName: "../images/configure.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost && root.currentEngine.jsonRpcClient.connected &&
                             !Configuration.hasOwnProperty("mainViewsFilter") && settings.showHiddenOptions
                    onClicked: {
                        root.configureMainView();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("App settings")
                    iconName: "../images/stock_application.svg"
                    progressive: false
                    onClicked: {
                        root.openAppSettings();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("System settings")
                    iconName: "../images/settings.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost && root.currentEngine.jsonRpcClient.connected
                    onClicked: {
                        root.openSystemSettings();
                        root.close();
                    }

                    Layout.bottomMargin: app.margins
                }


                Repeater {
                    model: Configuration.mainMenuLinks
                    delegate: NymeaItemDelegate {
                        property var entry: Configuration.mainMenuLinks[index]
                        Layout.fillWidth: true
                        text: entry.text
                        iconName: entry.iconName
                        progressive: false
                        onClicked: {
                            if (entry.page !== undefined) {
                                root.openCustomPage(entry.page)
                            }

                            if (entry.func !== undefined) {
                                entry.func(app, root.currentEngine)
                            }
                            if (entry.url !== undefined) {
                                Qt.openUrlExternally(entry.url)
                            }
                            root.close()
                        }
                    }
                }
            }
        }
    }

    //    Component {
    //        id: hostConnectionInfoComponent
    //        MeaDialog {

    //        }
    //    }
}

