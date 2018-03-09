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

    function addRule() {
//        pageStack.push(Qt.resolvedUrl("NewThingMagicPage.qml"), {device: root.device, text: "Add magic"})
        var rule = Engine.ruleManager.createNewRule();
        var page = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: rule});
        var eventDescriptor = rule.eventDescriptors.createNewEventDescriptor();
        eventDescriptor.deviceId = device.id;
        page.selectEventDescriptorData(eventDescriptor);
        page.onAccept.connect(function() {
            Engine.ruleManager.addRule(page.rule);
        })

    }

    Connections {
        target: Engine.ruleManager
        onAddRuleReply: {
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop();
            }
        }

        onEditRuleReply: {
            print("have add rule reply")
            if (ruleError == "RuleErrorNoError") {
                pageStack.pop();
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
                    color: !model.enabled ? "gray" : (model.active ? "red" : app.guhAccent)
                }

                Label {
                    Layout.fillWidth: true
                    text: model.name
                }
            }

            onClicked: {
                var editRulePage = pageStack.push(Qt.resolvedUrl("EditRulePage.qml"), {rule: rulesFilterModel.get(index) })
                editRulePage.onAccept.connect(function() {
                    Engine.ruleManager.editRule(editRulePage.rule);
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
