// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

ItemDelegate {
    id: root

    property var actionType: null
    property var actionState: null

    signal executeAction(var params)

    readonly property bool multiParam: actionType.paramTypes.count > 1

    contentItem: ColumnLayout {
        RowLayout {
            Label {
                Layout.fillWidth: true
                text: root.actionType.displayName
                elide: Text.ElideRight
                visible: loader.sourceComponent != buttonComponent
            }
            Loader {
                id: loader
                Layout.fillWidth: sourceComponent == textFieldComponent || sourceComponent == buttonComponent
                sourceComponent: {
                    if (root.multiParam || root.actionType.paramTypes.count === 0) {
                        return buttonComponent
                    }

                    var paramType = root.actionType.paramTypes.get(0);
                    switch (paramType.type.toLowerCase()) {
                    case "bool":
                        return boolComponent;
                    case "double":
                    case "int":
                        if (paramType.minValue === undefined || paramType.maxValue === undefined) {
                            return textFieldComponent
                        }
                        return stringComponent;
                    case "string":
                    case "qstring":
                        if (paramType.allowedValues.length > 0) {
                            return comboBoxComponent;
                        }
                        return buttonComponent;
//                        return textFieldComponent;
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
                        if (paramType.minValue !== undefined && paramType.maxValue !== undefined) {
                            if (root.multiParam) {
                                return labelledSpinnerComponent;
                            }
                            return sliderComponent
                        }
                        return textFieldComponent;
                    case "color":
                        return colorPickerComponent
                    case "string":
                        return paramType.allowedValues.length === 0 ? textFieldComponent :
                                                                      root.actionType.paramTypes.count === 1 ? null : comboBoxComponent
                    case "bool":
                        if (root.multiParam) {
                            return labeledBoolComponent;
                        }
                        return null
                    }
                    console.warn("WARNING", paramType.name, "of type", paramType.type, "not implemented")
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
                    when: bottomLoader.item
                    property: "value"
                    value: (root.actionState && index == 0) ? root.actionState : root.actionType.paramTypes.get(index).defaultValue
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
                var param1 = {};
                param1["paramTypeId"] = root.actionType.paramTypes.get(0).id;
                param1["value"] = checked;
                params.push(param1)
                root.executeAction(params)
            }
        }
    }

    Component {
        id: labeledBoolComponent
        RowLayout {
            id: switchRow
            property var paramType: null
            property var value

            Label {
                text: paramType.displayName
                Layout.fillWidth: true
            }
            Switch {
                checked: paramType.defaultValue
                onClicked: {
                    switchRow.value = checked;
                }
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
        id: labelledSpinnerComponent
        RowLayout {
            id: sliderRow
            property var paramType: null
            property var value: null
            Label {
                text: sliderRow.paramType.displayName
                Layout.fillWidth: true
            }
            SpinBox {
                from: sliderRow.paramType.minValue
                to: sliderRow.paramType.maxValue
                value: sliderRow.value
                editable: true
                onValueModified: {
                    sliderRow.value = value
                }
            }
        }
    }

    Component {
        id: textFieldComponent
        RowLayout {
            id: textFieldRow
            property alias value: textField.text
            property var paramType: null
            spacing: app.margins
            Label {
                text: paramType.displayName
            }

            TextField {
                id: textField
                Layout.fillWidth: true
                onAccepted: value = text
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
            text: root.actionType.displayName
            onClicked: {
                print("ActionDelegate: Button clicked")
                var params = [];
                print("fooo", root.actionType.paramTypes.count)
                for (var i = 0; i < root.actionType.paramTypes.count; i++) {
                    var param = {};
                    param["paramTypeId"] = root.actionType.paramTypes.get(i).id;
                    print("bla", paramRepeater.itemAt(i), paramRepeater.itemAt(i).item, paramRepeater.itemAt(i).item.value)
                    param["value"] = paramRepeater.itemAt(i).item.value;
                    params.push(param)
                }

                root.executeAction(params)
            }
        }
    }
}
