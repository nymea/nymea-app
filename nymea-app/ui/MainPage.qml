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
import QtGraphicalEffects 1.0
import Nymea 1.0
import "components"
import "delegates"
import "mainviews"

Page {
    id: root

    // Removing the background from this page only because the MainViewBase adds it again in
    // a deepter layer as we need to include it in the blurring of the header and footer.
    // We don't want to paint the background on the entire screen twice (overdraw is costly)
    background: null

    function configureViews() {
        if (Configuration.hasOwnProperty("mainViewsFilter")) {
            console.warn("Main views configuration is disabled by app configuration")
            return
        }

        PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
        d.configOverlay = configComponent.createObject(contentContainer)
    }

    function goToView(viewName, data) {
        // We allow separating the target by : and pass more stuff to
        console.log("Going to main view", viewName, filteredContentModel.count, data)
        for (var i = 0; i < filteredContentModel.count; i++) {
            console.log("got", i, filteredContentModel.modelData(i, "name"))
            if (filteredContentModel.modelData(i, "name") === viewName) {
                console.log("activating", i)
//                mainViewSettings.currentIndex = i;
//                tabBar.currentIndex = i;
                swipeView.setCurrentIndex(i)
                swipeView.currentItem.item.handleEvent(data)
                break;
            }
        }
    }

    header: Item {
        id: mainHeader
        height: 0

        HeaderButton {
            id: menuButton
            imageSource: "../images/navigation-menu.svg"
            anchors { left: parent.left; top: parent.top }
            onClicked: {
                if (d.configOverlay != null) {
                    d.configOverlay.destroy();
                }
                app.mainMenu.open()
            }
        }

        Row {
            id: additionalIcons
            anchors { right: parent.right; top: parent.top }
            visible: !d.configOverlay
            width: visible ? implicitWidth : 0

            HeaderButton {
                id: button
                imageSource: "../images/system-update.svg"
                color: Style.accentColor
                visible: updatesModel.count > 0 || engine.systemController.updateRunning
                onClicked: pageStack.push(Qt.resolvedUrl("system/SystemUpdatePage.qml"))
                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 2000
                    loops: Animation.Infinite
                    running: engine.systemController.updateRunning
                    onStopped: button.rotation = 0;
                }
                PackagesFilterModel {
                    id: updatesModel
                    packages: engine.systemController.packages
                    updatesOnly: true
                }
            }
            Repeater {
                model: swipeView.currentItem != null && swipeView.currentItem.item.hasOwnProperty("headerButtons") ? swipeView.currentItem.item.headerButtons : 0
                delegate: HeaderButton {
                    imageSource: swipeView.currentItem.item.headerButtons[index].iconSource
                    onClicked: swipeView.currentItem.item.headerButtons[index].trigger()
                    visible: swipeView.currentItem.item.headerButtons[index].visible
                    color: swipeView.currentItem.item.headerButtons[index].color
                }
            }
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
        property bool blurEnabled: PlatformHelper.deviceManufacturer !== "raspbian"
        property var editRulePage: null
        property var configOverlay: null
    }

    Settings {
        id: mainViewSettings
        category: engine.jsonRpcClient.currentHost.uuid
        property string mainMenuContent: ""
        property var sortOrder: []
        // Priority for main view config:
        // 1. Settings made by the user
        // 2. Style mainViewsFilter as that comes with branding (for now, if a style defines main views, all of them are active by default)
        // 3. Command line args
        // 4. Just show "things" alone by default
        property var filterList: Configuration.hasOwnProperty("mainViewsFilter") ?
                                     Configuration.mainViewsFilter
                                   : defaultMainViewFilter.length > 0 ?
                                         defaultMainViewFilter.split(',')
                                       : [Configuration.defaultMainView]
        property int currentIndex: 0
    }

    ListModel {
        id: mainMenuBaseModel
        ListElement { name: "things"; source: "ThingsView"; displayName: qsTr("Things"); icon: "things"; minVersion: "0.0" }
        ListElement { name: "favorites"; source: "FavoritesView"; displayName: qsTr("Favorites"); icon: "starred"; minVersion: "2.0" }
        ListElement { name: "groups"; source: "GroupsView"; displayName: qsTr("Groups"); icon: "groups"; minVersion: "2.0" }
        ListElement { name: "scenes"; source: "ScenesView"; displayName: qsTr("Scenes"); icon: "slideshow"; minVersion: "2.0" }
        ListElement { name: "garages"; source: "GaragesView"; displayName: qsTr("Garages"); icon: "garage/garage-100"; minVersion: "2.0" }
        ListElement { name: "energy"; source: "EnergyView"; displayName: qsTr("Energy"); icon: "smartmeter"; minVersion: "2.0" }
        ListElement { name: "media"; source: "MediaView"; displayName: qsTr("Media"); icon: "media"; minVersion: "2.0" }
        ListElement { name: "dashboard"; source: "DashboardView"; displayName: qsTr("Dashboard"); icon: "dashboard"; minVersion: "5.5" }
        ListElement { name: "airconditioning"; source: "AirConditioningView"; displayName: qsTr("AC"); icon: "sensors"; minVersion: "6.2" }
    }

    ListModel {
        id: mainMenuModel
        ListElement { name: "dummy"; source: "Dummy"; displayName: ""; icon: "" }

        Component.onCompleted: {
            var configList = {}
            var newList = {}
            var newItems = 0

            // Add extra views first to make them appear first in the list unless the config says otherwise
            if (Configuration.hasOwnProperty("additionalMainViews")) {
                for (var i = 0; i < Configuration.additionalMainViews.count; i++) {
                    var item = Configuration.additionalMainViews.get(i);
                    var idx = mainViewSettings.sortOrder.indexOf(item.name);
                    if (idx === -1) {
                        newList[newItems++] = item;
                    } else {
                        configList[idx] = item;
                    }
                }
            }


            for (var i = 0; i < mainMenuBaseModel.count; i++) {
                var item = mainMenuBaseModel.get(i);
                if (!engine.jsonRpcClient.ensureServerVersion(item.minVersion)) {
                    console.log("Skipping main view", item.name, "as the minimum required server version isn't met:", engine.jsonRpcClient.jsonRpcVersion, "<", item.minVersion)
                    continue;
                }

                var idx = mainViewSettings.sortOrder.indexOf(item.name);
                if (idx === -1) {
                    newList[newItems++] = item;
                } else {
                    configList[idx] = item;
                }
            }
            clear();

            var brandingFilter = Configuration.hasOwnProperty("mainViewsFilter") ? Configuration.mainViewsFilter : []

            for (idx in configList) {
                item = configList[idx];
                if (brandingFilter.length === 0 || brandingFilter.indexOf(item.name) >= 0) {
                    mainMenuModel.append(item)
                }
            }
            for (idx  in newList) {
                item = newList[idx];
                if (brandingFilter.length === 0 || brandingFilter.indexOf(item.name) >= 0) {
                    mainMenuModel.append(item)
                }
            }

            swipeView.currentIndex = mainViewSettings.currentIndex
            mainViewSettings.currentIndex = Qt.binding(function() { return swipeView.currentIndex; })
        }
    }

    SortFilterProxyModel {
        id: filteredContentModel
        sourceModel: mainMenuModel
        filterList: mainViewSettings.filterList
        filterRoleName: "name"
    }


    Item {
        id: contentContainer
        anchors.fill: parent
        clip: true

        property int headerSize: 48
        property int footerSize: app.landscape ? 48 : 64

        readonly property int scrollOffset: swipeView.currentItem ? swipeView.currentItem.item.contentY : 0
        readonly property int headerBlurSize: Math.min(headerSize, scrollOffset * 2)

        Background {
            anchors.fill: parent
        }

        SwipeView {
            id: swipeView
            anchors.fill: parent
            opacity: d.configOverlay === null ? 1 : 0
            visible: !engine.thingManager.fetchingData
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            Repeater {
                id: mainViewsRepeater
                model: d.configOverlay != null ? null : filteredContentModel

                delegate: Loader {
                    id: mainViewLoader
                    width: swipeView.width
                    height: swipeView.height
                    clip: true
                    source: "mainviews/" + model.source + ".qml"
                    visible: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem

                    Binding {
                        target: mainViewLoader.item
                        property: "isCurrentItem"
                        value: swipeView.currentIndex == index
                    }

                    Binding {
                        target: mainViewLoader.item
                        property: "bottomMargin"
                        value: footer.visible ? contentContainer.footerSize : 0
                    }

                    Image {
                        source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
                        anchors {
                            top: parent.top;
                            topMargin: -contentContainer.scrollOffset + (contentContainer.headerSize - height) / 2
                            horizontalCenter: parent.horizontalCenter;
                        }
                        fillMode: Image.PreserveAspectFit
                        height: 28
                        sourceSize.height: height
                        antialiasing: true
                        z: 2
                    }
                }
            }
        }


        ColumnLayout {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: Style.margins }
            spacing: Style.margins
            visible: engine.thingManager.fetchingData
            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: parent.visible
            }
            Label {
                text: qsTr("Loading data...")
                font: Style.bigFont
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    ShaderEffectSource {
        id: headerBlurSource
        width: contentContainer.width
        height: d.configOverlay ? contentContainer.headerSize : contentContainer.headerBlurSize
        sourceItem: d.blurEnabled ? contentContainer : null
        sourceRect: Qt.rect(0, 0, contentContainer.width, d.configOverlay ? contentContainer.headerSize : contentContainer.headerBlurSize)
        visible: false
    }

    FastBlur {
        anchors {
            left: parent.left;
            top: parent.top;
            right: parent.right;
        }
        height: d.configOverlay ? contentContainer.headerSize : contentContainer.headerBlurSize
        radius: 40
        transparentBorder: true
        source: d.blurEnabled ? headerBlurSource : null
        visible: d.blurEnabled
    }

    Rectangle {
        id: headerOpacityMask
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        height: d.configOverlay ? contentContainer.headerSize : contentContainer.headerBlurSize

        gradient: Gradient {
            GradientStop { position: 0.1; color: Style.backgroundColor }
            GradientStop { position: 0.6; color: Qt.rgba(Style.backgroundColor.r, Style.backgroundColor.g, Style.backgroundColor.b, 0.3) }
            GradientStop { position: 1; color: "transparent" }
        }
    }

    ShaderEffectSource {
        id: footerBlurSource
        width: contentContainer.width
        height: contentContainer.footerSize
        sourceItem: d.blurEnabled ? contentContainer : null
        sourceRect: Qt.rect(0, contentContainer.height - height, contentContainer.width, contentContainer.footerSize)
        visible: false
        enabled: d.blurEnabled && footer.shown
    }

    FastBlur {
        anchors {
            left: parent.left;
            bottom: parent.bottom;
            right: parent.right;
        }
        height: contentContainer.footerSize
        radius: 40
        transparentBorder: false
        source: d.blurEnabled ? footerBlurSource : null
        visible: d.blurEnabled && footer.shown
    }

    Rectangle {
        id: footer
        readonly property bool shown: tabsRepeater.count > 1 || d.configOverlay
        visible: shown
        anchors {
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }
        height:  contentContainer.footerSize
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}

//        color: "transparent"

        gradient: Gradient {
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.4; color: Qt.rgba(Style.backgroundColor.r, Style.backgroundColor.g, Style.backgroundColor.b, 0.7) }
            GradientStop { position: 1; color: Style.backgroundColor }
        }

        RowLayout {
            id: tabsLayout
            anchors.fill: parent
            spacing: 0

            opacity: d.configOverlay ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            Repeater {
                id: tabsRepeater
                model: d.configOverlay != null ? null : filteredContentModel
//                model: filteredContentModel
                delegate: MainPageTabButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    alignment: app.landscape ? Qt.Horizontal : Qt.Vertical
                    checked: index === swipeView.currentIndex
//                    anchors.verticalCenter: parent.verticalCenter
                    text: model.displayName
                    iconSource: "../images/" + model.icon + ".svg"

                    onClicked: swipeView.currentIndex = index
                    onPressAndHold: {
                        root.configureViews();
                    }
                }
            }
        }


        MainPageTabButton {
            anchors.fill: parent
            alignment: app.landscape ? Qt.Horizontal : Qt.Vertical
            text: d.configOverlay ? qsTr("Done") : qsTr("Configure")
            iconSource: "../images/configure.svg"

            opacity: d.configOverlay ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            visible: opacity > 0

            checked: true

            onClicked: {
                if (d.configOverlay) {
                    d.configOverlay.destroy()
                } else {
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                    d.configOverlay = configComponent.createObject(contentContainer)
                }
            }
        }
    }

    Component {
        id: configComponent
        Background {
            id: configOverlay
            width: contentContainer.width
            height: contentContainer.height

            ListView {
                id: configListView
                anchors.fill: parent
                model: mainMenuModel
                topMargin: contentContainer.headerSize
                bottomMargin: contentContainer.footerSize

                property bool dragging: draggingIndex >= 0
                property int draggingIndex : -1

                moveDisplaced: Transition { NumberAnimation { properties: "y" } }

                delegate: NymeaItemDelegate {
                    id: viewConfigDelegate
                    width: parent.width
                    text: model.displayName
                    iconName: Qt.resolvedUrl("images/" + model.icon + ".svg")
                    progressive: false
                    checked: mainViewSettings.filterList.indexOf(model.name) >= 0
                    visible: index !== configListView.draggingIndex
                    additionalItem: CheckBox {
                        checked: viewConfigDelegate.checked
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            var newList = []
                            for (var i = 0; i < mainMenuModel.count; i++) {
                                var entry = mainMenuModel.get(i).name;
                                if (entry === model.name) {
                                    if (!isEnabled) {
                                        newList.push(model.name)
                                    }
                                } else {
                                    if (mainViewSettings.filterList.indexOf(entry) >= 0) {
                                        newList.push(entry)
                                    }
                                }
                            }
                            if (newList.length === 0) {
                                newList.push(Configuration.defaultMainView)
                            }

                            mainViewSettings.filterList = newList
                        }
                    }
                }

                MouseArea {
                    id: dndArea
                    anchors.fill: parent
                    preventStealing: configListView.dragging
                    property int dragOffset: 0

                    onPressAndHold: {
                        mouse.accepted = true
                        var mouseYInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).y;
                        configListView.draggingIndex = configListView.indexAt(mouseX, mouseYInListView)
                        var item = mainMenuModel.get(configListView.draggingIndex)
                        print("draggingIndex", configListView.draggingIndex)
                        dndItem.text = item.displayName
                        dndItem.iconName = item.icon
                        var visualItem = configListView.itemAt(mouseX, mouseYInListView)
                        dndItem.checked = visualItem.checked
                        dndArea.dragOffset = configListView.mapToItem(visualItem, mouseX, mouseY).y
                        PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
                    }
                    onMouseYChanged: {
                        if (configListView.dragging) {
                            var mouseYInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).y;
                            var indexUnderMouse = configListView.indexAt(mouseX, mouseYInListView - dndArea.dragOffset / 2)
                            if (indexUnderMouse < 0) {
                                return;
                            }

                            indexUnderMouse = Math.min(Math.max(0, indexUnderMouse), configListView.count - 1)
                            if (configListView.draggingIndex !== indexUnderMouse) {
                                print("moving to", indexUnderMouse)
                                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                                mainMenuModel.move(configListView.draggingIndex, indexUnderMouse, 1)
                                configListView.draggingIndex = indexUnderMouse;
                            }
                        }
                    }
                    onReleased: {
                        print("released!")
                        var mouseYInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).y;
                        var clickedIndex = configListView.indexAt(mouseX, mouseYInListView)
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
                                newList.push(Configuration.defaultMainView)
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
//                    Timer {
//                        id: scroller
//                        interval: 2
//                        repeat: true
//                        running: direction != 0
//                        property int direction: {
//                            if (!configListView.dragging) {
//                                return 0;
//                            }
//                            return dndArea.mouseY < 50 ? -2 : dndArea.mouseY > dndArea.height - 50 ? 2 : 0
//                        }
//                        onTriggered: {
//                            configListView.contentY = Math.min(Math.max(0, configListView.contentY + direction), configListView.contentHeight - configListView.height)
//                        }
//                    }
                }

                NymeaItemDelegate {
                    id: dndItem
                    visible: configListView.dragging
                    y: dndArea.mouseY - dndArea.dragOffset
                    width: configListView.width
                    progressive: false
                    additionalItem: CheckBox {
                        checked: dndItem.checked
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }
            }

