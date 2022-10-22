import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import Nymea.AirConditioning 1.0
import "qrc:/ui/components"
import "qrc:/ui/delegates"

SettingsPageBase {
    id: editZonePage

    title: qsTr("Edit %1").arg(zone.name)

    property AirConditioningManager acManager: null
    property ZoneInfo zone: null
    property bool createNew: false

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

        onRemoveZoneReply: {
            if (commandId == d.pendingCommandId) {
                d.pendingCommandId = -1
                pageStack.pop()
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Zone information")
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        spacing: app.margins

        Label {
            text: qsTr("Name")
            Layout.fillWidth: true
        }
        TextField {
            id: nameTextField
            Layout.fillWidth: true
            text: zone.name
        }
        Button {
            text: qsTr("OK")
            visible: nameTextField.displayText !== zone.name
            onClicked: d.pendingCommandId = acManager.setZoneName(zone.id, nameTextField.displayText)
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Assigned things")
        onClicked: pageStack.push(Qt.resolvedUrl("EditZoneThingsPage.qml"), {acManager: acManager, zone: zone})
    }

    SettingsPageSectionHeader {
        text: qsTr("Temperature settings")
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Base temperature")
        subText: Types.toUiValue(editZonePage.zone.standbySetpoint, Types.UnitDegreeCelsius) + Types.toUiUnit(Types.UnitDegreeCelsius)
        onClicked: {
            var popup = selectBaseTempComponent.createObject(app, {zone: zone})
            popup.open()
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Set time schedule")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("TimeSchedulePage.qml"), {acManager: acManager, zone: zone})
        }
    }


//    SettingsPageSectionHeader {
//        text: qsTr("Notification settings")
//    }

//    SwitchDelegate {
//        Layout.fillWidth: true
//        text: qsTr("Bad air")
//    }
//    SwitchDelegate {
//        Layout.fillWidth: true
//        text: qsTr("Humidity")
//    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: createNew ? qsTr("OK") : qsTr("Remove this zone")
        onClicked: {
            if (createNew) {
                pageStack.pop()
            } else {
                d.pendingCommandId = acManager.removeZone(zone.id)
            }
        }
    }

    Component {
        id: selectBaseTempComponent
        NymeaDialog {
            id: selectBaseTempDialog

            property ZoneInfo zone: null

            CircleBackground {
                Layout.fillWidth: true
                Layout.preferredHeight: width

                Dial {
                    anchors.fill: parent
                    value: selectBaseTempDialog.zone.standbySetpoint
                    precision: 1
                    minValue: 10
                    maxValue: 40

                    onMoved: {
                        acManager.setZoneStandbySetpoint(zone.id, value)

                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: Types.toUiValue(zone.standbySetpoint, Types.UnitDegreeCelsius) + Types.toUiUnit(Types.UnitDegreeCelsius)
                    font: Style.bigFont
                }
            }
        }
    }
}
