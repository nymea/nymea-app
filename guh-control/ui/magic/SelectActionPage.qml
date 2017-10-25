import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "../components"
import "../actiondelegates"

Page {
    id: root

    // input
    property string text

    // output
    property var device: null
    property var actionType: null
    property var params: []
    signal complete();

    header: GuhHeader {
        text: "Select action"
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        spacing: app.margins

        Label {
            text: root.text
            Layout.fillWidth: true
        }

        Button {
            text: "control a certain device"
            Layout.fillWidth: true
            onClicked: {
                pageStack.push(selectDeviceComponent)
            }
        }
        Button {
            text: "control a group of devices"
            Layout.fillWidth: true
        }
    }

    Component {
        id: selectDeviceComponent
        Page {
            header: GuhHeader {
                text: "Select device"
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                ListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: Engine.deviceManager.devices
                    delegate: ItemDelegate {
                        width: parent.width
                        Label {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            text: model.name
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            root.device = Engine.deviceManager.devices.get(index)
                            var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(model.deviceClassId)
                            pageStack.push(selectDeviceActionComponent, {deviceClass: deviceClass})
                        }
                    }
                }
            }
        }
    }

    Component {
        id: selectDeviceActionComponent
        Page {
            id: page
            property var deviceClass

            header: GuhHeader {
                text: "Select action"
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                ListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: page.deviceClass.actionTypes

                    delegate: ItemDelegate {
                        width: parent.width
                        Label {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            text: model.name
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            root.actionType = page.deviceClass.actionTypes.get(index)
                            if (page.deviceClass.actionTypes.get(index).paramTypes.count == 0) {
                                // We're all set.
                                root.complete();
                            } else {
                                // need to fill in params
                                var actionType = page.deviceClass.actionTypes.get(index)
                                pageStack.push(selectDeviceActionParamComponent, {actionType: actionType})
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: selectDeviceActionParamComponent
        Page {
            id: page
            property var actionType
            header: GuhHeader {
                text: "params"
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                Repeater {
                    id: delegateRepeater
                    model: page.actionType.paramTypes
                    ItemDelegate {
                        id: paramDelegate
                        Layout.fillWidth: true
                        property var paramType: page.actionType.paramTypes.get(index)
                        property var value: paramType.defaultValue
                        RowLayout {
                            anchors.fill: parent
                            Label {
                                Layout.fillWidth: true
                                text: paramDelegate.paramType.name
                            }
                            Switch {
                                checked: paramDelegate.value
                                onClicked: paramDelegate.value = checked
                            }
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Button {
                    text: "OK"
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    onClicked: {
                        for (var i = 0; i < delegateRepeater.count; i++) {
                            var paramDelegate = delegateRepeater.itemAt(i);
                            var param = {}
                            param["paramTypeId"] = paramDelegate.paramType.id
                            param["value"] = paramDelegate.value
                            root.params.push(param)
                        }
                        root.complete()
                    }
                }
            }
        }
    }
}
