import QtQuick 2.2
import QtQuick.Controls 2.2

Rectangle {
    id: lineNumbers
    width: {
        var ret = 10;
        var tmp = scriptEdit.lineCount
        while (tmp >= 10) {
            ret += 10;
            tmp /= 10;
        }
        return ret;
    }
    height: scriptEdit.height - 10
    color: (app.backgroundColor.r * 0.2126 + app.backgroundColor.g * 0.7152 + app.backgroundColor.b * 0.0722) * 255 < 128 ? "#202020" : "#e0e0e0"
    anchors { left: parent.left; leftMargin: scriptFlickable.contentX }
    Component.onCompleted: {
        print("..", app.backgroundColor.r)
        print("*** background", (app.backgroundColor.r * 0.2126 + app.backgroundColor.g * 0.7152 + app.backgroundColor.b * 0.0722) * 255 < 128 )
    }

    Column {
        id: lineNumbersColumn
        anchors.fill: parent
        anchors.topMargin: 8
        Repeater {
            model: scriptEdit.lineCount
            delegate: Rectangle {
                id: lineNumberDelegate
                width: parent.width
                height: scriptEdit.contentHeight / scriptEdit.lineCount
                color: hasError ? "#FF0000" : "transparent"
                readonly property bool hasError: errorModel.errorLines.indexOf(index + 1) >= 0
                Label {
                    id: lineNumber
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 3
                    text: index + 1
                    font.pixelSize: scriptEdit.font.pixelSize
                    font.family: scriptEdit.font.family
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
