import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

Dialog {
    id: root
    width: Math.min(parent.width * .6, 400)
//    height: content.height
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    title: qsTr("Error")
    property alias text: contentLabel.text

    standardButtons: Dialog.Ok

    header: Item {
        implicitHeight: headerRow.height + app.margins * 2
        implicitWidth: parent.width
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
            spacing: app.margins
            ColorIcon {
                Layout.preferredHeight: app.iconSize * 2
                Layout.preferredWidth: height
                name: "../images/dialog-error-symbolic.svg"
                color: app.guhAccent
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: root.title
                color: app.guhAccent
                font.pixelSize: app.largeFont
            }
        }
    }

    ColumnLayout {
        id: content
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: childrenRect.height

        Label {
            id: contentLabel
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
}
