import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    property Device device: null
    readonly property DeviceClass deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

    property bool showLogsButton: true
    property bool showDetailsButton: true
    property bool showBrowserButton: true
    property bool popStackOnBackButton: true

    default property alias data: contentItem.data

    signal backPressed()

    header: NymeaHeader {
        text: device.name
        onBackPressed: {
            root.backPressed();
            if (root.popStackOnBackButton) {
                pageStack.pop()
            }
        }

        HeaderButton {
            imageSource: "../images/folder-symbolic.svg"
            visible: root.deviceClass.browsable && root.showBrowserButton
            onClicked: {
                pageStack.push(Qt.resolvedUrl("DeviceBrowserPage.qml"), {device: root.device})
            }
        }

        HeaderButton {
            imageSource: "../images/navigation-menu.svg"
            onClicked: thingMenu.open();
        }
    }

    TagsProxyModel {
        id: favoritesProxy
        tags: engine.tagsManager.tags
        filterDeviceId: root.device.id
        filterTagId: "favorites"
    }

    AutoSizeMenu {
        id: thingMenu
        x: parent.width - width

        Component.onCompleted: {
            thingMenu.addItem(menuEntryComponent.createObject(thingMenu, {text: qsTr("Magic"), iconSource: "../images/magic.svg", functionName: "openDeviceMagicPage"}))

            if (root.showDetailsButton) {
                thingMenu.addItem(menuEntryComponent.createObject(thingMenu, {text: qsTr("Thing details"), iconSource: "../images/configure.svg", functionName: "openGenericDevicePage"}))
            }
            if (root.showLogsButton) {
                thingMenu.addItem(menuEntryComponent.createObject(thingMenu, {text: qsTr("Thing logs"), iconSource: "../images/logs.svg", functionName: "openDeviceLogPage"}))
            }

            if (engine.jsonRpcClient.ensureServerVersion(1.6)) {
                thingMenu.addItem(menuEntryComponent.createObject(thingMenu,
                    {
                        text: Qt.binding(function() { return favoritesProxy.count === 0 ? qsTr("Mark as favorite") : qsTr("Remove from favorites")}),
                        iconSource: Qt.binding(function() { return favoritesProxy.count === 0 ? "../images/starred.svg" : "../images/non-starred.svg"}),
                        functionName: "toggleFavorite"
                    }))
            }
        }
        function openDeviceMagicPage() {
            pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device})
        }
        function openGenericDevicePage() {
            pageStack.push(Qt.resolvedUrl("GenericDevicePage.qml"), {device: root.device})
        }
        function toggleFavorite() {
            if (favoritesProxy.count === 0) {
                engine.tagsManager.tagDevice(root.device.id, "favorites", 100000)
            } else {
                engine.tagsManager.untagDevice(root.device.id, "favorites")
            }
        }
        function openDeviceLogPage() {
            pageStack.push(Qt.resolvedUrl("DeviceLogPage.qml"), {device: root.device });
        }

        Component {
            id: menuEntryComponent
            IconMenuItem {
                width: parent.width
                property string functionName: ""
                onTriggered: thingMenu[functionName]()
            }
        }
    }

    Rectangle {
        id: infoPane
        visible: batteryState !== null || (connectedState !== null && connectedState.value === false)
        height: visible ? contentRow.implicitHeight : 0
        anchors { left: parent.left; top: parent.top; right: parent.right }
        property var batteryState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryLevel").id) : null
        property var batteryCriticalState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryCritical").id) : null
//        property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
        property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
        property bool alertState: (connectedState !== null && connectedState.value === false) ||
                                  (batteryCriticalState !== null && batteryCriticalState.value === true)
        color: alertState ? "red" : "transparent"
        z: 1000

        RowLayout {
            id: contentRow
            anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins }
            Item {
                Layout.fillWidth: true
                height: app.iconSize
            }

            Label {
                text: (infoPane.connectedState !== null && infoPane.connectedState.value === false) ?
                          qsTr("Thing is not connected!")
                        : qsTr("Thing runs out of battery!")
                visible: infoPane.alertState
                font.pixelSize: app.smallFont
                color: "white"
            }

            ColorIcon {
                height: app.iconSize / 2
                width: height
                visible: infoPane.connectedState !== null && infoPane.connectedState.value === false
                color: "white"
                name: "../images/dialog-warning-symbolic.svg"
            }

            ColorIcon {
                height: app.iconSize / 2
                width: height * 1.23
                name: infoPane.batteryState !== null ? "../images/battery/battery-" + ("00" + (Math.floor(infoPane.batteryState.value / 10) * 10)).slice(-3) + ".svg" : ""
                visible: infoPane.batteryState !== null
                color: infoPane.alertState ? "white" : keyColor
            }
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.topMargin: infoPane.height
        clip: true
    }
}
