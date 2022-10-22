import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0

WizardPageBase {
    id: root
    property AirConditioningManager acManager: null
    title: qsTr("New zone")

    showBackButton: true
    showExtraButton: false


    QtObject {
        id: d
        property var thermostats: []
        property var windowSensors: []
        property var indoorSensors: []
        property var outdoorSensors: []
    }

    onBack: pageStack.pop();

    onNext: {
        acManager.addZone(nameTextField.text, d.thermostats, d.windowSensors, d.indoorSensors, d.outdoorSensors)
        pageStack.pop();
    }

    ThingsProxy {
        id: thermostatsProxy
        engine: _engine
        shownInterfaces: ["thermostat"]
    }
    ThingsProxy {
        id: windowSensorsProxy
        engine: _engine
        shownInterfaces: ["closablesensors"]
    }

    ThingsProxy {
        id: sensorsProxy
        engine: _engine
        shownInterfaces: ["temperaturesensor", "humiditysensor", "vocsensor", "pm25sensor"]
        hiddenInterfaces: ["thermostat"]
    }

    content: Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.visibleContentHeight

        Flickable {
            id: flickable
            anchors.fill: parent
            contentHeight: contentColumn.height


            ColumnLayout {
                id: contentColumn
                width: flickable.width

                SettingsPageSectionHeader {
                    text: qsTr("Zone name")
                }

                NymeaTextField {
                    id: nameTextField
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                }


                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    text: qsTr("Select the thermostats that should be part of this zone.")
                    wrapMode: Text.WordWrap
                }

                Repeater {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: thermostatsProxy

                    delegate: CheckDelegate {
                        Layout.fillWidth: true
                        text: model.name
                        checked: d.thermostats.indexOf(model.id) >= 0
                        onClicked: {
                            var tmp = d.thermostats
                            if (checked) {
                                tmp.push(model.id)
                            } else {
                                var idx = tmp.indexOf(model.id);
                                tmp.splice(idx, 1)
                            }
                            d.thermostats = tmp;
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    text: qsTr("Select the sensors that should be part of this zone.")
                    wrapMode: Text.WordWrap
                }

                Repeater {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: sensorsProxy

                    delegate: CheckDelegate {
                        Layout.fillWidth: true
                        text: model.name
                        checked: d.things.indexOf(model.id) >= 0
                        onClicked: {
                            var tmp = d.sensors
                            if (checked) {
                                tmp.push(model.id)
                            } else {
                                var idx = tmp.indexOf(model.id);
                                tmp.splice(idx, 1)
                            }
                            d.sensors = tmp;
                        }
                    }
                }
            }
        }

    }

}
