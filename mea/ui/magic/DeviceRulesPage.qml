import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import Mea 1.0

Page {
    id: root

    property var device: null

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
            rule = Engine.ruleManager.createNewRule();
        }
        d.editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: rule});
        d.editRulePage.StackView.onRemoved.connect(function() {
            d.editRulePage.rule.destroy();
            d.editRulePage = null
        })
        d.editRulePage.onAccept.connect(function() {
            d.editRulePage.busy = true;
            Engine.ruleManager.addRule(page.rule);
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

        delegate: SwipeDelegate {
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
                d.editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: rulesFilterModel.get(index).clone() })
                d.editRulePage.StackView.onRemoved.connect(function() {
                    d.editRulePage.rule.destroy();
                })
                d.editRulePage.onAccept.connect(function() {
                    d.editRulePage.busy = true
                    Engine.ruleManager.editRule(d.editRulePage.rule);
                })
                d.editRulePage.onCancel.connect(function() {
                    pageStack.pop();
                })
            }

            swipe.right: Item {
                height: ruleDelegate.height
                width: height
                anchors.right: parent.right
                ColorIcon {
                    anchors.fill: parent
                    anchors.margins: app.margins
                    name: "../images/delete.svg"
                    color: "red"
                }
                SwipeDelegate.onClicked: Engine.ruleManager.removeRule(model.id)
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
