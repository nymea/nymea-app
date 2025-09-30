import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    property alias energyManager: consumersPieChart.energyManager
    property alias consumers: consumersPieChart.consumers

    header: NymeaHeader {
        text: qsTr("Consumers balance")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ConsumersPieChart {
        id: consumersPieChart
        anchors.fill: parent
        titleVisible: false
    }
}
