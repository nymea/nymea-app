import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    property alias energyManager: powerBalanceStats
    property alias producers: powerBalanceStats.producers

    header: NymeaHeader {
        text: qsTr("Power balance totals")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    PowerBalanceStats {
        id: powerBalanceStats
        anchors.fill: parent
        titleVisible: false
    }
}
