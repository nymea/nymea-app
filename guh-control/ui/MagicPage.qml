import QtQuick 2.8
import QtQuick.Controls 2.1
import "components"
import Guh 1.0

Page {
    id: root
    header: GuhHeader {
        text: "Magic"
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("images/add.svg")
            onClicked: {
                var newRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: Engine.ruleManager.createNewRule() });
                newRulePage.onAccept.connect(function() {
                    Engine.ruleManager.addRule(newRulePage.rule);
                })
            }
        }
    }

    ListView {
        anchors.fill: parent

        model: Engine.ruleManager.rules
        delegate: SwipeDelegate {
            width: parent.width
            text: model.name

            onClicked: {
                var editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: Engine.ruleManager.rules.get(index) })
                editRulePage.onAccept.connect(function() {
                    Engine.ruleManager.editRule(editRulePage.rule);
                })
            }

//            swipe.right: ColorIcon {
//                name: "delete.svg"
//                color: "red"
//            }

            swipe.right: Label {
                    id: deleteLabel
                    text: qsTr("Delete")
                    color: "white"
                    verticalAlignment: Label.AlignVCenter
                    padding: 12
                    height: parent.height
                    anchors.right: parent.right

                    SwipeDelegate.onClicked: Engine.ruleManager.removeRule(model.id)

                    background: Rectangle {
                        color: deleteLabel.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
                    }
                }
        }
    }
}
