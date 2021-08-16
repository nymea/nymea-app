import QtQuick 2.3
import Qt5Compat.GraphicalEffects
import Nymea 1.0

Item {
    id: root

    property alias backgroundItem: blurEffectSource.sourceItem
    property alias backgroundRect: blurEffectSource.sourceRect

    Behavior on x { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
    Behavior on y { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
    Behavior on width { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
    Behavior on height { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }

    readonly property alias animationsEnabled: d.animationsEnabled

    Timer {
        running: visible
        repeat: false
        interval: 1
        onTriggered: {
            d.animationsEnabled = true
        }
    }
    onVisibleChanged: {
        if (!visible) {
            d.animationsEnabled = false
        }
    }

    QtObject {
        id: d
        property bool animationsEnabled: false
    }

    Rectangle {
        id: blurSource
        anchors.fill: parent
        color: Style.backgroundColor
        visible: false
        radius: Style.smallCornerRadius

        ShaderEffectSource {
            id: blurEffectSource
            anchors.fill: parent
        }
    }

    FastBlur {
        anchors.fill: parent
        source: blurSource
        radius: 32
        visible: root.visible
    }

    Rectangle {
        anchors.fill: parent
        color: Style.tooltipBackgroundColor
        opacity: .5
        radius: Style.smallCornerRadius
    }

}
