import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
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