//            NumberAnimation {
//                target: configOverlay
//                property: "scale"
//                duration: 200
//                easing.type: Easing.InOutQuad
//                from: 2
//                to: 1
//                running: true
//            }
//            NumberAnimation {
//                target: configOverlay
//                property: "opacity"
//                duration: 200
//                easing.type: Easing.InOutQuad
//                from: 0
//                to: 1
//                running: true
//            }

//            ListView {
//                id: configListView
//                model: mainMenuModel
//                width: parent.width
//                height: parent.height / 3
//                anchors.centerIn: parent
//                orientation: ListView.Horizontal
//                moveDisplaced: Transition {
//                    NumberAnimation { properties: "x,y"; duration: 200 }
//                }

//                property int delegateWidth: width / 3

//                property bool dragging: draggingIndex >= 0
//                property int draggingIndex : -1

//                MouseArea {
//                    id: dndArea
//                    anchors.fill: parent
//                    preventStealing: configListView.dragging
//                    property int dragOffset: 0

//                    onPressAndHold: {
//                        mouse.accepted = true
//                        var mouseXInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).x;
//                        configListView.draggingIndex = configListView.indexAt(mouseXInListView, mouseY)
//                        var item = mainMenuModel.get(configListView.draggingIndex)
//                        dndItem.displayName = item.displayName
//                        dndItem.icon = item.icon
//                        var visualItem = configListView.itemAt(mouseXInListView, mouseY)
//                        dndItem.isEnabled = visualItem.isEnabled
//                        dndArea.dragOffset = configListView.mapToItem(visualItem, mouseX, mouseY).x
//                        PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
//                    }
//                    onMouseYChanged: {
//                        if (configListView.dragging) {
//                            var mouseXInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).x;
//                            var indexUnderMouse = configListView.indexAt(mouseXInListView - dndArea.dragOffset / 2, mouseY)
//                            indexUnderMouse = Math.min(Math.max(0, indexUnderMouse), configListView.count - 1)
//                            if (configListView.draggingIndex !== indexUnderMouse) {
//                                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
//                                mainMenuModel.move(configListView.draggingIndex, indexUnderMouse, 1)
//                                configListView.draggingIndex = indexUnderMouse;
//                            }
//                        }
//                    }
//                    onReleased: {
//                        print("released!")
//                        var mouseXInListView = configListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).x;
//                        var clickedIndex = configListView.indexAt(mouseXInListView, mouseY)
//                        var item = mainMenuModel.get(clickedIndex)
//                        var isEnabled = mainViewSettings.filterList.indexOf(item.name) >= 0;
//                        if (!configListView.dragging) {
//                            var newList = []
//                            for (var i = 0; i < mainMenuModel.count; i++) {
//                                var entry = mainMenuModel.get(i).name;
//                                if (entry === item.name) {
//                                    if (!isEnabled) {
//                                        newList.push(item.name)
//                                    }
//                                } else {
//                                    if (mainViewSettings.filterList.indexOf(entry) >= 0) {
//                                        newList.push(entry)
//                                    }
//                                }
//                            }
//                            if (newList.length === 0) {
//                                newList.push(Configuration.defaultMainView)
//                            }

