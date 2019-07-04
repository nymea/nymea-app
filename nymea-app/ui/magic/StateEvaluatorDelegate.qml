import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

ItemDelegate {

    id: root
    property var stateEvaluator: null
    readonly property var device: stateEvaluator ? engine.deviceManager.devices.getDevice(stateEvaluator.stateDescriptor.deviceId) : null
    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var stateType: deviceClass ? deviceClass.stateTypes.getStateType(stateEvaluator.stateDescriptor.stateTypeId) : null

    property bool canDelete: true
    signal deleteClicked()

    function editStateDescriptor(interfaceMode) {
        if (interfaceMode === undefined) {
            interfaceMode = false;
        }

        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {selectInterface: interfaceMode, showStates: true});
        page.backPressed.connect(function() {
            pageStack.pop()
        })
        page.thingSelected.connect(function(device) {
            root.stateEvaluator.stateDescriptor.interfaceName = "";
            root.stateEvaluator.stateDescriptor.deviceId = device.id;
            selectStateDescriptorData()
        });
        page.interfaceSelected.connect(function(interfaceName) {
            root.stateEvaluator.stateDescriptor.deviceId = "";
            root.stateEvaluator.stateDescriptor.interfaceName = interfaceName;
            selectStateDescriptorData();
        });
    }
    function editInterfaceStateDescriptor() {
        editStateDescriptor(true)
    }
    function selectStateDescriptorData() {
        var statePage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorPage.qml"), {text: "Select state", stateDescriptor: root.stateEvaluator.stateDescriptor})
        statePage.backPressed.connect(function() {
            pageStack.pop();
        })
        statePage.done.connect(function() {
            pageStack.pop();
            pageStack.pop();
            pageStack.pop();
        })
    }

    contentItem: ColumnLayout {
        SimpleStateEvaluatorDelegate {
            Layout.fillWidth: true
            stateEvaluator: root.stateEvaluator
            swipe.enabled: root.canDelete
            onClicked: {
                var page = pageStack.push(stateQuestionPageComponent);
            }
            onDeleteClicked: {
                root.deleteClicked()
            }
        }

        ComboBox {
            Layout.fillWidth: true
            model: [qsTr("and all of those"), qsTr("or any of those")]
            currentIndex: root.stateEvaluator && root.stateEvaluator.stateOperator === StateEvaluator.StateOperatorAnd ? 0 : 1
            visible: root.stateEvaluator && root.stateEvaluator.childEvaluators.count > 0
            onActivated: {
                root.stateEvaluator.stateOperator = index == 0 ? StateEvaluator.StateOperatorAnd : StateEvaluator.StateOperatorOr
            }
        }

        Repeater {
            model: root.stateEvaluator ? root.stateEvaluator.childEvaluators : null
            delegate: SimpleStateEvaluatorDelegate {
                Layout.fillWidth: true
                stateEvaluator: root.stateEvaluator.childEvaluators.get(index)
                showChilds: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("EditStateEvaluatorPage.qml"), {stateEvaluator: stateEvaluator})
                }
                onDeleteClicked: {
                    root.stateEvaluator.childEvaluators.remove(index)
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Add a condition")
            onClicked: {
                root.stateEvaluator.addChildEvaluator()
            }
        }
    }

    Component {
        id: stateQuestionPageComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Edit condition...")

                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                Repeater {
                    model: ListModel {
                        ListElement {
                            iconName: "../images/state.svg"
                            text: qsTr("When one of my things is in a certain state")
                            method: "editStateDescriptor"

                        }
                        ListElement {
                            iconName: "../images/state-interface.svg"
                            text: qsTr("When a thing of a given type enters a state")
                            method: "editInterfaceStateDescriptor"
                        }
                    }
                    delegate: NymeaListItemDelegate {
                        Layout.fillWidth: true
                        iconName: model.iconName
                        text: model.text
                        progressive: true
                        iconSize: app.iconSize * 2

                        onClicked: {
                            root[model.method]()
                        }
                    }
                }
            }
        }
    }
}
