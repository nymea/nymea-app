import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "components"
import Mea 1.0

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

    Connections {
        target: Engine.ruleManager
        onAddRuleReply: {
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop();
            } else {
                var popup = errorDialog.createObject(root, {text: ruleError })
                popup.open();
            }
        }

        onEditRuleReply: {
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop();
            } else {
                var popup = errorDialog.createObject(root, {text: ruleError })
                popup.open();
            }
        }
    }

    ListView {
        anchors.fill: parent

        model: Engine.ruleManager.rules
        delegate: SwipeDelegate {
            id: ruleDelegate
            width: parent.width

            contentItem: RowLayout {
                spacing: app.margins
                ColorIcon {
                    height: app.iconSize
                    width: height
                    name: "../images/magic.svg"
                    color: !model.enabled ? "red" : (model.active ? app.guhAccent : "grey")
                }

                Label {
                    Layout.fillWidth: true
                    text: model.name
                }
            }

            onClicked: {
                var editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: Engine.ruleManager.rules.get(index) })
                editRulePage.onAccept.connect(function() {
                    Engine.ruleManager.editRule(editRulePage.rule);
                })
            }

            swipe.right: MouseArea {
                height: ruleDelegate.height
                width: height
                anchors.right: parent.right
                ColorIcon {
                    anchors.fill: parent
                    anchors.margins: app.margins
                    name: "../images/delete.svg"
                    color: "red"
                }
                onClicked: Engine.ruleManager.removeRule(model.id)
            }
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {}
    }
}
