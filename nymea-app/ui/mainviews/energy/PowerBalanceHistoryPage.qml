import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
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
