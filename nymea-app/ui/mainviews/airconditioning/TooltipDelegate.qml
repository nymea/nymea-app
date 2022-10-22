import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0
import QtCharts 2.3

NymeaToolTip {
    width: layout.implicitWidth + Style.smallMargins * 2
    height: layout.implicitHeight + Style.smallMargins * 2

    property Thing thing: null
    property LogEntry entry: null
    property alias color: rect.color
    property ValueAxis axis: null
    property int unit: Types.UnitNone

    readonly property int realY: entry ? Math.min(Math.max(mouseArea.height - (entry.value * mouseArea.height / axis.max) - height / 2 /*- Style.margins*/, 0), mouseArea.height - height) : 0
    property int fixedY: 0
    y: fixedY // Animated

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Style.smallMargins

        Rectangle {
            id: rect
            width: Style.extraSmallFont.pixelSize
            height: width
        }
        Label {
            text: "%1: %2%3".arg(thing.name).arg(entry ? round(Types.toUiValue(entry.value, unit)) : "-").arg(Types.toUiUnit(unit))
            Layout.fillWidth: true
            font: Style.extraSmallFont
            elide: Text.ElideMiddle
            function round(value) {
                return Math.round(value * 100) / 100
            }
        }
    }
}
