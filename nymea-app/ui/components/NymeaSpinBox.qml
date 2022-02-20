import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2

RowLayout {
    id: root

    property var from
    property var to

    property var value

    property bool floatingPoint: false

    property bool editable: true

    signal valueModified(var value)

    ColorIcon {
        name: "remove"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var tmp = NaN
                if (root.floatingPoint) {
                    tmp = parseFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (tmp != NaN){
                    root.value = tmp - 1
                    root.valueModified(root.value)
                }
            }
        }
    }
    TextField {
        text: root.value
        readOnly: !root.editable
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        onTextEdited: {
            root.value = text
            root.valueModified(root.value)
        }

        validator: root.floatingPoint ? doubleValidator : intValidator

        IntValidator {
            id: intValidator
            bottom: Math.min(root.from, root.to)
            top: Math.max(root.from, root.to)
        }

        DoubleValidator {
            id: doubleValidator
            bottom: Math.min(root.from, root.to)
            top:  Math.max(root.from, root.to)
        }

    }
    ColorIcon {
        name: "add"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var tmp = NaN
                if (root.floatingPoint) {
                    tmp = parseFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (tmp != NaN){
                    root.value = tmp + 1
                    root.valueModified(root.value)
                }
            }
        }
    }
}
