import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import "qrc:/ui/delegates"
import Nymea 1.0
import Nymea.AirConditioning 1.0

RowLayout {
    id: root
    implicitHeight: Style.bigIconSize

    property alias imageSource: icon.name
    property alias iconColor: icon.color
    property alias text: label.text

    property ZoneInfo zone: null
    property int flag: ZoneInfo.ZoneStatusFlagNone
    property bool active: zone && ((zone.zoneStatus & flag) > 0)

    ColorIcon {
        id: icon
        size: Style.bigIconSize
        color: root.active ? root.iconColor : Style.iconColor
    }
    Label {
        id: label
        Layout.fillWidth: true
    }
}
