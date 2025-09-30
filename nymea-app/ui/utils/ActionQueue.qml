import QtQuick
import Nymea

Item {
    id: root

    property Thing thing: null

    // either or
    property string stateName: ""
    property StateType stateType: null

    readonly property var pendingValue: d.queuedValue || d.pendingValue

    Component.onDestruction: {
        if (d.queuedValue != null) {
            d.pendingCommand = -1;
            sendValue(d.queuedValue);
        }
    }

    function sendValue(value) {
        if (d.pendingCommand != -1) {
            // busy, cache value
            d.queuedValue = value;
            return;
        }
        d.pendingValue = value;
//        print("sending action", value)
        var stateName = root.stateType == null ? root.stateName : root.stateType.name
        d.pendingCommand = root.thing.executeAction(stateName,
                                          [{
                                               paramName: stateName,
                                               value: value
                                           }])
    }

    QtObject {
        id: d
        property int pendingCommand: -1
        property var pendingValue: null
        property var queuedValue: null
    }

    Connections {
        target: root.thing
        onExecuteActionReply: {
            if (d.pendingCommand == commandId) {
//                print("command finished")
                d.pendingCommand = -1;
                if (d.queuedValue != null) {
                    root.sendValue(d.queuedValue)
                    d.queuedValue = null
                } else {
                    d.pendingValue = null
                }
            }
        }
    }
}
