import QtQuick 2.8
import QtQuick.Controls 2.1

Dialog {
    width: parent.width * .6
    height: parent.height * .6
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    title: qsTr("Error")
    property alias text: contentLabel.text

    standardButtons: Dialog.Ok

    Label {
        id: contentLabel
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
