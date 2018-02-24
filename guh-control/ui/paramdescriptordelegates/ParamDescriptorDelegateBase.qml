import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Guh 1.0

ItemDelegate {
    id: root
    height: layout.height

    property var paramType: null
    property var value: null
    property int operatorType: ParamDescriptors.ValueOperatorEquals

    RowLayout {
        id: layout
        anchors { left: parent.left; top: parent.top; right: parent.right}
        anchors.margins: app.margins
        spacing: app.margins
        Label {
            text: paramType.displayName
        }
        ComboBox {
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
                        return sliderComponent;
                    }
                    return textFieldComponent;
                }
                console.warn("ParamDescriptorDelegate: Type delegate not implemented", paramType.type)
                return null;
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
        Slider {
            from: paramType.minValue
            to: paramType.maxValue
            onMoved: {
                root.value = value;
            }
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
}
