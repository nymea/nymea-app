import QtQuick 2.7
import QtQuick.Controls 2.2
import "../components"
import QtQuick.Layouts 1.2

Page {
    header: GuhHeader {
        text: "Add some magic"
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        Label {
            text: "When"
        }
    }

}
