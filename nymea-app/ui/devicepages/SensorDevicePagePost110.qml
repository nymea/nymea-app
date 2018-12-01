import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

ListView {
    anchors { fill: parent }
    model: ListModel {
        Component.onCompleted: {
            var supportedInterfaces = ["temperaturesensor", "humiditysensor", "pressuresensor", "moisturesensor", "lightsensor", "conductivitysensor", "noisesensor", "co2sensor"]
            for (var i = 0; i < supportedInterfaces.length; i++) {
                print("checking", root.deviceClass.name, root.deviceClass.interfaces)
                if (root.deviceClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
                    append({name: supportedInterfaces[i]});
                }
            }
        }
    }
    delegate: GenericTypeGraph {
        width: parent.width
        device: root.device
        stateType: root.deviceClass.stateTypes.findByName(stateTypeName)
        color: app.interfaceToColor(modelData)
        iconSource: app.interfaceToIcon(modelData)

        implicitHeight: width * .6
        property string stateTypeName: {
            switch (modelData) {
            case "lightsensor":
                return "lightIntensity";
            default:
                return modelData.replace("sensor", "");
            }
        }
    }
}
