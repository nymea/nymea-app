import QtQuick 2.5


Item {
    id: root
    property var actionType: null
    property var actionState: null

    signal executeAction(var params)
}
