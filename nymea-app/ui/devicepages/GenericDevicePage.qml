import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

DevicePageBase {
    id: root
    showDetailsButton: false

    function executeAction(actionTypeId, params) {
        print("executing", actionTypeId)
        return engine.deviceManager.executeAction(root.device.id, actionTypeId, params)
    }

    ListView {
        id: flickable
        anchors.fill: parent
        clip: true

        SwipeDelegateGroup {}

        section.property: "type"
        section.delegate: ListSectionHeader {
            text: {
                switch (parseInt(section)) {
                case DeviceModel.TypeStateType:
                    return qsTr("States")
                case DeviceModel.TypeActionType:
                    return qsTr("Actions")
                case DeviceModel.TypeEventType:
                    return qsTr("Events")
                }
            }
        }

        model: DeviceModel {
            device: root.device
        }
        delegate: SwipeDelegate {
            id: delegate
            width: parent.width

            readonly property StateType stateType: model.type === DeviceModel.TypeStateType ? root.deviceClass.stateTypes.getStateType(model.id) : null
            readonly property ActionType actionType: model.writable ? root.deviceClass.actionTypes.getActionType(model.id) : null
            readonly property EventType eventType: model.type === DeviceModel.TypeEventType ? root.deviceClass.eventTypes.getEventType(model.id) : null

            Layout.fillWidth: true
            topPadding: model.type === DeviceModel.TypeActionType ? app.margins / 2 : 0
            bottomPadding: 0
            contentItem: Loader {
                id: inlineLoader
                sourceComponent: {
                    switch (model.type) {
                    case DeviceModel.TypeStateType:
                        return stateComponent;
                    case DeviceModel.TypeActionType:
                        return actionComponent;
                    case DeviceModel.TypeEventType:
                        return eventComponent;
                    }
                }

                Binding {
                    target: inlineLoader.item
                    when: model.type === DeviceModel.TypeStateType
                    property: "stateType"
                    value: delegate.stateType
                }
                Binding {
                    target: inlineLoader.item
                    when: model.type === DeviceModel.TypeActionType
                    property: "actionType"
                    value: delegate.actionType
                }
                Binding {
                    target: inlineLoader.item
                    when: model.type === DeviceModel.TypeEventType
                    property: "eventType"
                    value: delegate.eventType
                }
            }

            onClicked: swipe.close()

            swipe.right: RowLayout {
                height: delegate.height
                anchors.right: parent.right
                MouseArea {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    ColorIcon {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        name: "../images/logs.svg"
                    }
                    onClicked: {
                        swipe.close();
                        pageStack.push(Qt.resolvedUrl("DeviceLogPage.qml"), {device: root.device, filterTypeIds: [model.id]})
                    }
                }
            }
        }
    }

    Component {
        id: stateComponent

        RowLayout {
            id: stateDelegate
            property StateType stateType: null
            readonly property State deviceState: stateType ? root.device.states.getState(stateType.id) : null
            readonly property bool writable: root.deviceClass.actionTypes.getActionType(stateType.id) !== null

            Label {
                Layout.fillWidth: true
                Layout.minimumWidth: parent.width / 2
                text: stateDelegate.stateType.displayName
                elide: Text.ElideRight
            }
            Loader {
                id: stateDelegateLoader
                Layout.fillWidth: true
            }
            Label {
                visible: stateDelegate.stateType.unit !== Types.UnitUnixTime && stateDelegate.stateType.unitString.length > 0
                text: stateDelegate.stateType.unitString
            }

            Component.onCompleted: updateLoader()
            onStateTypeChanged: updateLoader();

            function updateLoader() {
                if (stateDelegate.stateType == null) {
                    return;
                }

                var isWritable =  root.deviceClass.actionTypes.getActionType(stateType.id) !== null;

                var sourceComp;
                switch (stateDelegate.stateType.type.toLowerCase()) {
                case "string":
                    if (isWritable) {
                        if (stateDelegate.stateType.allowedValues.length > 0) {
                            sourceComp = "ComboBoxDelegate.qml"
                        } else {
                            sourceComp = "TextFieldDelegate.qml";
                        }
                    } else {
                        sourceComp = "LabelDelegate.qml";
                    }
                    break;
                case "stringlist":
                    sourceComp = "ListDelegate.qml";
                    break;
                case "bool":
                    if (isWritable) {
                        sourceComp = "SwitchDelegate.qml";
                    } else {
                        sourceComp = "LedDelegate.qml";
                    }
                    break;
                case "int":
                case "uint":
                case "double":
                    if (stateDelegate.stateType.unit === Types.UnitUnixTime) {
                        sourceComp = "DateTimeDelegate.qml";
                    } else if (isWritable) {
                        if (stateDelegate.stateType.minValue !== undefined && stateDelegate.stateType.maxValue !== undefined) {
                            sourceComp = "SliderDelegate.qml";
                        } else {
                            sourceComp = "SpinBoxDelegate.qml";
                        }
                    } else {
                        sourceComp = "NumberLabelDelegate.qml";
                    }
                    break;
                case "color":
                    sourceComp = "ColorDelegate.qml";
                    break;
                }
                if (!sourceComp) {
                    sourceComp = "LabelDelegate.qml";
                    print("GenericDevicePage: unhandled entry", stateDelegate.stateType.displayName)
                }

                var minValue = stateDelegate.stateType.minValue !== undefined
                        ? stateDelegate.stateType.minValue
                        : stateDelegate.stateType.type.toLowerCase() === "uint"
                          ? 0
                          : -2000000000; // As per QML spec
                var maxValue = stateDelegate.stateType.maxValue !== undefined
                        ? stateDelegate.stateType.maxValue
                        : 2000000000;
                print(stateDelegate.stateType.minValue)
                print("pushing delegate for", stateDelegate.stateType.name, "from:", minValue, "to:", maxValue)
                stateDelegateLoader.setSource("../delegates/statedelegates/" + sourceComp,
                                              {
//                                                  value: root.device.states.getState(stateType.id).value,
                                                  possibleValues: stateDelegate.stateType.allowedValues,
                                                  from: minValue,
                                                  to: maxValue,
                                                  writable: isWritable,
                                                  stateType: stateDelegate.stateType
                                              })
            }

            property int pendingActionId: -1
            property real valueCache: 0
            property bool valueCacheDirty: false

            function enqueueSetValue(value) {
                if (pendingActionId == -1) {
                    executeAction(value);
                    return;
                } else {
                    valueCache = value
                    valueCacheDirty = true;
                }
            }

            function executeAction(value) {
                var params = []
                var param1 = {}
                param1["paramTypeId"] = stateDelegate.stateType.id
                param1["value"] = value;
                params.push(param1)
                var actionId = root.executeAction(stateDelegate.stateType.id, params);
                stateDelegate.pendingActionId = actionId
            }

            Binding {
                target: stateDelegateLoader.item
                property: "value"
                value: stateDelegate.deviceState.value
                when: !stateDelegate.valueCacheDirty && stateDelegate.pendingActionId === -1
            }

            Connections {
                target: stateDelegateLoader.item && stateDelegateLoader.item.hasOwnProperty("changed") ? stateDelegateLoader.item : null
                onChanged: {
                    stateDelegate.enqueueSetValue(value)
                }
            }
            Connections {
                target: engine.deviceManager
                onExecuteActionReply: {
                    if (stateDelegate.pendingActionId === params.id) {
                        stateDelegate.pendingActionId = -1
                        if (stateDelegate.valueCacheDirty) {
                            stateDelegate.executeAction(stateDelegate.valueCache)
                            stateDelegate.valueCacheDirty = false;
                        }
                    }
                }
            }
        }
    }

    Component {
        id: actionComponent

        RowLayout {
            id: actionDelegate

            property ActionType actionType: null
            property int pendingActionId: -1
            property bool lastSuccess: false

            Connections {
                target: engine.deviceManager
                onExecuteActionReply: {
                    if (params["id"] === actionDelegate.pendingActionId) {
                        pendingTimer.start();
                        actionDelegate.lastSuccess = params["params"]["deviceError"] === "DeviceErrorNoError"
                        actionDelegate.pendingActionId = -1
                    }
                }
            }
            Timer { id: pendingTimer; interval: 1000; repeat: false; running: false }

            Button {
                text: actionType.displayName
                Layout.fillWidth: true


                onClicked: {
                    if (actionDelegate.actionType.paramTypes.count === 0) {
                        actionDelegate.pendingActionId = root.executeAction(actionDelegate.actionType.id, [])
                    } else {
                        var dialog = paramsDialogComponent.createObject(root, { actionType: actionDelegate.actionType })
                        dialog.open()
                    }
                }

                Component {
                    id: paramsDialogComponent
                    Dialog {
                        id: paramsDialog
                        modal: true
                        width: parent.width - app.margins * 2
                        x: (parent.width - width) / 2
                        y: (parent.height - height) / 2
                        padding: 0

                        property ActionType actionType: null

                        contentItem: ColumnLayout {
                            Repeater {
                                id: paramsRepeater
                                model: paramsDialog.actionType.paramTypes
                                delegate: ParamDelegate {
                                    Layout.fillWidth: true
                                    paramType: paramsDialog.actionType.paramTypes.get(index)
                                }
                            }
                            RowLayout {
                                Layout.margins: app.margins
                                spacing: app.margins
                                Button {
                                    text: qsTr("Cancel")
                                    Layout.fillWidth: true
                                    onClicked: paramsDialog.close()
                                }
                                Button {
                                    text: qsTr("OK")
                                    Layout.fillWidth: true
                                    onClicked: {
                                        var params = []
                                        for (var i = 0; i < paramsRepeater.count; i++) {
                                            var param = {}
                                            param["paramTypeId"] = paramsRepeater.itemAt(i).paramType.id
                                            param["value"] = paramsRepeater.itemAt(i).value
                                            params.push(param)
                                        }
                                        actionDelegate.pendingActionId = root.executeAction(paramsDialog.actionType.id, params);
                                        paramsDialog.close();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.preferredHeight: preferredSize
                Layout.preferredWidth: preferredSize
                property int preferredSize: actionDelegate.pendingActionId !== -1 || pendingTimer.running ? app.iconSize : 0
                Behavior on preferredSize { NumberAnimation { duration: 100 } }

                BusyIndicator {
                    anchors.fill: parent
                    visible: actionDelegate.pendingActionId !== -1
                }

                ColorIcon {
                    anchors.fill: parent
                    visible: actionDelegate.pendingActionId === -1
                    name: actionDelegate.lastSuccess ? "../images/tick.svg" : "../images/close.svg"
                    color: actionDelegate.lastSuccess ? "green" : "red"
                }
            }
        }
    }

    Component {
        id: eventComponent
        RowLayout {
            id: eventComponentItem
            property EventType eventType: null


            Label {
                Layout.fillWidth: true
                text: eventComponentItem.eventType.displayName
            }
            Rectangle {
                id: flashlight
                Layout.preferredHeight: app.iconSize * .8
                Layout.preferredWidth: height
                color: "lightgray"
                radius: width / 2
                border.color: app.foregroundColor
                border.width: 1

                SequentialAnimation on color {
                    id: flashlightAnimation
                    running: false
                    ColorAnimation { to: "lightgreen"; duration: 100 }
                    ColorAnimation { to: "lightgray"; duration: 500 }
                }
            }
            LogsModelNg {
                engine: _engine
                live: true
                deviceId: root.device.id
                typeIds: eventComponentItem.eventType.id
                onCountChanged: {
                    flashlightAnimation.start()
                }
            }
        }
    }
}
