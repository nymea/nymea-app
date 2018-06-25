import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"

MeaListItemDelegate {
    id: root
    width: parent.width
    iconName: app.interfacesToIcon(root.interfaces)
    text: root.name
    progressive: true

    property var interfaces: []
    property string name: ""
}
