import QtQuick
import QtQuick.Layouts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"

RowLayout {
    id: root
    Layout.fillWidth: true

    property ZoneInfo  zone: null
    property int iconSize: Style.iconSize

    signal clicked(int flag)

    Repeater {
        id: zoneStatusRepeater
        model: zoneStatusModel
        property var zoneStatusModel: [
            {
                value: ZoneInfo.ZoneStatusFlagSetpointOverrideActive,
                icon: "dial",
                activeColor: Style.accentColor
            },
            {
                value: ZoneInfo.ZoneStatusFlagTimeScheduleActive,
                icon: "calendar",
                activeColor: Style.orange
            },
            {
                value: ZoneInfo.ZoneStatusFlagWindowOpen,
                icon: "sensors/window-closed",
                activeIcon: "sensors/window-open",
                activeColor: Style.red
            },
            {
                value: ZoneInfo.ZoneStatusFlagHighHumidity,
                icon: "sensors/humidity",
                activeColor: Style.lightBlue
            },
            {
                value: ZoneInfo.ZoneStatusFlagBadAir,
                icon: "weathericons/weather-clouds",
                activeColor: Style.purple
            }
        ]
        delegate: Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.bigIconSize
            property var entry: zoneStatusRepeater.zoneStatusModel[index]
            ColorIcon {
                id: zoneStatusIcon
                anchors.centerIn: parent
                name: entry.hasOwnProperty("activeIcon") && active ? entry.activeIcon : entry.icon
                size: root.iconSize
                property bool active: (root.zone.zoneStatus & entry.value) > 0
                color: active ? entry.activeColor : Style.iconColor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.clicked(entry.value)
                }
            }
        }
    }
}
