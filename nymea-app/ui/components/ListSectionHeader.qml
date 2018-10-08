import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ColumnLayout {
    width: parent.width
    property alias text: label.text
    Label {
        id: label
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        Layout.topMargin: app.margins
        horizontalAlignment: Text.AlignRight
    }
    ThinDivider {}
}
