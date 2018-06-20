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
        delegate: MeaListItemDelegate {
            id: ruleDelegate
            width: parent.width
            iconName: "../images/magic.svg"
            iconColor: !model.enabled ? "red" : (model.active ? app.guhAccent : "grey")
            text: model.name
            canDelete: true

            onDeleteClicked: Engine.ruleManager.removeRule(model.id)

            onClicked: {
                d.editRulePage = pageStack.push(Qt.resolvedUrl("magic/EditRulePage.qml"), {rule: Engine.ruleManager.rules.get(index).clone()})
                d.editRulePage.StackView.onRemoved.connect(function() {
                    d.editRulePage.rule.destroy();
                    d.editRulePage = null
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true;
                    Engine.ruleManager.editRule(d.editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
                })
            }
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {}
    }
}
