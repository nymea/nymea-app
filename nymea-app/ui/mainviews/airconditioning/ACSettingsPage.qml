import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import Nymea.AirConditioning 1.0
import "qrc:/ui/components"
import "qrc:/ui/delegates"

SettingsPageBase {
    id: root
    title: qsTr("Configure zones")

    property AirConditioningManager acManager: null

    header: NymeaHeader {
        text: root.title
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "add"
            onClicked: {
                createZone();
            }

        }
    }

    function createZone() {
        pendingAddCall = acManager.addZone(qsTr("Zone %1").arg(acManager.zoneInfos.count + 1), [], [], [], [])
    }
    property int pendingAddCall: -1
    Connections {
        target: acManager

        onAddZoneReply: {
            if (commandId == pendingAddCall) {
                print("zone added", zoneId)
                var zone = acManager.zoneInfos.getZoneInfo(zoneId)
                pageStack.push(Qt.resolvedUrl("EditZonePage.qml"), {acManager: acManager, zone: zone, createNew: true})
            }
        }
    }


    Item {
        width: parent.width
        height: root.height - root.header.height
        visible: acManager.zoneInfos.count == 0

        EmptyViewPlaceholder {
            anchors.centerIn: parent
            width: parent.width - app.margins * 2
            title: qsTr("No zones configured.")
            text: qsTr("Start with configuring your zones.")
            imageSource: "qrc:/icons/sensors.svg"
            buttonText: qsTr("Add zone")
            onButtonClicked: createZone()
        }
    }


    Repeater {
        model: acManager.zoneInfos

        delegate: NymeaItemDelegate {
            property ZoneInfo zone: acManager.zoneInfos.get(index)
            Layout.fillWidth: true
            text: model.name
            onClicked: pageStack.push(Qt.resolvedUrl("EditZonePage.qml"), {acManager: root.acManager, zone: zone})
        }
    }
}
