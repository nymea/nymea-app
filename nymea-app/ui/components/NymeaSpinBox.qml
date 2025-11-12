import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2

import NymeaApp.Utils 1.0

RowLayout {
    id: root

    property var from
    property var to

    property var value
    property var showValue

    property bool floatingPoint: false

    property bool editable: true

    signal valueModified(var value)

    function parseUserInputFloat(text) {
        if (typeof text === "string") {
            if (text.includes(",")) {
                text = text.replace(",", ".")
            }
            return parseFloat(text)
        } else {
            return text
        }
    }

    function toUserVisibleFloat(value) {
        var text = value.toFixed(NymeaUtils.numDecimals(value))
        if (typeof root.showValue === "string" && root.showValue.includes(",")) {
            text = text.replace(".", ",")
        }
        return text
    }

    Component.onCompleted: {
        if (root.floatingPoint) {
            root.showValue = NymeaUtils.floatToLocaleString(root.value)
        }
    }

    ColorIcon {
        name: "remove"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var tmp = NaN
                if (root.floatingPoint) {
                    tmp = parseUserInputFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (tmp != NaN){
                    root.value = Math.max(root.from, tmp - 1)
                    root.showValue = toUserVisibleFloat(root.value)
                    root.valueModified(root.value)
                }
            }
        }
    }
    TextField {
        text: root.showValue
        readOnly: !root.editable
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        onTextEdited: {
            root.showValue = text
            var input = text
            if (input.includes(",")) {
                input = input.replace(",", ".")
            }
            root.value = input
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
                    tmp = parseUserInputFloat(root.value)
                } else {
                    tmp = parseInt(root.value)
                }
                if (tmp != NaN){
                    root.value = Math.min(root.to, tmp + 1)
                    root.showValue = toUserVisibleFloat(root.value)
                    root.valueModified(root.value)
                }
            }
        }
    }
}
