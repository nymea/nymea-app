import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    ListView {
        anchors { fill: parent }
        model: ListModel {
            Component.onCompleted: {
                if (root.deviceClass.interfaces.indexOf("extendedsmartmeterproducer") >= 0
                        || root.deviceClass.interfaces.indexOf("extendedsmartmeterconsumer") >= 0) {
                    append( {interface: "extendedsmartmeterproducer", stateTypeName: "currentPower" })
                }
                if (root.deviceClass.interfaces.indexOf("smartmeterproducer") >= 0) {
                    append( {interface: "smartmeterproducer", stateTypeName: "totalEnergyProduced" })
                }
                if (root.deviceClass.interfaces.indexOf("smartmeterconsumer") >= 0) {
                    append( {interface: "smartmeterconsumer", stateTypeName: "totalEnergyConsumed" })
                }
                print("shown graphs are", count)
            }
        }
        delegate: ColumnLayout {
            width: parent.width
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.topMargin: app.margins; Layout.rightMargin: app.rightMargins;
                text: root.deviceClass.stateTypes.findByName(model.stateTypeName).displayName
            }
            GenericTypeGraph {
                Layout.fillWidth: true
                device: root.device
                stateType: root.deviceClass.stateTypes.findByName(model.stateTypeName)
                color: app.interfaceToColor(model.interface)
                iconSource: app.interfaceToIcon(model.interface)
                roundTo: 5
            }
        }
    }
}