//                            mainViewSettings.filterList = newList
//                        }
//                        configListView.draggingIndex = -1;

//                        var newSortOrder = []
//                        for (var i = 0; i < mainMenuModel.count; i++) {
//                            newSortOrder.push(mainMenuModel.get(i).name)
//                        }
//                        mainViewSettings.sortOrder = newSortOrder;
//                    }
//                    Timer {
//                        id: scroller
//                        interval: 2
//                        repeat: true
//                        running: direction != 0
//                        property int direction: {
//                            if (!configListView.dragging) {
//                                return 0;
//                            }
//                            return dndArea.mouseX < 50 ? -2 : dndArea.mouseX > dndArea.width - 50 ? 2 : 0
//                        }
//                        onTriggered: {
//                            configListView.contentX = Math.min(Math.max(0, configListView.contentX + direction), configListView.contentWidth - configListView.width)
//                        }
//                    }
//                }

//                delegate: BigTile {
//                    id: configDelegate
//                    width: configListView.delegateWidth
//                    height: configListView.height
//                    property bool isEnabled: mainViewSettings.filterList.indexOf(model.name) >= 0
//                    visible: configListView.draggingIndex !== index

//                    leftPadding: 0
//                    rightPadding: 0
//                    topPadding: 0
//                    bottomPadding: 0

