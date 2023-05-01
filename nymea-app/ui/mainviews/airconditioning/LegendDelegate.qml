import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0
import QtCharts 2.3

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

