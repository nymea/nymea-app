import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    property alias energyManager: consumersStats
    property alias consumers: consumersStats.consumers

    header: NymeaHeader {
        text: qsTr("Consumers balance")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ConsumerStats {
        id: consumersStats
        anchors.fill: parent
        titleVisible: false
    }
}
