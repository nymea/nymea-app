import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings
import Nymea
import NymeaApp.Utils

import "components"

Drawer {
    id: root
    dragMargin: 4

    property ConfiguredHostsModel configuredHosts: null
    readonly property Engine currentEngine: configuredHosts.count > 0 ? configuredHosts.get(configuredHosts.currentIndex).engine : null

    signal openThingSettings()
    signal openMagicSettings()
    signal openAppSettings()
    signal openSystemSettings()
    signal openCustomPage(string page)
    signal configureMainView()

    signal startWirelessSetup()
    signal startManualConnection()

    background: Rectangle {
        color: Style.backgroundColor
    }

    onClosed: topSectionLayout.configureConnections = false;

    // This allows to emit a custom signal and perform any other task besids opening a page
    // By defining a signalName property in the customMenuLinks it can be distinguished by using
    // the signalName string
    signal customMenuLinkClicked(string signalName)
    property var customMenuLinks: [ ]

    Settings {
        id: tokenSettings
        category: "jsonTokens"
    }

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
                        imageSource: "qrc:/icons/configure.svg"
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
                    Layout.fillWidth: true
                    Layout.preferredHeight: count * Style.smallDelegateHeight
                    model: root.configuredHosts
                    clip: true
                    interactive: false
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
                                imageSource: "qrc:/icons/close.svg"
                                visible: topSectionLayout.configureConnections && (autoConnectHost.length === 0 || index > 0)
                                longpressEnabled: false
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
                                    print("host is:", hostDelegate.configuredHost.uuid)
                                    if (hostDelegate.configuredHost.uuid != "{00000000-0000-0000-0000-000000000000}") {
                                        var popup = askCloseDialog.createObject(app, {uuid: hostDelegate.configuredHost.uuid, index: index})
                                        popup.open();
                                    } else {
                                        configuredHostsModel.removeHost(index)
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: askCloseDialog
                        NymeaDialog {
                            property string uuid
                            property int index
                            title: qsTr("Are you sure?")
                            text: qsTr("Do you want to log out from %1 and remove it from your connections?").arg(configuredHostsModel.get(index).name)
                            standardButtons: Dialog.Yes | Dialog.No
                            onAccepted: {
                                tokenSettings.setValue(uuid, "")
                                configuredHostsModel.removeHost(index)
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
                    iconName: "qrc:/icons/things.svg"
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                             && NymeaUtils.hasPermissionScope(root.currentEngine.jsonRpcClient.permissions, UserInfo.PermissionScopeConfigureThings)
                             && root.currentEngine.jsonRpcClient.connected
                    progressive: false
                    onClicked: {
                        root.openThingSettings()
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Magic")
                    iconName: "qrc:/icons/magic.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost
                             && NymeaUtils.hasPermissionScope(root.currentEngine.jsonRpcClient.permissions, UserInfo.PermissionScopeConfigureRules)
                             && root.currentEngine.jsonRpcClient.connected && Configuration.magicEnabled
                    onClicked: {
                        root.openMagicSettings();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Configure main view")
                    iconName: "qrc:/icons/configure.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost && root.currentEngine.jsonRpcClient.connected &&
                             !Configuration.hasOwnProperty("mainViewsFilter")
                    onClicked: {
                        root.configureMainView();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("App settings")
                    iconName: "qrc:/icons/stock_application.svg"
                    progressive: false
                    onClicked: {
                        root.openAppSettings();
                        root.close();
                    }
                }
                NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("System settings")
                    iconName: "qrc:/icons/settings.svg"
                    progressive: false
                    visible: root.currentEngine && root.currentEngine.jsonRpcClient.currentHost && root.currentEngine.jsonRpcClient.connected
                    onClicked: {
                        root.openSystemSettings();
                        root.close();
                    }
                }

                // Custom entries
                Repeater {
                    id: customRepeater

                    model: root.customMenuLinks
                    delegate: NymeaItemDelegate {
                        property var entry: root.customMenuLinks[index]
                        Layout.fillWidth: true
                        text: entry.text
                        iconName: entry.iconName
                        visible: entry.requiresEngine === true ? root.currentEngine && root.currentEngine.jsonRpcClient.currentHost && root.currentEngine.jsonRpcClient.connected : true
                        progressive: false
                        onClicked: {
                            if (entry.page !== undefined) {
                                root.openCustomPage(entry.page)
                            }

                            if (entry.signalName !== undefined) {
                                root.customMenuLinkClicked(entry.signalName)
                            }

                            root.close()
                        }
                    }
                }


                Item {
                    id: spaceItem
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.margins
                }

                Repeater {
                    id: configurationRepeater

                    model: Configuration.mainMenuLinks
                    delegate: NymeaItemDelegate {
                        property var entry: Configuration.mainMenuLinks[index]
                        Layout.fillWidth: true
                        text: entry.text
                        iconName: entry.iconName
                        visible: entry.requiresEngine === true ? root.currentEngine && root.currentEngine.jsonRpcClient.currentHost && root.currentEngine.jsonRpcClient.connected : true
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
}

