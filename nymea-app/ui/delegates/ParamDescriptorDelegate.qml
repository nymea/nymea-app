import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0

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
                    switch (paramType.type.toLowerCase()) {
                    case "bool":
                    case "string":
                    case "qstring":
                    case "color":
                        return [qsTr("is"), qsTr("is not")];
                    case "int":
                    case "double":
                        return [qsTr("is"), qsTr("is not"), qsTr("is greater"), qsTr("is smaller"), qsTr("is greater or equal"), qsTr("is smaller or equal")]
                    }
                }
                onCurrentTextChanged: {
                    switch (currentText) {
                    case qsTr("is"):
                        root.operatorType = ParamDescriptor.ValueOperatorEquals;
                        break;
                    case qsTr("is not"):
                        root.operatorType = ParamDescriptor.ValueOperatorNotEquals;
                        break;
                    case qsTr("is greater"):
                        root.operatorType = ParamDescriptor.ValueOperatorGreater;
                        break;
                    case qsTr("is smaller"):
                        root.operatorType = ParamDescriptor.ValueOperatorLess;
                        break;
                    case qsTr("is greater or equal"):
                        root.operatorType = ParamDescriptor.ValueOperatorGreaterOrEqual;
                        break;
                    case qsTr("is smaller or equal"):
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
                    print("Datatye is:", paramType.type, paramType.minValue, paramType.maxValue, paramType.allowedValues)
                    switch (paramType.type.toLowerCase()) {
                    case "bool":
                        return boolComponent;
                    case "int":
                    case "double":
                        if (paramType.minValue !== undefined && paramType.maxValue !== undefined) {
                            return labelComponent;
                        }
                        return textFieldComponent;
                    case "string":
                    case "qstring":
                    case "color":
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
                switch (paramType.type.toLowerCase()) {
                case "int":
                case "double":
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
                switch (root.paramType.type.toLowerCase()) {
                case "int":
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
            onCurrentIndexChanged: {
                root.value = paramType.allowedValues[currentIndex]
            }
        }
    }
}
