/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtQuick.Window 2.3
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.2
import Nymea 1.0
import "components"
import "delegates"
import "mainviews"

Page {
    id: root

    header: FancyHeader {
        id: mainHeader
        title: d.configOverlay !== null ? qsTr("Configure main view") : filteredContentModel.data(swipeView.currentIndex, "displayName")
        leftButtonVisible: true
        leftButtonImageSource: {
            switch (engine.jsonRpcClient.currentConnection.bearerType) {
            case Connection.BearerTypeLan:
            case Connection.BearerTypeWan:
                if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                    return "../images/connections/network-wired.svg"
                }
                return "../images/connections/network-wifi.svg";
            case Connection.BearerTypeBluetooth:
                return "../images/connections/network-wifi.svg";
            case Connection.BearerTypeCloud:
                return "../images/connections/cloud.svg"
            case Connection.BearerTypeLoopback:
                return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
            }
            return ""
        }
        onLeftButtonClicked: {
            var dialog = connectionDialogComponent.createObject(root)
            dialog.open();
        }
        onMenuOpenChanged: {
            if (menuOpen && d.configOverlay) {
                d.configOverlay.destroy()
            }
        }

        model: ListModel {
            ListElement { iconSource: "../images/things.svg"; text: qsTr("Configure things"); page: "thingconfiguration/EditThingsPage.qml" }
            ListElement { iconSource: "../images/magic.svg"; text: qsTr("Magic"); page: "MagicPage.qml" }
            ListElement { iconSource: "../images/stock_application.svg"; text: qsTr("App settings"); page: "appsettings/AppSettingsPage.qml" }
            ListElement { iconSource: "../images/settings.svg"; text: qsTr("System settings"); page: "SettingsPage.qml" }
        }

        onClicked: {
            pageStack.push(model.get(index).page)
        }
    }

    Connections {
        target: engine.ruleManager
        onAddRuleReply: {
            d.editRulePage.busy = false
            if (d.editRulePage) {
                pageStack.pop();
                d.editRulePage = null
            }
        }
    }
    QtObject {
        id: d
        property var editRulePage: null
        property var configOverlay: null
    }

    Settings {
        id: mainViewSettings
        category: engine.jsonRpcClient.currentHost.uuid
        property string mainMenuContent: ""
        property var sortOrder: []
        property var filterList: ["things"]
        property int currentIndex: 0
    }

    ListModel {
        id: mainMenuBaseModel
        // TODO: Should read this from disk somehow maybe?    
        ListElement { name: "things"; source: "ThingsView"; displayName: qsTr("Things"); icon: "things" }
        ListElement { name: "favorites"; source: "FavoritesView"; displayName: qsTr("Favorites"); icon: "starred" }
        ListElement { name: "groups"; source: "GroupsView"; displayName: qsTr("Groups"); icon: "view-grid-symbolic" }
        ListElement { name: "scenes"; source: "ScenesView"; displayName: qsTr("Scenes"); icon: "slideshow" }
        ListElement { name: "garages"; source: "GaragesView"; displayName: qsTr("Garages"); icon: "garage/garage-100" }
        ListElement { name: "energy"; source: "EnergyView"; displayName: qsTr("Energy"); icon: "smartmeter" }
        ListElement { name: "media"; source: "MediaView"; displayName: qsTr("Media"); icon: "media" }
        ListElement { name: "wallbox"; source: "WallboxView"; displayName: qsTr("Wallbox"); icon: "ev-charger" }
    }

    ListModel {
        id: mainMenuModel
        ListElement { name: "dummy"; source: "Dummy"; displayName: ""; icon: "" }

        Component.onCompleted: {
            var configList = {}
            var newList = {}
            var newItems = 0
            for (var i = 0; i < mainMenuBaseModel.count; i++) {
                var item = mainMenuBaseModel.get(i);
                var idx = mainViewSettings.sortOrder.indexOf(item.name);
                if (idx === -1) {
                    newList[newItems++] = item;
                } else {
                    configList[idx] = item;
                }
            }

            clear();

            for (idx in configList) {
                item = configList[idx];
                mainMenuModel.append(item)
            }
            for (idx  in newList) {
                item = newList[idx];
                mainMenuModel.append(item)
            }

            tabBar.currentIndex = Qt.binding(function() { return mainViewSettings.currentIndex; })
            swipeView.currentIndex = Qt.binding(function() { return tabBar.currentIndex; })
            mainViewSettings.currentIndex = Qt.binding(function() { return swipeView.currentIndex; })
        }
    }

    SortFilterProxyModel {
        id: filteredContentModel
        sourceModel: mainMenuModel
        filterList: mainViewSettings.filterList
        filterRoleName: "name"
    }

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
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            SwipeView {
                id: swipeView
                anchors.fill: parent
                opacity: d.configOverlay === null ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                Repeater {
                    model: d.configOverlay != null ? null : filteredContentModel

                    delegate: Loader {
                        width: swipeView.width
                        height: swipeView.height
                        clip: true
                        source: "mainviews/" + model.source + ".qml"
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
    footer: Item {
        readonly property bool shown: tabsRepeater.count > 1 || mainHeader.menuOpen || d.configOverlay
        implicitHeight: shown ? 70 + (app.landscape ? -20 : 0) : 0
        Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}

        TabBar {
            id: tabBar
            anchors { left: parent.left; top: parent.top; right: parent.right }
            height: 70 + (app.landscape ? -20 : 0)
            Material.elevation: 3
            position: TabBar.Footer

            opacity: (!mainHeader.menuOpen && !d.configOverlay) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            Repeater {
                id: tabsRepeater
                model: d.configOverlay != null ? null : filteredContentModel

                delegate: MainPageTabButton {
                    alignment: app.landscape ? Qt.Horizontal : Qt.Vertical
                    height: tabBar.height
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.displayName
                    iconSource: "../images/" + model.icon + ".svg"

                    onPressAndHold: {
                        PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                        d.configOverlay = configComponent.createObject(contentContainer)
                        mainHeader.menuOpen = false;
                    }
                }
            }
        }

        TabBar {
            anchors.fill: tabBar
            Material.elevation: 3
            position: TabBar.Footer

            opacity: mainHeader.menuOpen || d.configOverlay ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            visible: opacity > 0

            MainPageTabButton {
                height: tabBar.height
                alignment: app.landscape ? Qt.Horizontal : Qt.Vertical
                text: d.configOverlay ? qsTr("Done") : qsTr("Configure")
                iconSource: "../images/configure.svg"
                anchors.verticalCenter: parent.verticalCenter

                checked: false
                checkable: false

                onClicked: {
                    if (d.configOverlay) {
                        d.configOverlay.destroy()
                    } else {
                        PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                        d.configOverlay = configComponent.createObject(contentContainer)
                        mainHeader.menuOpen = false;
                    }
                }
            }
        }

    }

    Component {
        id: configComponent
        Item {
            id: configOverlay
            width: contentContainer.width
            height: contentContainer.height

            NumberAnimation {
                target: configOverlay
                property: "scale"
                duration: 200
                easing.type: Easing.InOutQuad
                from: 2
                to: 1
                running: true
            }
            NumberAnimation {
                target: configOverlay
                property: "opacity"
                duration: 200
                easing.type: Easing.InOutQuad
                from: 0
                to: 1
                running: true
            }

            ListView {
                id: configListView
                model: mainMenuModel
                width: parent.width
                height: parent.height / 2.5
                anchors.centerIn: parent
                orientation: ListView.Horizontal
                moveDisplaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 200 }
                }

                property int delegateWidth: width / 2.5

                property bool dragging: draggingIndex >= 0
                property int draggingIndex : -1

                MouseArea {
                    id: dndArea
                    anchors.fill: parent
                    preventStealing: configListView.dragging
                    property int dragOffset: 0

                    onPressAndHold: {
                        mouse.accepted = true
                        var mouseXInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).x;
                        configListView.draggingIndex = configListView.indexAt(mouseXInListView, mouseY)
                        var item = mainMenuModel.get(configListView.draggingIndex)
                        dndItem.displayName = item.displayName
                        dndItem.icon = item.icon
                        var visualItem = configListView.itemAt(mouseXInListView, mouseY)
                        dndItem.isEnabled = visualItem.isEnabled
                        dndArea.dragOffset = configListView.mapToItem(visualItem, mouseX, mouseY).x
                        PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
                    }
                    onMouseYChanged: {
                        if (configListView.dragging) {
                            var mouseXInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).x;
                            var indexUnderMouse = configListView.indexAt(mouseXInListView - dndArea.dragOffset / 2, mouseY)
                            indexUnderMouse = Math.min(Math.max(0, indexUnderMouse), configListView.count - 1)
                            if (configListView.draggingIndex !== indexUnderMouse) {
                                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                                mainMenuModel.move(configListView.draggingIndex, indexUnderMouse, 1)
                                configListView.draggingIndex = indexUnderMouse;
                            }
                        }
                    }
                    onReleased: {
                        print("released!")
                        var mouseXInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).x;
                        var clickedIndex = configListView.indexAt(mouseXInListView, mouseY)
                        var item = mainMenuModel.get(clickedIndex)
                        var isEnabled = mainViewSettings.filterList.indexOf(item.name) >= 0;
                        if (!configListView.dragging) {
                            var newList = []
                            for (var i = 0; i < mainMenuModel.count; i++) {
                                var entry = mainMenuModel.get(i).name;
                                if (entry === item.name) {
                                    if (!isEnabled) {
                                        newList.push(item.name)
                                    }
                                } else {
                                    if (mainViewSettings.filterList.indexOf(entry) >= 0) {
                                        newList.push(entry)
                                    }
                                }
                            }
                            if (newList.length === 0) {
                                newList.push("things")
                            }

                            mainViewSettings.filterList = newList
                        }
                        configListView.draggingIndex = -1;

                        var newSortOrder = []
                        for (var i = 0; i < mainMenuModel.count; i++) {
                            newSortOrder.push(mainMenuModel.get(i).name)
                        }
                        mainViewSettings.sortOrder = newSortOrder;
                    }
                    Timer {
                        id: scroller
                        interval: 2
                        repeat: true
                        running: direction != 0
                        property int direction: {
                            if (!configListView.dragging) {
                                return 0;
                            }
                            return dndArea.mouseX < 50 ? -2 : dndArea.mouseX > dndArea.width - 50 ? 2 : 0
                        }
                        onTriggered: {
                            configListView.contentX = Math.min(Math.max(0, configListView.contentX + direction), configListView.contentWidth - configListView.width)
                        }
                    }
                }

                delegate: Item {
                    id: configDelegate
                    width: configListView.delegateWidth
                    height: configListView.height
                    property bool isEnabled: mainViewSettings.filterList.indexOf(model.name) >= 0
                    visible: configListView.draggingIndex !== index

                    Pane {
                        anchors.fill: parent
                        anchors.margins: app.margins / 2
                        Material.elevation: 2

                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0

                        contentItem: ItemDelegate {
                            anchors.fill: parent

                            padding: app.margins * 2
                            contentItem: GridLayout {
                                columns: 1

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    ColorIcon {
                                        anchors.centerIn: parent
                                        width: Math.min(parent.width, parent.height) * .8
                                        height: width
                                        name: Qt.resolvedUrl("images/" + model.icon + ".svg")
                                        color: configDelegate.isEnabled ? app.accentColor : keyColor
                                    }
                                }


                                Label {
                                    text: model.displayName
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: app.largeFont
                                }
                            }
                        }
                    }
                }
                Item {
                    id: dndItem
                    width: configListView.delegateWidth
                    height: configListView.height
                    property bool isEnabled: false
                    property string displayName: ""
                    property string icon: "things"
                    visible: configListView.dragging
                    x: dndArea.mouseX - dndArea.dragOffset
                    onVisibleChanged: {
                        if (visible) {
                            dragStartAnimation.start();
                        }
                    }

                    NumberAnimation {
                        id: dragStartAnimation
                        target: dndItem
                        property: "scale"
                        from: 1
                        to: 0.9
                        duration: 200
                    }

                    Pane {
                        anchors.fill: parent
                        anchors.margins: app.margins / 2
                        Material.elevation: 2

                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0

                        contentItem: ItemDelegate {
                            anchors.fill: parent

                            padding: app.margins * 2
                            contentItem: GridLayout {
                                columns: 1

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    ColorIcon {
                                        anchors.centerIn: parent
                                        width: Math.min(parent.width, parent.height) * .8
                                        height: width
                                        name: Qt.resolvedUrl("images/" + dndItem.icon + ".svg")
                                        color: dndItem.isEnabled ? app.accentColor : keyColor
                                    }
                                }


                                Label {
                                    text: dndItem.displayName
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: app.largeFont
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: connectionDialogComponent
        MeaDialog {
            id: connectionDialog
            title: engine.jsonRpcClient.currentHost.name
            standardButtons: Dialog.NoButton
            headerIcon: {
                switch (engine.jsonRpcClient.currentConnection.bearerType) {
                case Connection.BearerTypeLan:
                case Connection.BearerTypeWan:
                    if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                        return "../images/connections/network-wired.svg"
                    }
                    return "../images/connections/network-wifi.svg";
                case Connection.BearerTypeBluetooth:
                    return "../images/connections/bluetooth.svg";
                case Connection.BearerTypeCloud:
                    return "../images/connections/cloud.svg"
                case Connection.BearerTypeLoopback:
                    return "../images/connections/network-wired.svg"
                }
                return ""
            }

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
                text: engine.jsonRpcClient.currentHost.name
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: app.margins
            }

            RowLayout {
                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: engine.jsonRpcClient.currentHost.uuid
                        font.pixelSize: app.smallFont
                        elide: Text.ElideRight
                        color: Material.color(Material.Grey)
                        //                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        Layout.fillWidth: true
                        text: engine.jsonRpcClient.currentConnection.url
                        font.pixelSize: app.smallFont
                        elide: Text.ElideRight
                        color: Material.color(Material.Grey)
                        //                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                ColorIcon {
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: app.iconSize
                    name: engine.jsonRpcClient.currentConnection.secure ? "../images/lock-closed.svg" : "../images/lock-open.svg"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var component = Qt.createComponent(Qt.resolvedUrl("connection/CertificateDialog.qml"));
                            var popup = component.createObject(app,  {serverUuid: engine.jsonRpcClient.serverUuid, issuerInfo: engine.jsonRpcClient.certificateIssuerInfo});
                            popup.open();
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: app.margins
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    id: disconnectButton
                    text: qsTr("Disconnect")
                    Layout.preferredWidth: Math.max(cancelButton.implicitWidth, disconnectButton.implicitWidth)
                    onClicked: {
                        tabSettings.lastConnectedHost = "";
                        engine.jsonRpcClient.disconnectFromHost();
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    id: cancelButton
                    text: qsTr("OK")
                    Layout.preferredWidth: Math.max(cancelButton.implicitWidth, disconnectButton.implicitWidth)
                    onClicked: connectionDialog.close()
                }
            }
        }
    }
}
