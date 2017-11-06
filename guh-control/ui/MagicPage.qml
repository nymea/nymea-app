import QtQuick 2.8
import QtQuick.Controls 2.1
import "components"
import Guh 1.0

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

        model: Engine.ruleManager.rules
        delegate: ItemDelegate {
            width: parent.width
            Label {
                text: model.name
            }
        }
    }
}
