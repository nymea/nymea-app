import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    property alias energyManager: consumersHistory
    property alias consumers: consumersHistory.consumers

    header: NymeaHeader {
        text: qsTr("Power balance totals")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ConsumersHistory {
        id: consumersHistory
        anchors.fill: parent
        titleVisible: false
    }
}
