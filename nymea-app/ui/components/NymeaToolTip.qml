import QtQuick 2.3
import QtGraphicalEffects 1.0
import Nymea 1.0

Item {
    id: root

    property alias backgroundItem: blurEffectSource.sourceItem
    property alias backgroundRect: blurEffectSource.sourceRect

    Behavior on x { NumberAnimation { duration: Style.animationDuration } }
    Behavior on y { NumberAnimation { duration: Style.animationDuration } }
    Behavior on width { NumberAnimation { duration: Style.animationDuration } }
    Behavior on height { NumberAnimation { duration: Style.animationDuration } }

    Rectangle {
        id: blurSource
        anchors.fill: toolTip
        color: Style.backgroundColor
        visible: false
        radius: Style.smallCornerRadius

        ShaderEffectSource {
            id: blurEffectSource
            anchors.fill: parent
        }
    }

    FastBlur {
        anchors.fill: toolTip
        source: blurSource
        radius: 32
        visible: toolTip.visible
    }

    Rectangle {
        anchors.fill: parent
        color: Style.tooltipBackgroundColor
        opacity: .5
        radius: Style.smallCornerRadius
    }

}
