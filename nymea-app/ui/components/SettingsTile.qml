import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

BigTile {
    id: root

    property alias iconSource: icon.name
    property alias text: textLabel.text
    property alias subText: subTextLabel.text

    contentItem: RowLayout {
        spacing: Style.margins
        ColorIcon {
            id: icon
            size: Style.iconSize
            color: Style.accentColor
        }
        ColumnLayout {
            Label {
                id: textLabel
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Label {
                id: subTextLabel
                Layout.fillWidth: true
                font: Style.extraSmallFont
                elide: Text.ElideRight
                color: Style.unobtrusiveForegroundColor
            }
        }
    }
}
