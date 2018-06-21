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
                addRule()
            }
        }
    }

    function addRule() {
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

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        spacing: app.margins * 2
        visible: Engine.ruleManager.rules.count ===  0
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("There is no magic set up yet.")
            wrapMode: Text.WordWrap
            color: app.guhAccent
            font.pixelSize: app.largeFont
        }
        Label {
            text: qsTr("Add some using the wizard stick!")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        AbstractButton {
            Layout.preferredHeight: app.iconSize * 4
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignHCenter

            ColorIcon {
                anchors.fill: parent
                name: "../images/magic.svg"
            }

            onClicked: addRule()
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {}
    }
}
