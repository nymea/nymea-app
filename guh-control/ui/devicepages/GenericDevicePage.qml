import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "../components"

DevicePageBase {
    id: root

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: contentColumn.height
        contentWidth: parent.width

        clip: true

        property var d: root.device
        property var dc: root.deviceClass

        ColumnLayout {
            id: contentColumn
            width: parent.width
//            spacing: app.margins

            Repeater {
                id: interfaceViewsRepeater
                property bool unhandledInterface: false

                model: deviceClass.interfaces
                delegate: Loader {
                    id: stateViewLoader
                    Layout.fillWidth: true
                    source: {
                        var src = "";
                        var options = []
                        switch (modelData) {
                        case "weather":
                            src = "WeatherView.qml";
                            break;
                        case "mediacontroller":
                            src = "MediaControllerView.qml"
                            break;
                        case "extendedvolumecontroller":
                            src = "ExtendedVolumeController.qml"
                            break;
                        case "temperaturesensor":
                        case "humiditysensor":
                            src = "SensorView.qml"
                            options.interfaceName = modelData;
                            break;
                        case "notifications":
                            src = "NotificationsView.qml"
                            break;
                        case "battery":
                        case "connectable":
                            // Handled by our base class
                            break;
                        case "sensor":
                        case "media":
                            // Ignore interfaces without any states/actions
                            break;
                        default:
                            print("unhandled interface", modelData)
                            interfaceViewsRepeater.unhandledInterface = true
                        }

                        return Qt.resolvedUrl("../customviews/" + src);
                    }
                    Binding {
                        target: stateViewLoader.item ? stateViewLoader.item : null
                        property: "device"
                        value: device
                    }
                    Binding {
                        target: stateViewLoader.item ? stateViewLoader.item : null
                        property: "deviceClass"
                        value: deviceClass
                    }
                    Binding {
                        target: stateViewLoader.item ? stateViewLoader.item : null
                        property: "interfaceName"
                        value: modelData
                    }
                }
            }


            Repeater {
                model: interfaceViewsRepeater.count == 0 || interfaceViewsRepeater.unhandledInterface ? deviceClass.actionTypes : null
                delegate: ItemDelegate {
                    Layout.fillWidth: true
                    Layout.preferredHeight: delegateLoader.height

                    Loader {
                        id: delegateLoader
                        width: parent.width
                        property var actionType: deviceClass.actionTypes.get(index)
                        property var actionValue: device.hasState(actionType.id) ? device.states.getState(actionType.id).value : null
                        source: {
                            print("actiontype is", actionType.name, actionValue, actionType.paramTypes.count)
                            for (var i = 0; i < actionType.paramTypes.count; i++) {
                                print("have actionType param:", actionType.paramTypes.get(i).name, actionType.paramTypes.get(i).type)
                            }

                            var delegate = "ActionDelegateFallback.qml";
                            if (actionType.paramTypes.count === 0) {
                                delegate = "ActionDelegateNoParams.qml";
                            } else if (actionType.paramTypes.count === 1) {
                                var paramType = actionType.paramTypes.get(0)
                                if (paramType.type === "Int" && paramType.minValue !== null && paramType.maxValue !== null) {
                                    delegate = "ActionDelegateSlider.qml";
                                } else if (paramType.type === "Bool") {
                                    delegate = "ActionDelegateBool.qml";
                                } else if (paramType.type === "Color") {
                                    delegate = "ActionDelegateColor.qml";
                                } else if (paramType.type === "String" && paramType.allowedValues.length > 0) {
                                    delegate = "ActionDelegateStringFromStringList.qml";
                                }
                            }
                            return Qt.resolvedUrl("../actiondelegates/" + delegate);
                        }

                        Binding {
                            target: delegateLoader.item ? delegateLoader.item : null
                            property: "actionType"
                            value: delegateLoader.actionType
                        }
                        Binding {
                            target: delegateLoader.item ? delegateLoader.item : null
                            property: "actionState"
                            value: delegateLoader.actionValue
                        }

                        property int commandId: 0
                        Connections {
                            target: delegateLoader.item ? delegateLoader.item : null
                            onExecuteAction: {
                                delegateLoader.commandId = Engine.deviceManager.executeAction(root.device.id, model.id, params)
                            }
                        }
                        Connections {
                            target: Engine.jsonRpcClient
                            onResponseReceived: {
                                if (commandId == delegateLoader.commandId) {
                                    print("response:", response["error"])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
