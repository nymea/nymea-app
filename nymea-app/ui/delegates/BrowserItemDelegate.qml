import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

NymeaListItemDelegate {
    id: root
    width: parent.width
    text: model.displayName
    progressive: model.browsable
    subText: model.description
    prominentSubText: false
    iconName: model.thumbnail
    fallbackIcon: "../images/browser/" + model.icon + ".svg"
    enabled: model.browsable || model.executable
    secondaryIconName: model.actionTypeIds.length > 0 ? "../images/navigation-menu.svg" : ""
    secondaryIconClickable: true

    property Device device: null

    onPressAndHold: openContextMenu()
    onSecondaryIconClicked: openContextMenu()

    signal contextMenuActionTriggered(var actionTypeId, var params)

    function openContextMenu() {
        if (model.actionTypeIds.length === 0) {
            return;
        }

        var actionDialogComponent = Qt.createComponent(Qt.resolvedUrl("../components/BrowserContextMenu.qml"));
        var popup = actionDialogComponent.createObject(root, {device: root.device, title: model.displayName, itemId: model.id, actionTypeIds: model.actionTypeIds});
        popup.activated.connect(function(actionTypeId, params) {
            root.contextMenuActionTriggered(actionTypeId, params)
        })
        popup.open()
    }
}
