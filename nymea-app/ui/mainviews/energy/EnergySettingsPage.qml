import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

SettingsPageBase {
    id: root
    title: qsTr("Energy settings")

    property EnergyManager energyManager: null

    property ThingsProxy allConsumers: ThingsProxy {
        engine: _engine
        shownInterfaces: ["smartmeterconsumer", "energymeter"]
        hiddenThingIds: [energyManager.rootMeterId]
    }


    SettingsPageSectionHeader {
        text: qsTr("General")
        visible: rootMeterProxy.count > 1
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        text: qsTr("Multiple energy meters are installed in the system. Please select the one you'd like to use as the root meter. That is, the one measuring the entire household.")
        visible: rootMeterProxy.count > 1
    }

    RowLayout {
        Layout.fillWidth: true
        visible: rootMeterProxy.count > 1
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins

        Label {
            text: qsTr("Root meter")
        }
        ComboBox {
            Layout.fillWidth: true
            model: ThingsProxy {
                id: rootMeterProxy
                engine: _engine
                shownInterfaces: ["energymeter"]
            }

            textRole: "name"
            currentIndex: rootMeterProxy.indexOf(rootMeterProxy.getThing(energyManager.rootMeterId))
            Component.onCompleted: print("root meter id:", energyManager.rootMeterId)
            onActivated: {
                energyManager.setRootMeterId(rootMeterProxy.get(index).id)
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Consumers")
        visible: root.allConsumers.count > 0
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        text: qsTr("Uncheck individual consumers to hide them from the energy charts.")
        visible: root.allConsumers.count > 0
    }

    Repeater {
        model: root.allConsumers
        delegate: CheckDelegate {
            Layout.fillWidth: true
            text: model.name
            checked: !tagWatcher.tag
            onToggled: {
                if (checked) {
                    engine.tagsManager.untagThing(model.id, "hiddenInEnergyView")
                } else {
                    engine.tagsManager.tagThing(model.id, "hiddenInEnergyView", "1")
                }
            }

            TagWatcher {
                id: tagWatcher
                tags: engine.tagsManager.tags
                thingId: model.id
                tagId: "hiddenInEnergyView"
            }
        }
    }
}
