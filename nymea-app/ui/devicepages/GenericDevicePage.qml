import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../delegates"

DevicePageBase {
    id: root
    showDetailsButton: false

    function executeAction(actionTypeId, params) {
        return engine.deviceManager.executeAction(root.device.id, actionTypeId, params)
    }

    ListView {
        id: flickable
        anchors.fill: parent
        clip: true

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

            onClicked: pageStack.push(Qt.resolvedUrl("DeviceLogPage.qml"), {device: root.device, filterTypeIds: [model.id]})

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
                sourceComponent: {
                    switch (stateType.type.toLowerCase()) {
                    case "string":
                        if (stateDelegate.writable) {
                            if (stateDelegate.stateType.allowedValues !== undefined) {
                                return comboBoxComponent
                            }
                            return textFieldComponent;
                        } else {
                            return labelComponent;
                        }
                    case "stringlist":
                        return listComponent;
                    case "bool":
                        if (stateDelegate.writable) {
                            return switchComponent;
                        } else {
                            return ledComponent;
                        }
                    case "int":
                    case "double":
                        if (stateDelegate.stateType.unit === Types.UnitUnixTime) {
                            return dateTimeComponent;
                        }

                        if (stateDelegate.writable) {
                            return sliderComponent;
//                            return spinBoxComponent;
                        }
                        return numberLabelComponent;
                    case "color":
                        return colorComponent;
                    default:
                        print("Unhandled state type", stateType.displayName, stateType.type)
                    }

                    print("GenericDevicePage: unhandled entry", stateDelegate.stateType.displayName)
                }
            }

            Label {
                visible: stateDelegateLoader.sourceComponent === sliderComponent
                text: stateDelegate.deviceState.value
            }

            Label {
                visible: stateDelegate.stateType.unit !== Types.UnitUnixTime && stateDelegate.stateType.unitString.length > 0
                text: stateDelegate.stateType.unitString
            }

            Binding {
                target: stateDelegateLoader.item
                property: "value"
                value: root.device.states.getState(stateDelegate.stateType.id).value
            }
            Binding {
                target: stateDelegateLoader.item && stateDelegateLoader.item.hasOwnProperty("possibleValues") ? stateDelegateLoader.item : null
                property: "possibleValues"
                value: stateDelegate.stateType.allowedValues
            }
            Binding {
                target: stateDelegateLoader.item && stateDelegateLoader.item.hasOwnProperty("from") ? stateDelegateLoader.item : null
                property: "from"
                value: stateDelegate.stateType.minValue !== undefined ? stateDelegate.stateType.minValue : -999999999999
            }
            Binding {
                target: stateDelegateLoader.item && stateDelegateLoader.item.hasOwnProperty("to") ? stateDelegateLoader.item : null
                property: "to"
                value: stateDelegate.stateType.maxValue !== undefined ? stateDelegate.stateType.maxValue : 999999999999
            }
            Binding {
                target: stateDelegateLoader.item && stateDelegateLoader.item.hasOwnProperty("actionTypeId") ? stateDelegateLoader.item : null
                property: "actionTypeId"
                value: stateDelegate.stateType.id
            }
            Connections {
                target: stateDelegateLoader.item && stateDelegateLoader.item.hasOwnProperty("changed") ? stateDelegateLoader.item : null
                onChanged: {
                    var params = []
                    var param1 = {}
                    param1["paramTypeId"] = stateDelegate.stateType.id
                    param1["value"] = value;
                    params.push(param1)
                    root.executeAction(stateDelegate.stateType.id, params);
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
                        print("blubb!")
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

    Component {
        id: ledComponent
        Led {
            property bool value
            on: value === true
        }
    }

    Component {
        id: labelComponent
        Label {
            property var value
            text: value
        }
    }
    Component {
        id: numberLabelComponent
        Label {
            property var value
            text: Math.round(value * 100) / 100
        }
    }
    Component {
        id: textFieldComponent
        TextField {
            property var value
            text: value
        }
    }

    Component {
        id: listComponent
        Label {
            property var value
            text: value.join(", ")
        }
    }

    Component {
        id: checkBoxComponent
        CheckBox {
            property var value
            checked: value === true
            enabled: false
        }
    }

    Component {
        id: switchComponent
        Switch {
            property var value
            signal changed(var value)
            checked: value === true
            onClicked: {
                changed(checked)
            }
        }
    }

    Component {
        id: spinBoxComponent
        SpinBox {
            width: 150
            signal changed(var value)
            stepSize: (to - from) / 20
            editable: true
            onValueModified: {
                changed(value)
            }
        }
    }

    Component {
        id: sliderComponent
        ThrottledSlider {
            signal changed(var value)
            stepSize: 1
            onMoved: changed(value)
        }
    }

    Component {
        id: comboBoxComponent
        ComboBox {
            property var value
            property var possibleValues

            signal changed(var value)
            model: possibleValues
            onActivated: changed(model[index])
        }
    }

    Component {
        id: colorComponent
        Item {
            id: colorComponentItem
            implicitWidth: app.iconSize * 2
            implicitHeight: app.iconSize
            property var value
            signal changed(var value)

            Pane {
                anchors.fill: parent
                topPadding: 0
                bottomPadding: 0
                leftPadding: 0
                rightPadding: 0
                Material.elevation: 1
                contentItem: Rectangle {
                    color: colorComponentItem.value

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var pos = colorComponentItem.mapToItem(root, 0, colorComponentItem.height)
                            print("opening", colorComponentItem.value)
                            var colorPicker = colorPickerComponent.createObject(root, {preferredY: pos.y, colorValue: colorComponentItem.value })
                            colorPicker.open()
                        }
                    }
                }
            }

            Component {
                id: colorPickerComponent
                Dialog {
                    id: colorPickerDialog
                    modal: true
                    x: (parent.width - width) / 2
                    y: Math.min(preferredY, parent.height - height)
                    width: parent.width - app.margins * 2
                    height: 200
                    padding: app.margins
                    property var colorValue
                    property int preferredY: 0
                    contentItem: ColorPicker {
                        color: colorPickerDialog.colorValue
                        property var lastSentTime: new Date()
                        onColorChanged: {
                            var currentTime = new Date();
                            if (pressed && currentTime - lastSentTime > 200) {
                                colorComponentItem.changed(color);
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: dateTimeComponent
        Label {
            property var value
            text: Qt.formatDateTime(new Date(value * 1000), Qt.DefaultLocaleShortDate)
        }
    }
}
