import QtQuick 2.8
import QtQuick.Controls 2.1
import "../components"

Page {
    id: root

    property var device: null

    header: GuhHeader {
        text: "New rule"
        onBackPressed: pageStack.pop()
    }
}
