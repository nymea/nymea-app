import QtQuick 2.8
import QtQuick.Controls 2.2
import "components"

Page {
    id: root
    header: GuhHeader {
        text: "Magic"
        backButtonVisible: false

        HeaderButton {
            imageSource: "images/add.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("magic/NewRulePage.qml"))
        }
    }

    ListView {
        anchors.fill: parent
//        model: Engine.
    }
}
