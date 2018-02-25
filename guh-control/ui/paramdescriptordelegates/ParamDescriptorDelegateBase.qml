import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Guh 1.0

ItemDelegate {
    id: root

    property var paramType: null
    property var value: null
    property int operatorType: ParamDescriptors.ValueOperatorEquals

    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            spacing: app.margins
            Label {
                text: paramType.displayName
            }
            ComboBox {
                Layout.fillWidth: true
                model: {
                    switch (paramType.type) {
                    case "Bool":
                    case "String":
                        return ["is", "is not"];
                    case "Int":
                    case "Double":
                        return ["is", "is not", "is greater", "is smaller", "is greater or equal", "is smaller or equal"]
                    }
                }
                onCurrentTextChanged: {
                    switch (currentText) {
                    case "is":
                        root.operatorType = ParamDescriptor.ValueOperatorEquals;
                        break;
                    case "is not":
                        root.operatorType = ParamDescriptor.ValueOperatorNotEquals;
                        break;
                    case "is greater":
                        root.operatorType = ParamDescriptor.ValueOperatorGreater;
                        break;
                    case "is smaller":
                        root.operatorType = ParamDescriptor.ValueOperatorLess;
                        break;
                    case "is greater or equal":
                        root.operatorType = ParamDescriptor.ValueOperatorGreaterOrEqual;
                        break;
                    case "is smaller or equal":
                        root.operatorType = ParamDescriptor.ValueOperatorLessOrEqual;
                        break;
                    }
                    print("set operator to", root.operatorType, currentText)
                }
            }


            Loader {
                id: placeHolder
                Layout.fillWidth: true

                sourceComponent: {
                    print("Datatye is:", paramType.type, paramType.minValue, paramType.maxValue)
                    switch (paramType.type) {
                    case "Bool":
                        return boolComponent;
                    case "Int":
                    case "Double":
                        if (paramType.minValue !== undefined && paramType.maxValue !== undefined) {
                            return labelComponent;
                        }
                        return textFieldComponent;
                    case "String":
                        if (paramType.allowedValues.length > 0) {
                            return comboBoxComponent
                        }
                        return textFieldComponent;
                    }
                    console.warn("ParamDescriptorDelegate: Type delegate not implemented", paramType.type)
                    return null;
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            sourceComponent: {
                switch (paramType.type) {
                case "Int":
                case "Double":
                    if (paramType.minValue !== undefined && paramType.maxValue !== undefined) {
                        return sliderComponent
                    }

                }
            }
        }

    }

    Component {
        id: labelComponent
        Label {
            text: {
                switch (root.paramType.type) {
                case "Int":
                    return Math.round(root.value)
                }
                return root.value
            }
        }
    }

    Component {
        id: textFieldComponent
        TextField {
            text: ""
            onTextChanged: {
                root.value = text;
            }
        }
    }

    Component {
        id: sliderComponent
        RowLayout {
            spacing: app.margins
            Label { text: root.paramType.minValue }
            Slider {
                from: paramType.minValue
                to: paramType.maxValue
                Layout.fillWidth: true
                onMoved: {
                    root.value = value;
                }
            }
            Label { text: root.paramType.maxValue  }
        }

    }

    Component {
        id: boolComponent
        ComboBox {
            model: ListModel {
                ListElement { modelData: "true"; value: true }
                ListElement { modelData: "false"; value: false }
            }
            onCurrentIndexChanged: {
                root.value = model.get(currentIndex).value
            }
        }
    }

    Component {
        id: comboBoxComponent
        ComboBox {
            model: paramType.allowedValues
            currentIndex: root.paramType.value
            onActivated: {
                root.value = paramType.allowedValues[index]
            }
        }
    }
}
