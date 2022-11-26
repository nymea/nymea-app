import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
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
