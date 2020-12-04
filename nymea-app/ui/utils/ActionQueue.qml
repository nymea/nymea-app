import QtQuick 2.9
import Nymea 1.0

Item {
    id: root

    property Thing thing: null
    property StateType stateType: null

    readonly property var pendingValue: d.queuedValue || d.pendingValue

    function sendValue(value) {
        if (d.pendingCommand != -1) {
            // busy, cache value
            d.queuedValue = value;
            return;
        }
        d.pendingValue = value;
        d.pendingCommand = engine.thingManager.executeAction(root.thing.id,
                                          root.stateType.id,
                                          [{
                                               paramTypeId: root.stateType.id,
                                               value: value
                                           }])
        d.queuedValue = null
    }

    QtObject {
        id: d
        property int pendingCommand: -1
        property var pendingValue: null
        property var queuedValue: null
    }

    Connections {
        target: engine.thingManager
        onExecuteActionReply: {
            if (d.pendingCommand == commandId) {
                d.pendingCommand = -1;
                if (d.queuedValue != null) {
                    root.sendValue(d.queuedValue)
                } else {
                    d.pendingValue = null
                }
            }
        }
    }
}
