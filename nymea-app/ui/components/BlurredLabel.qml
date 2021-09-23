import QtQuick 2.5
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import Nymea 1.0

Item {
    id: root
    implicitWidth: label.implicitWidth + Style.margins * 2
    implicitHeight: label.implicitHeight + Style.margins * 2

    property alias text: label.text
    property alias wrapMode: label.wrapMode
    property alias horizontalAlignment: label.horizontalAlignment
    property alias textFormat: label.textFormat

    property bool blurred: false

    Label {
        id: label
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: effectSource
        anchors.fill: parent
        sourceItem: label
        hideSource: true
        visible: false
    }

    FastBlur {
        anchors.fill: parent
        source: effectSource
        radius: root.blurred ? 32 : 0
        Behavior on radius { NumberAnimation { duration: Style.animationDuration } }
    }
}
