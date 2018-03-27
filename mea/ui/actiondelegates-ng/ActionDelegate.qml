import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Mea 1.0
import "../components"

ItemDelegate {
    id: root

    property var actionType: null
    property var actionState: null

    signal executeAction(var params)

    contentItem: ColumnLayout {
        RowLayout {
            Label {
                Layout.fillWidth: true
                text: root.actionType.displayName
                elide: Text.ElideRight
            }
            Loader {
                id: loader
                Layout.fillWidth: sourceComponent == textFieldComponent
                sourceComponent: {
                    if (root.actionType.paramTypes.count !== 1) {
                        return buttonComponent
                    }

                    var paramType = root.actionType.paramTypes.get(0);
                    switch (paramType.type.toLowerCase()) {
                    case "bool":
                        return boolComponent;
                    case "int":
                        return stringComponent;
                    case "string":
                    case "qstring":
                        if (paramType.allowedValues.length > 0) {
                            return comboBoxComponent;
                        }
                        return textFieldComponent;
                    case "color":
                        return colorPreviewComponent;
                    }
                    console.warn("Param Delegate: Fallback to stringComponent", paramType.name, paramType.type)
                    return stringComponent;
                }
            }
            Binding {
                target: loader.item
                when: loader.item
                property: "paramType"
                value: root.actionType.paramTypes.get(0)
            }
            Binding {
                target: loader.item
                when: loader.item
                property: "value"
                value: root.actionState
            }
        }
        Repeater {
            id: paramRepeater
            model: root.actionType.paramTypes
            delegate: Loader {
                id: bottomLoader
                property var paramType: root.actionType.paramTypes.get(index)
                Layout.fillWidth: true
                sourceComponent: {
                    switch (paramType.type.toLowerCase()) {
                    case "int":
                    case "double":
                        if (paramType.minValue != undefined && paramType.maxValue != undefined) {
                            return sliderComponent
                        }
                        break;
                    case "color":
                        return colorPickerComponent
                    case "string":
                        return paramType.allowedValues.length === 0 ? textFieldComponent : null
                    }
                    return null;
                }

                Binding {
                    target: bottomLoader.item
                    when: bottomLoader.item
                    property: "paramType"
                    value: bottomLoader.paramType
                }
                Binding {
                    target: bottomLoader.item
                    when: bottomLoader.item && root.actionState
                    property: "value"
                    value: root.actionState
                }
            }
        }
    }

    Component {
        id: stringComponent
        Label {
            property var paramType: null
            property var value: null
            text: {
                switch (paramType.type.toLowerCase()) {
                case "int":
                    return Math.round(value);
                }
                return value;
            }
        }
    }
    Component {
        id: boolComponent
        Switch {
            checked: root.actionState === true
            onClicked: {
                var params = [];
                var param1 = new Object();
                param1["paramTypeId"] = root.actionType.paramTypes.get(0).id;
                param1["value"] = checked;
                params.push(param1)
                root.executeAction(params)
            }
        }
    }
    Component {
        id: sliderComponent
        RowLayout {
            id: sliderRow
            spacing: app.margins
            property var paramType: null
            property var value: null
            Label {
                text: sliderRow.paramType.minValue
            }
            ThrottledSlider {
                Layout.fillWidth: true
                from: sliderRow.paramType.minValue
                to: sliderRow.paramType.maxValue
                value: sliderRow.value
                stepSize: {
                    switch (sliderRow.paramType.type) {
                    case "Int":
                        return 1;
                    }
                    return 0.01;

                }

                onMoved: {
                    var params = [];
                    var param1 = new Object();
                    param1["paramTypeId"] = sliderRow.paramType.id;
                    param1["value"] = value;
                    params.push(param1)
                    root.executeAction(params)
                }
            }
            Label {
                text: sliderRow.paramType.maxValue
            }
        }

    }

    Component {
        id: textFieldComponent
        RowLayout {
            property alias value: textField.text
            property var paramType: null
            spacing: app.margins
            Label {
                text: paramType.displayName
            }

            TextField {
                id: textField
                Layout.fillWidth: true
            }
        }
    }

    Component {
        id: comboBoxComponent
        ComboBox {
            id: box
            model: paramType.allowedValues
            currentIndex: paramType.allowedValues.indexOf(value)
            property var paramType: null
            property var value: null
            onActivated: {
                value = paramType.allowedValues[index]
                var params = [];
                var param1 = new Object();
                param1["paramTypeId"] = paramType.id;
                param1["value"] = currentText;
                params.push(param1)
                root.executeAction(params)
            }
        }
    }

    Component {
        id: colorPickerComponent
        ColorPicker {
            id: colorPicker
            implicitHeight: 200
//            color: root.param.value

            Binding {
                target: colorPicker
                property: "color"
                value: root.actionState
                when: !colorPicker.pressed
            }

            property var lastSentTime: new Date()
            onColorChanged: {
                var currentTime = new Date();
                if (pressed && currentTime - lastSentTime > 200) {
                    var params = [];
                    var param1 = new Object();
                    param1["paramTypeId"] = paramType.id;
                    param1["value"] = color;
                    params.push(param1)
                    root.executeAction(params)
                }
            }

            touchDelegate: Rectangle {
                height: 15
                width: height
                radius: height / 2
                color: Material.accent


                Rectangle {
                    color: colorPicker.hovered || colorPicker.pressed ? "#11000000" : "transparent"
                    anchors.centerIn: parent
                    height: 30
                    width: height
                    radius: width / 2
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }
    }

    Component {
        id: colorPreviewComponent
        Rectangle {
            property var paramType: null
            property var value: null
            implicitHeight: app.mediumFont
            implicitWidth: implicitHeight
            color: value
            radius: width / 4
        }
    }

    Component {
        id: buttonComponent
        Button {
            // just to suppress some warnings
            property var paramType: null
            property var value: null
            text: "Do it"
            onClicked: {
                var params = [];
                for (var i = 0; i < root.actionType.paramTypes.count; i++) {
                    var param = new Object();
                    param["paramTypeId"] = root.actionType.paramTypes.get(i).id;
                    param["value"] = paramRepeater.itemAt(i).item.value;
                    params.push(param)
                }

                root.executeAction(params)
            }
        }
    }
}
