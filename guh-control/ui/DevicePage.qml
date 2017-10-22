import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "components"

Page {
    id: root
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)


    header: GuhHeader {
        text: device.name
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "images/info.svg"
            onClicked: pageStack.push(deviceStateDetailsPage)
        }
    }

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

            Loader {
                id: stateViewLoader
                Layout.fillWidth: true
                source: {
                    var src = "";
                    print("**** devicetags", deviceClass.basicTags)
                    if (deviceClass.interfaces.indexOf("weather") >= 0) {
                        src = "customviews/WeatherView.qml";
                    }
                    if (deviceClass.interfaces.indexOf("mediacontroller") >= 0) {
                        src = "customviews/MediaControllerView.qml"
                    }
                    if (deviceClass.interfaces.indexOf("sensor") >= 0) {
                        src = "customviews/SensorView.qml"
                    }

                    return Qt.resolvedUrl(src);
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
            }


            Repeater {
                model: deviceClass.actionTypes
                delegate: ItemDelegate {
                    Layout.fillWidth: true
                    Layout.preferredHeight: delegateLoader.height

                    Loader {
                        id: delegateLoader
                        width: parent.width
                        property var actionType: deviceClass.actionTypes.get(index)
                        property var actionValue: device.hasState(actionType.id) ? device.states.getState(actionType.id).value : null
                        source: {
                            print("actiontyoe is", actionType.name, actionValue, actionType.paramTypes.count)
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
                            return Qt.resolvedUrl("actiondelegates/" + delegate);
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
                                delegateLoader.commandId = Engine.jsonRpcClient.executeAction(root.device.id, model.id, params)
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

    Component {
        id: deviceStateDetailsPage
        Page {
            header: GuhHeader {
                text: "Details for " + root.device.name
                onBackPressed: pageStack.pop()
            }
            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
                spacing: app.margins

                Repeater {
                    model: deviceClass.stateTypes
                    delegate: RowLayout {
                        width: parent.width
                        height: app.largeFont

                        Label {
                            id: stateLabel
                            Layout.preferredWidth: parent.width / 2
                            text: name
                        }

                        Label {
                            id: valueLable
                            Layout.fillWidth: true
                            text: device.states.getState(id).value + " " + deviceClass.stateTypes.getStateType(id).unitString
                        }
                    }
                }
            }
        }
    }
}