//                    header: RowLayout {
//                        id: headerRow
//                        width: parent.width
//                        Label {
//                            text: model.displayName
//                            Layout.fillWidth: true
//                            elide: Text.ElideRight
//                        }
//                    }

//                    contentItem: Item {
//                        Layout.fillWidth: true
//                        implicitHeight: configListView.height - headerRow.height - Style.margins * 2

//                        ColorIcon {
//                            anchors.centerIn: parent
//                            width: Math.min(parent.width, parent.height) * .6
//                            height: width
//                            name: Qt.resolvedUrl("images/" + model.icon + ".svg")
//                            color: configDelegate.isEnabled ? Style.accentColor : Style.iconColor
//                        }
//                    }
//                }
//                Item {
//                    id: dndItem
//                    width: configListView.delegateWidth
//                    height: configListView.height
//                    property bool isEnabled: false
//                    property string displayName: ""
//                    property string icon: "things"
//                    visible: configListView.dragging
//                    x: dndArea.mouseX - dndArea.dragOffset
//                    onVisibleChanged: {
//                        if (visible) {
//                            dragStartAnimation.start();
//                        }
//                    }

//                    NumberAnimation {
//                        id: dragStartAnimation
//                        target: dndItem
//                        property: "scale"
//                        from: 1
//                        to: 0.95
//                        duration: 200
//                    }

//                    BigTile {
//                        id: dndTile
//                        anchors.fill: parent
//                        //                        anchors.margins: app.margins / 2
//                        Material.elevation: 2

//                        leftPadding: 0
//                        rightPadding: 0
//                        topPadding: 0
//                        bottomPadding: 0

//                        header: RowLayout {
//                            Label {
//                                text: dndItem.displayName
//                            }
//                        }

//                        contentItem: Item {
//                            Layout.fillWidth: true
//                            implicitHeight: configListView.height - header.height

//                            ColorIcon {
//                                anchors.centerIn: parent
//                                width: Math.min(parent.width, parent.height) * .6
//                                height: width
//                                name: Qt.resolvedUrl("images/" + dndItem.icon + ".svg")
//                                color: dndItem.isEnabled ? Style.accentColor : Style.iconColor
//                            }
//                        }
//                    }
//                }
//            }
        }
    }

    Component {
        id: connectionDialogComponent
        NymeaDialog {
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
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
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
