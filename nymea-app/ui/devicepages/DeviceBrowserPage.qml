import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Browse %1").arg(root.device.name)
        onBackPressed: pageStack.pop()
    }
    property Device device: null
    property string nodeId: ""

    Component.onCompleted: {
        d.model = engine.deviceManager.browseDevice(root.device.id, root.nodeId);
    }

    function executeBrowserItem(itemId) {
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.deviceManager.executeBrowserItem(root.device.id, itemId)
    }
    function executeBrowserItemAction(itemId, actionTypeId, params) {
        d.pendingItemId = itemId
        d.pendingBrowserItemId = engine.deviceManager.executeBrowserItemAction(root.device.id, itemId, actionTypeId, params)
    }

    QtObject {
        id: d
        property BrowserItems model: null
        property int pendingBrowserItemId: -1
        property string pendingItemId: ""
    }

    Connections {
        target: engine.deviceManager
        onExecuteBrowserItemReply: actionExecuted(params)
        onExecuteBrowserItemActionReply: actionExecuted(params)
    }
    function actionExecuted(params) {
        print("Execute Action reply:", params, params.id, params["id"], d.pendingBrowserItemId)
        if (params.id === d.pendingBrowserItemId) {
            d.pendingBrowserItemId = -1;
            d.pendingItemId = ""
            print("yep finished")
            if (params.status !== "success") {
                header.showInfo(params.error, true);
            } else  if (params.params.deviceError !== "DeviceErrorNoError") {
                header.showInfo(qsTr("Error: %1").arg(params.params.deviceError), true)
            }
        }
        engine.deviceManager.refreshBrowserItems(d.model)
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: d.model
        ScrollBar.vertical: ScrollBar {}

        delegate: NymeaListItemDelegate {
            width: parent.width
            text: model.displayName
            progressive: model.browsable
            subText: model.description
            prominentSubText: false
            iconName: model.thumbnail
            fallbackIcon: "../images/browser/" + model.icon + ".svg"
            enabled: !model.disabled
            busy: d.pendingItemId === model.id

            onClicked: {
                print("clicked:", model.id)
                if (model.executable) {
                    root.executeBrowserItem(model.id)
                } else if (model.browsable) {
                    pageStack.push(Qt.resolvedUrl("DeviceBrowserPage.qml"), {device: root.device, nodeId: model.id})
                }
            }


            onPressAndHold: {
                print("show actions:", model.actionTypeIds)
                var actionDialogComponent = Qt.createComponent(Qt.resolvedUrl("../components/BrowserContextMenu.qml"));
                var popup = actionDialogComponent.createObject(this, {device: root.device, title: model.displayName, itemId: model.id, actionTypeIds: model.actionTypeIds});
                popup.activated.connect(function(actionTypeId, params) {
                    root.executeBrowserItemAction(model.id, actionTypeId, params)
                })
                popup.open()
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: listView.model.busy
            visible: running
        }
    }

}
