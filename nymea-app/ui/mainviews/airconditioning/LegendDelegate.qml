import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/customviews"

Item {
    id: root
    implicitHeight: Style.smallIconSize + Style.smallMargins
    property alias text: textLabel.text
    property alias iconName: icon.name
    property color color: "white"

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: -Style.smallMargins
        anchors.bottomMargin: -Style.smallMargins
    }
    Row {
        anchors.centerIn: parent
        spacing: Style.smallMargins
        ColorIcon {
            id: icon
            size: Style.smallIconSize
            color: root.color
            visible: root.iconName != ""
        }
        Rectangle {
            width: Style.smallIconSize
            height: Style.smallIconSize
            color: root.color
            visible: root.iconName == ""
        }

        Label {
            id: textLabel
            width: parent.parent.width - x
            elide: Text.ElideRight
            visible: root.width > 60
            anchors.verticalCenter: parent.verticalCenter
            font: Style.smallFont
        }
    }
}

