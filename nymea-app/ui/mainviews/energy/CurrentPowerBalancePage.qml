import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

Page {
    id: root

    property EnergyManager energyManager: null
    property ThingsProxy consumers: null
    property ThingsProxy producers: null

    header: NymeaHeader {
        text: qsTr("My energy mix")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        CurrentConsumptionBalancePieChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
            energyManager: root.energyManager
            visible: root.producers.count > 0
            animationsEnabled: Qt.application.active
        }
        CurrentProductionBalancePieChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
            energyManager: root.energyManager
            visible: root.producers.count > 0
            animationsEnabled: Qt.application.active
        }
    }


}
