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
    property Thing thing: null
    property string iconName: ""
    property color color: "white"
    Layout.fillWidth: true
    Layout.fillHeight: true
    //                    opacity: selfProductionConsumptionSeries.opacity
    MouseArea {
        anchors.fill: parent
        anchors.topMargin: -Style.smallMargins
        anchors.bottomMargin: -Style.smallMargins
        //                        onClicked: d.selectSeries(selfProductionConsumptionSeries)
    }
    Row {
        anchors.centerIn: parent
        spacing: Style.smallMargins
        ColorIcon {
            name: root.iconName
            size: Style.smallIconSize
            color: root.color
        }
        Label {
            width: parent.parent.width - x
            elide: Text.ElideRight
            visible: root.width > 60
            text: root.thing.name
            anchors.verticalCenter: parent.verticalCenter
            font: Style.smallFont
        }
    }
}

