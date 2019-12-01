import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

Dialog {
    id: root
    width: Math.min(parent.width * .8, Math.max(contentLabel.implicitWidth, 400))
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property alias headerIcon: headerColorIcon.name
    property alias text: contentLabel.text
    default property alias children: content.children

    standardButtons: Dialog.Ok

    MouseArea {
        parent: app.overlay
        anchors.fill: parent
        z: -1
        onPressed: mouse.accepted = true
    }

    header: Item {
        implicitHeight: headerRow.height + app.margins * 2
        implicitWidth: parent.width
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
            spacing: app.margins
            ColorIcon {
                id: headerColorIcon
                Layout.preferredHeight: app.iconSize * 2
                Layout.preferredWidth: height
                color: app.accentColor
                visible: name.length > 0
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                color: app.accentColor
                font.pixelSize: app.largeFont
            }
        }
    }
    ColumnLayout {
        id: content
        anchors { left: parent.left; top: parent.top; right: parent.right }

        Label {
            id: contentLabel
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            visible: text.length > 0
        }
    }
}
