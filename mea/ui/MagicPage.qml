import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "components"
import Mea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Magic")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("images/add.svg")
            onClicked: {
                d.editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: Engine.ruleManager.createNewRule() });
                d.editRulePage.StackView.onRemoved.connect(function() {
                    d.editRulePage.rule.destroy()
                    d.editRulePage = null;
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true;
                    Engine.ruleManager.addRule(d.editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
                })
            }
        }
    }

    QtObject {
        id: d
        property var editRulePage: null
    }

    Connections {
        target: Engine.ruleManager
        onAddRuleReply: {
            d.editRulePage.busy = false;
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop();
            } else {
                var popup = errorDialog.createObject(app, {errorCode: ruleError })
                popup.open();
            }
        }

        onEditRuleReply: {
            d.editRulePage.busy = false;
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop();
            } else {
                var popup = errorDialog.createObject(app, {errorCode: ruleError })
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
                d.editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: Engine.ruleManager.rules.get(index).clone()})
                d.editRulePage.StackView.onRemoved.connect(function() {
                    d.editRulePage.rule.destroy();
                    d.editRulePage = null
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true;
                    Engine.ruleManager.editRule(editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
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
