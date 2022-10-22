import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import "qrc:/ui/customviews"
import Nymea 1.0
import Nymea.AirConditioning 1.0

Page {
    id: root
    property AirConditioningManager acManager: null
    property ZoneInfo zone: null

    ZoneInfoWrapper {
        id: zoneWrapper
        zone: root.zone
    }


    header: NymeaHeader {
        text: root.zone.name

        onBackPressed: {
            pageStack.pop()
        }

        HeaderButton {
            imageSource: "chart"
            onClicked: pageStack.push(Qt.resolvedUrl("ACChartsPage.qml"), {acManager: root.acManager, zoneWrapper: zoneWrapper})
        }
    }

    ZoneView {
        anchors.fill: parent
        acManager: root.acManager
        zoneWrapper: zoneWrapper
    }
}
