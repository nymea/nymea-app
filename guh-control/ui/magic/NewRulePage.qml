import QtQuick 2.8
import QtQuick.Controls 2.1
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: "New rule"
        onBackPressed: pageStack.pop()
    }
}
