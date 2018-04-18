import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "../components"
import "../paramdelegates"

Page {
    id: root

    property var device
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)
    property bool readOnly: true

    header: GuhHeader {
        text: "Details for " + root.device.name
        onBackPressed: pageStack.pop()
    }
    Flickable {
        anchors.fill: parent
        contentHeight: statesColumn.height + app.margins*2

        ColumnLayout {
            id: statesColumn
            anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
            spacing: app.margins

            Repeater {
                model: deviceClass.stateTypes
                delegate: RowLayout {
                    width: parent.width
                    height: app.largeFont

                    property var stateType: deviceClass.stateTypes.get(index)

                    Label {
                        id: stateLabel
                        Layout.preferredWidth: parent.width / 2
                        text: displayName
                    }

                    Loader {
                        id: placeHolder
                        Layout.fillWidth: true
                        sourceComponent: {
                            var writable = deviceClass.actionTypes.getActionType(id) !== null;
                            if (root.readOnly || !writable) {
                                return labelComponent;
                            }

                            switch (stateType.type) {
                            case "Bool":
                                return boolComponent;
                            case "Int":
                            case "Double":
                                if (stateType.minValue !== undefined && stateType.maxValue !== undefined) {
                                    return sliderComponent;
                                }
                                return textFieldComponent;
                            case "String":
                                return textFieldComponent;
                            case "Color":
                                return colorPreviewComponent;
                            }
                            console.warn("DeviceStateDetailsPage: Type delegate not implemented", stateType.type)
                            return null;
                        }
                    }

                    ColorIcon {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        name: "../images/info.svg"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageStack.push(Qt.resolvedUrl("StateLogPage.qml"),
                                                      {device: root.device, stateType: stateType})
                        }
                    }

                    Binding {
                        target: placeHolder.item
                        when: placeHolder.item
                        property: "value"
                        value: device.states.getState(id).value
                    }
//                    Binding {
//                        target: placeHolder.item
//                        when: placeHolder.item
//                        property: "enabled"
//                        value: deviceClass.actionTypes.getActionType(id) !== null
//                    }
                    Binding {
                        target: placeHolder.item
                        when: placeHolder.item
                        property: "stateTypeId"
                        value: id
                    }

    //                Label {
    //                    id: valueLable
    //                    Layout.fillWidth: true
    //                    text: device.states.getState(id).value + " " + deviceClass.stateTypes.getStateType(id).unitString
    //                }
                }
            }
        }
    }


    Component {
        id: labelComponent
        Label {
            property var value: ""
            property var stateTypeId: null
            text: value + " " + deviceClass.stateTypes.getStateType(stateTypeId).unitString
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component {
        id: textFieldComponent
        TextField {
            property var value: ""
            property var stateTypeId: null
            text: value
            onEditingFinished: {
                executeAction(stateTypeId, text)
            }
        }
    }

    Component {
        id: boolComponent
        Switch {
            property var value: false
            property var stateTypeId: null
            checked: value
            onClicked: executeAction(stateTypeId, checked)
        }
    }

    Component {
        id: colorPreviewComponent
        Rectangle {
            property var value: "blue"
            property var stateTypeId: null
            color: value
            implicitHeight: app.mediumFont
            implicitWidth: height
            radius: height / 4
        }
    }

    function executeAction(stateTypeId, value) {
        var paramList = []
        var muteParam = {}
        muteParam["paramTypeId"] = stateTypeId;
        muteParam["value"] = value;
        paramList.push(muteParam)
        Engine.deviceManager.executeAction(root.device.id, stateTypeId, paramList)
    }
}
