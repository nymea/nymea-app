import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Mea 1.0

SwipeDelegate {

    id: root
    property var stateEvaluator: null
    readonly property var device: stateEvaluator ? Engine.deviceManager.devices.getDevice(stateEvaluator.stateDescriptor.deviceId) : null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var stateType: deviceClass ? deviceClass.stateTypes.getStateType(stateEvaluator.stateDescriptor.stateTypeId) : null

    contentItem: ColumnLayout {
        SimpleStateEvaluatorDelegate {
            Layout.fillWidth: true
            stateEvaluator: root.stateEvaluator
            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"));
                page.backPressed.connect(function() {pageStack.pop()})
                page.thingSelected.connect(function(device) {
                    root.stateEvaluator.stateDescriptor.deviceId = device.id
                    var statePage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorPage.qml"), {text: "Select state", stateDescriptor: root.stateEvaluator.stateDescriptor})
                    statePage.backPressed.connect(function() {pageStack.pop()})
                    statePage.done.connect(function() {pageStack.pop(); pageStack.pop()})
                })
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
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Add a condition")
            onClicked: {
                root.stateEvaluator.addChildEvaluator()
                //                    root.editStateEvaluator()
            }
        }
    }
}
