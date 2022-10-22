import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import Nymea.AirConditioning 1.0
import "qrc:/ui/components"
import "qrc:/ui/delegates"

SettingsPageBase {
    id: zoneThingsPage
    title: qsTr("Things in zone %1").arg(zone.name)

    property AirConditioningManager acManager: null
    property ZoneInfo zone: null

    ZoneInfoWrapper {
        id: zoneWrapper
        zone: zoneThingsPage.zone
    }

    busy: d.pendingCommandId != -1
    QtObject {
        id: d
        property int pendingCommandId: -1
    }

    Connections {
        target: acManager
        onSetZoneNameReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Thermostats")
    }

    Repeater {
        model: zoneWrapper.thermostats
        delegate: ThingDelegate {
            Layout.fillWidth: true
            thing: zoneWrapper.thermostats.get(index)
            progressive: false
            canDelete: true
            onDeleteClicked: {
                acManager.removeZoneThermostat(zone.id, thing.id)
            }
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: qsTr("Add thermostat")
        onClicked: {
            var page = pageStack.push(selectThingComponent, {
                                          acManager: acManager,
                                          zone: zone,
                                          interfaces: ["thermostat"],
                                          hiddenThingIds: zone.thermostats,
                                          title: qsTr("Add thermostats"),
                                          placeHolderTitle: qsTr("No thermostats installed"),
                                          placeHolderText: qsTr("Before a thermostat can be assigned to this zone, it needs to be connected to nymea."),
                                          placeHolderButtonText: qsTr("Setup thermostats"),
                                          placeHolderFilterInterface: "thermostat"
                                      })
            page.selected.connect(function(thingId) {
                acManager.addZoneThermostat(zone.id, thingId)
            })
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Window sensors")
    }

    Repeater {
        model: zoneWrapper.windowSensors
        delegate: ThingDelegate {
            Layout.fillWidth: true
            thing: zoneWrapper.windowSensors.get(index)
            progressive: false
            canDelete: true
            onDeleteClicked: {
                acManager.removeZoneWindowSensor(zone.id, thing.id)
            }
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: qsTr("Add window sensor")
        onClicked: {
            var page = pageStack.push(selectThingComponent, {
                                          acManager: acManager,
                                          zone: zone,
                                          interfaces: ["closablesensor"],
                                          hiddenThingIds: zone.windowSensors,
                                          title: qsTr("Add window sensors"),
                                          placeHolderTitle: qsTr("No window sensors installed"),
                                          placeHolderText: qsTr("Before a window sensor can be assigned to this zone, it needs to be connected to nymea."),
                                          placeHolderButtonText: qsTr("Setup window sensor"),
                                          placeHolderFilterInterface: "closablesensor"
                                      })
            page.selected.connect(function(thingId) {
                acManager.addZoneWindowSensor(zone.id, thingId)
            })
        }
    }
    SettingsPageSectionHeader {
        text: qsTr("Indoor sensors")
    }

    Repeater {
        model: zoneWrapper.indoorSensors
        delegate: ThingDelegate {
            Layout.fillWidth: true
            thing: zoneWrapper.indoorSensors.get(index)
            progressive: false
            canDelete: true
            onDeleteClicked: {
                acManager.removeZoneIndoorSensor(zone.id, thing.id)
            }
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: qsTr("Add indoor sensor")
        onClicked: {
            var page = pageStack.push(selectThingComponent, {
                                          acManager: acManager,
                                          zone: zone,
                                          interfaces: ["temperaturesensor", "humiditysensor", "vocsensor", "pm25sensor"],
                                          hiddenThingIds: zone.indoorSensors,
                                          title: qsTr("Add indoor sensors"),
                                          placeHolderTitle: qsTr("No sensors installed"),
                                          placeHolderText: qsTr("Before a sensor be assigned to this zone, it needs to be connected to nymea."),
                                          placeHolderButtonText: qsTr("Setup sensors"),
                                          placeHolderFilterInterface: "sensor"
                                      })
            page.selected.connect(function(thingId) {
                acManager.addZoneIndoorSensor(zone.id, thingId)
            })
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Outdoor sensors")
    }

    Repeater {
        model: zoneWrapper.outdoorSensors
        delegate: ThingDelegate {
            Layout.fillWidth: true
            thing: zoneWrapper.outdoorSensors.get(index)
            progressive: false
            canDelete: true
            onDeleteClicked: {
                acManager.removeZoneOutdoorSensor(zone.id, thing.id)
            }
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: qsTr("Add outdoor sensor")
        onClicked: {
            var page = pageStack.push(selectThingComponent, {
                                          acManager: acManager,
                                          zone: zone,
                                          interfaces: ["temperaturesensor", "humiditysensor", "vocsensor", "pm25sensor"],
                                          hiddenThingIds: zone.outdoorSensors,
                                          title: qsTr("Select outdoor sensors"),
                                          placeHolderTitle: qsTr("No sensors installed"),
                                          placeHolderText: qsTr("Before a sensor be assigned to this zone, it needs to be connected to nymea."),
                                          placeHolderButtonText: qsTr("Setup sensors"),
                                          placeHolderFilterInterface: "sensor"
                                      })
            page.selected.connect(function(thingId) {
                acManager.addZoneOutdoorSensor(zone.id, thingId)
            })
        }
    }

    Component {
        id: selectThingComponent
        SettingsPageBase {
            id: selectThingPage
            busy: d.pendingCommandId != -1

            property AirConditioningManager acManager: null
            property ZoneInfo zone: null
            property var interfaces: []
            property var hiddenThingIds: []

            property alias placeHolderTitle: placeHolder.title
            property alias placeHolderText: placeHolder.text
            property alias placeHolderButtonText: placeHolder.buttonText
            property string placeHolderFilterInterface: ""

            signal selected(var thingId)

            QtObject {
                id: d
                property int pendingCommandId: -1
            }

            Connections {
                target: acManager
                onSetZoneThingsReply: {
                    if (commandId == d.pendingCommandId) {
                        d.pendingCommandId = -1
                    }

                    pageStack.pop();
                }
            }

            Repeater {

                model: ThingsProxy {
                    id: thingsProxy
                    engine: _engine
                    shownInterfaces: selectThingPage.interfaces
                    hiddenThingIds: selectThingPage.hiddenThingIds
                }

                delegate: ThingDelegate {
                    Layout.fillWidth: true
                    thing: thingsProxy.get(index)
                    progressive: false
                    onClicked: selectThingPage.selected(thing.id)
                }
            }

            Item {
                visible: thingsProxy.count == 0
                width: selectThingPage.width
                height: selectThingPage.height - selectThingPage.header.height

                EmptyViewPlaceholder {
                    id: placeHolder
                    anchors.centerIn: parent
                    width: parent.width - app.margins * 2
                    imageSource: app.interfaceToIcon(selectThingPage.placeHolderFilterInterface)
                    buttonText: qsTr("Add things")
                    onButtonClicked: {
                        pageStack.push("/ui/thingconfiguration/NewThingPage.qml", {filterInterface: selectThingPage.placeHolderFilterInterface})
                    }
                }
            }
        }
    }
}


