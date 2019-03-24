import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

ItemDelegate {
    id: root

    property ParamType paramType: null
    property alias value: d.value
    property Param param: Param {
        id: d
        paramTypeId: paramType.id
        value: paramType.defaultValue
    }
    property bool writable: true
    property alias nameVisible: nameLabel.visible
    property string placeholderText: ""

    topPadding: 0
    bottomPadding: 0
    contentItem: ColumnLayout {
        id: contentItemColumn
        RowLayout {
            Label {
                id: nameLabel
                Layout.fillWidth: true
                Layout.minimumWidth: parent.width / 2
                text: root.paramType.displayName
                elide: Text.ElideRight
            }
            Loader {
                id: loader
                Layout.fillWidth: sourceComponent === textFieldComponent
                sourceComponent: {
                    print("loading paramdelegate:", root.writable, root.paramType.type)
                    if (!root.writable) {
                        return stringComponent;
                    }

                    switch (root.paramType.type.toLowerCase()) {
                    case "bool":
                        return boolComponent;
                    case "uint":
                    case "int":
                    case "double":
                        if (root.paramType.minValue && root.paramType.maxValue) {
                            return sliderComponent;
                        } else {
                            return spinnerComponent;
                        }
                    case "string":
                    case "qstring":
                        if (root.paramType.allowedValues.length > 0) {
                            return comboBoxComponent;
                        }
                        return textFieldComponent;
                    case "color":
                        return colorPreviewComponent;
                    }
                    console.warn("Param Delegate: Fallback to stringComponent", root.paramType.name, root.paramType.type)
                    return stringComponent;
                }
            }
        }
        Loader {
            Layout.fillWidth: true
            sourceComponent: {
                switch (root.paramType.type.toLowerCase()) {
//                case "int":
//                case "double":
//                    if (root.paramType.minValue !== undefined && root.paramType.maxValue !== undefined) {
//                        return sliderComponent
//                    }
//                    break;
                case "color":
                    return colorPickerComponent
                }
                return null;
            }
        }
    }

    Component {
        id: stringComponent
        Label {
            text: {
                switch (root.paramType.type.toLowerCase()) {
                case "int":
                    return Math.round(root.param.value);
                }
                return root.param.value;
            }
        }
    }
    Component {
        id: boolComponent
        Switch {
            checked: root.param.value === true
            Component.onCompleted: {
                if (root.param.value === undefined) {
                    root.param.value = checked;
                }
            }

            onClicked: {
                root.param.value = checked;
            }
        }
    }
    Component {
        id: sliderComponent
        RowLayout {
            spacing: app.margins
            Slider {
                id: slider
                Layout.fillWidth: true
                from: root.paramType.minValue
                to: root.paramType.maxValue
                value: root.param.value
                stepSize: {
                    var ret = 1
                    for (var i = 0; i < decimals; i++) {
                        ret /= 10;
                    }
                    return ret;
                }
                property int decimals: root.paramType.type.toLocaleLowerCase() === "int" ? 0 : 1

                onMoved: {
                    var newValue
                    switch (root.paramType.type.toLowerCase()) {
                    case "int":
                        newValue = Math.round(value)
                        break;
                    default:
                        newValue = Math.round(value * 10) / 10
                    }
                    root.param.value = newValue;
                }
            }
            Label {
                text: root.param.value.toFixed(slider.decimals) + root.paramType.unitString
            }
        }

    }

    Component {
        id: spinnerComponent
        SpinBox {
            value: root.param.value ? root.param.value : 0
            from: root.paramType.minValue
                  ? root.paramType.minValue
                  : root.paramType.type.toLowerCase() === "uint"
                    ? 0
                    : -2000000000
            to: root.paramType.maxValue
                ? root.paramType.maxValue
                : 2000000000
            editable: true
            width: 150
            onValueModified: root.param.value = value
            textFromValue: function(value) {
                return value
            }
            Component.onCompleted: {
                if (root.value === undefined) {
                    root.value = value
                }
            }
        }
    }

    Component {
        id: textFieldComponent
        TextField {
            text: root.param.value !== undefined
                  ? root.param.value
                  : root.paramType.defaultValue
                    ? root.paramType.defaultValue
                    : ""
            onEditingFinished: {
                root.param.value = text
            }
            Component.onCompleted: {
                if (root.param.value === undefined) {
                    root.param.value = text;
                }
            }
            placeholderText: root.placeholderText
        }
    }

    Component {
        id: comboBoxComponent
        ComboBox {
            model: root.paramType.allowedValues
            currentIndex: root.paramType.allowedValues.indexOf(root.param.value)
            onActivated: {
                root.param.value = root.paramType.allowedValues[index]
                print("setting value to", root.param.value)
            }
            Component.onCompleted: {
                if (root.value === undefined) {
                    root.value = model[0]
                }
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
                value: root.param.value
                when: !colorPicker.pressed
            }

            onColorChanged: {
                root.param.value = color;
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
            implicitHeight: app.mediumFont
            implicitWidth: implicitHeight
            color: root.param.value
            radius: width / 4
        }
    }
}
