import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
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
