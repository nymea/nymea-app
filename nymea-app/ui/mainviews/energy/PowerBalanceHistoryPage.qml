import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("My power balance history")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    PowerBalanceHistory {
        id: powerBalanceHistory
        anchors.fill: parent
        titleVisible: false
    }
}
