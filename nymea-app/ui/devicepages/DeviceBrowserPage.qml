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
                var popup = actionDialogComponent.createObject(this, {title: model.displayName, itemId: model.id, actionTypeIds: model.actionTypeIds});
                popup.open()
//                root.device.deviceClass.browserItemActionTypes.getActionType()
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: listView.model.busy
            visible: running
        }
    }

    Component {
        id: actionDialogComponent
        MeaDialog {
            id: actionDialog

            property string itemId
            property alias actionTypeIds: actionListView.model

            ListView {
                id: actionListView
                Layout.fillWidth: true
                implicitHeight: count * 50
                interactive: contentHeight > height
                clip: true
                delegate: NymeaListItemDelegate {
                    width: parent.width
                    text: actionType.displayName
                    progressive: false
                    property ActionType actionType: root.device.deviceClass.browserItemActionTypes.getActionType(modelData)
                    onClicked: {
                        var params = []
                        root.executeBrowserItemAction(actionDialog.itemId, actionType.id, params)
                        actionDialog.close()
                    }
                }
            }
        }
    }
}
