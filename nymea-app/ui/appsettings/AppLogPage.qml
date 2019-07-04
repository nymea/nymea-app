import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    header: NymeaHeader {
        text: qsTr("App log")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        HeaderButton {
            imageSource: "../images/edit-copy.svg"
            onClicked: AppLogController.toClipboard()
        }
    }

    ListView {
        anchors.fill: parent

        ScrollBar.vertical: ScrollBar {}

        model: AppLogController
        delegate: Text {
            width: parent.width
            maximumLineCount: 2
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: model.text
            color: model.type === AppLogController.TypeWarning ? "red" : app.foregroundColor
            font.pixelSize: app.smallFont
        }
    }
}
