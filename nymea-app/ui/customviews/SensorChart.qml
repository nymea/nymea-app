import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

CustomViewBase {
    id: root
    implicitHeight: width * .6
    property string interfaceName

    readonly property string stateTypeName: {
        switch (interfaceName) {
        case "lightsensor":
            return "lightIntensity";
        default:
            return interfaceName.replace("sensor", "");
        }
    }
    GenericTypeGraph {
        anchors { left: parent.left; top: parent.top; right: parent.right; bottom: parent.bottom }
        device: root.device
        stateType: root.deviceClass.stateTypes.findByName(root.stateTypeName)
        color: app.interfaceToColor(root.interfaceName)
        iconSource: app.interfaceToIcon(root.interfaceName)
    }
}
