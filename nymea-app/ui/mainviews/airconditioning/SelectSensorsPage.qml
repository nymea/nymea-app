import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0

Page {
    id: root
    property AirConditioningManager acManager: null
    property ZoneInfo zoneInfo: null

    readonly property Thing thermostat: engine.thingManager.things.getThing(root.zoneInfo.thermostatId)    

    header: NymeaHeader {
        text: root.thermostat.name

        onBackPressed: {
            pageStack.pop()
        }

        HeaderButton {
            imageSource: "tick"
            onClicked: {
                var sensorIds = []
                acManager.setZoneThings(root.zoneInfo.id, d.checkedThings)
            }
        }
    }

    QtObject {
        id: d
        property var checkedThings: root.zoneInfo.thingIds

    }

    Component.onCompleted: print("***** sensors", root.zoneInfo.thingIds, d.checkedThings)

    GroupedListView {
        id: sensorsListView
        anchors.fill: parent

        section.property: "mainInterface"
        model: ThingsProxy {
            id: sensorsProxy
            engine: _engine
            shownInterfaces: ["thermostat", "closablesensor", "temperaturesensor", "humiditysensor", "vocsensor", "pm25sensor"]
//            hiddenInterfaces: ["thermostat"]
            groupByInterface: true
        }
        delegate: CheckDelegate {
            readonly property Thing thing: sensorsProxy.get(index)
            width: parent.width
            text: model.name
            checked: {
                for (var i = 0; i < d.checkedThings.length; i++) {
                    if (d.checkedThings[i] == model.id) { // Intentionally
                        return true;
                    }
                }
                return false;
            }
            onClicked: {
                if (checked) {
                    d.checkedThings.push(model.id)
                } else {
                    d.checkedThings.splice(d.checkedThings.indexOf(model.id.toString()), 1)
                }
            }
        }
    }
}
