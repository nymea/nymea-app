import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ColumnLayout {
    id: root
    spacing: app.margins * 2

    property alias title: titleLabel.text
    property alias text: textLabel.text
    property alias imageSource: image.source
    property alias buttonText: button.text
    property alias buttonVisible: button.visible

    signal imageClicked();
    signal buttonClicked();

    Label {
        id: titleLabel
        font.pixelSize: app.largeFont
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: app.guhAccent
    }
    Label {
        id: textLabel
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        Layout.alignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    Image {
        id: image
        Layout.preferredWidth: app.iconSize * 5
        Layout.preferredHeight: width
        Layout.alignment: Qt.AlignHCenter
        sourceSize.width: app.iconSize * 5
        sourceSize.height: app.iconSize * 5
        MouseArea {
            anchors.fill: parent
            onClicked: root.imageClicked();
        }
    }
    Button {
        id: button
        Layout.fillWidth: true
        Layout.maximumWidth: 400
        Layout.alignment: Qt.AlignHCenter
        onClicked: root.buttonClicked();
    }
}
