import QtQuick 2.4
import QtQuick.Controls 2.2

Rectangle {
    id: root

    property TextArea textArea: null

    FontMetrics {
        id: fontMetrics
        font: textArea.font
    }

    width: {
        var ret = fontMetrics.maximumCharacterWidth * 2;
        var tmp = textArea.lineCount
        while (tmp >= 10) {
            ret += fontMetrics.maximumCharacterWidth;
            tmp /= 10;
        }
        return ret;
    }
    height: root.textArea.height - 10
    color: (app.backgroundColor.r * 0.2126 + app.backgroundColor.g * 0.7152 + app.backgroundColor.b * 0.0722) * 255 < 128 ? "#202020" : "#e0e0e0"
    Component.onCompleted: {
        print("..", app.backgroundColor.r)
        print("*** background", (app.backgroundColor.r * 0.2126 + app.backgroundColor.g * 0.7152 + app.backgroundColor.b * 0.0722) * 255 < 128 )
    }

    Column {
        id: lineNumbersColumn
        anchors.fill: parent
        anchors.topMargin: 8
        Repeater {
            model: root.textArea.lineCount
            delegate: Rectangle {
                id: lineNumberDelegate
                width: parent.width
                height: root.textArea.contentHeight / root.textArea.lineCount
                color: hasError ? "#FF0000" : "transparent"
                readonly property bool hasError: errorModel.errorLines.indexOf(index + 1) >= 0
                Label {
                    id: lineNumber
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 3
                    text: index + 1
                    font.pixelSize: root.textArea.font.pixelSize
                    font.family: root.textArea.font.family
                    font.weight: Font.Light
                    color: lineNumberDelegate.hasError ? "#FFFFFF" : "#808080"
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    ToolTip.visible: lineNumberDelegate.hasError && containsMouse
                    ToolTip.text: hasError ? errorModel.getError(index + 1).message : ""
                    property string bla: hasError ? ".." : ""
                    onBlaChanged: print("**", errorModel.getError(index + 1).message)
                }
            }
        }
    }
}