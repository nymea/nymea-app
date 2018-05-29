import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"

ItemDelegate {
    id: root
    width: parent.width

    property var interfaces: []
    property var name: ""

    contentItem: RowLayout {
        spacing: app.margins
        ColorIcon {
            height: app.iconSize
            width: height
            name: app.interfacesToIcon(root.interfaces)
            color: app.guhAccent
        }

        Label {
            Layout.fillWidth: true
            text: root.name
        }
        Image {
            source: "../images/next.svg"
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: height
        }
    }
}
