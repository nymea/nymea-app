import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/customviews"

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
