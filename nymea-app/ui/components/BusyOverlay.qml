import QtQuick 2.9
import QtQuick.Controls 2.1

Rectangle {
    anchors.fill: parent
    color: "#55000000"
    visible: shown

    property bool shown: false

    BusyIndicator {
        anchors.centerIn: parent
    }
}
