import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

Page {
    id: root

    property var device: null

    Component.onCompleted: print("+++ created devicerulespage")
    Component.onDestruction: print("--- destroying devicerulespage")

    header: GuhHeader {
        text: qsTr("Magic involving %1").arg(root.device.name)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/add.svg"
            visible: rulesListView.count > 0
            onClicked: addRule()
        }
    }

    // Rule is optional and might be initialized with anything wanted. A new, empty one will be created if null
    // This Page will take ownership of the rule and delete it eventually.
    function addRule(rule) {
        if (rule === null || rule === undefined) {
            d.editRulePage = pageStack.push(Qt.resolvedUrl("NewThingMagicPage.qml"), {device: root.device});
            d.editRulePage.manualCreation.connect(function() {
                pageStack.pop();
                rule = Engine.ruleManager.createNewRule();
                addRule(rule)
            })
            d.editRulePage.done.connect(function() {pageStack.pop(root);});
            return;
        }
        d.editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: rule});
        d.editRulePage.StackView.onRemoved.connect(function() {
            rule.destroy();
        })
        d.editRulePage.onAccept.connect(function() {
            d.editRulePage.busy = true;
            Engine.ruleManager.addRule(d.editRulePage.rule);
        })
        d.editRulePage.onCancel.connect(function() {
            pageStack.pop();
        })

//        if (rule.eventDescriptors.count === 0) {
//            var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
//            eventDescriptor.deviceId = device.id;
//            page.selectEventDescriptorData(eventDescriptor);
//        }

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
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                var popup = errorDialog.createObject(root, {errorCode: ruleError })
                popup.open();
            }
        }

        onEditRuleReply: {
            d.editRulePage.busy = false;
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop();
            } else {
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"));
                var popup = errorDialog.createObject(root, {errorCode: ruleError })
                popup.open();
            }
        }
    }

    ListView {
        id: rulesListView
        anchors.fill: parent

        model: RulesFilterModel {
            id: rulesFilterModel
            rules: Engine.ruleManager.rules
            filterDeviceId: root.device.id
        }

        delegate: MeaListItemDelegate {
            width: parent.width
            iconName: "../images/magic.svg"
            iconColor: !model.enabled ? "red" : (model.active ? app.guhAccent : "grey")
            text: model.name
            canDelete: true

            onDeleteClicked: Engine.ruleManager.removeRule(model.id)
            onClicked: {
                print("clicked")
                var newRule = rulesFilterModel.get(index).clone();
                print("rule cloned")
                d.editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: newRule })
                print("page pushed")
                d.editRulePage.StackView.onRemoved.connect(function() {
                    newRule.destroy();
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true
                    Engine.ruleManager.editRule(d.editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
                })
            }

        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        spacing: app.margins * 2
        visible: rulesListView.count == 0

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("There's no magic involving %1.").arg(root.device.name)
            font.pixelSize: app.largeFont
            color: app.guhAccent
        }
        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Add some using the wizard stick!")
            font.pixelSize: app.largeFont
        }

        AbstractButton {
            height: app.iconSize * 4
            width: height
            anchors.horizontalCenter: parent.horizontalCenter

            ColorIcon {
                anchors.fill: parent
                name: "../images/magic.svg"
            }

            onClicked: addRule()
        }
    }
}
