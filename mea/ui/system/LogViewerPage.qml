import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Mea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: "Log viewer"
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/go-down.svg"
            color: root.autoScroll ? app.guhAccent : keyColor
            onClicked: root.autoScroll = !root.autoScroll
        }
    }

    property bool autoScroll: true

    LogsModel {
        id: logsModel
        startTime: {
            var date = new Date();
            date.setHours(new Date().getHours() - 1);
            return date;
        }
        endTime: new Date()
        live: true
        Component.onCompleted: update()
        onCountChanged: {
            if (root.autoScroll) {
                listView.positionViewAtEnd()
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: listView
        visible: logsModel.busy
    }

    ListView {
        id: listView
        model: logsModel
        anchors.fill: parent
        clip: true
        headerPositioning: ListView.OverlayHeader

        property int column0Width: root.width / 10 * 2
        property int column1Width: root.width / 10 * 1
        property int column2Width: root.width / 10 * 3
        property int column3Width: root.width / 10 * 3
        property int column4Width: root.width / 10 * 1

        header: Rectangle {
            width: parent.width
            height: app.margins * 3
            color: "white"
            z: 2

            Row {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    width: listView.column0Width
                    text: "Time"
                }
                Label {
                    text: "Type"
                    width: listView.column1Width
                }

                Label {
                    width: listView.column2Width
                    text: "Thing"
                }
                Label {
                    width: listView.column3Width
                    text: "Object"
                }
                Label {
                    width: listView.column4Width
                    text: "Value"
                }
            }
            ThinDivider {
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
            }
        }

        delegate: Row {
            id: delegate
            property var device: Engine.deviceManager.devices.getDevice(model.deviceId)
            property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
            Label {
                width: listView.column0Width
                text: width > 130 ? Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss") : Qt.formatDateTime(model.timestamp,"hh:mm:ss")
                elide: Text.ElideRight
            }
            Label {
                width: listView.column1Width
                text: {
                    switch (model.source) {
                    case LogEntry.LoggingSourceStates:
                        return "SC";
                    case LogEntry.LoggingSourceSystem:
                        return "SYS";
                    case LogEntry.LoggingSourceActions:
                        return "AE";
                    case LogEntry.LoggingSourceEvents:
                        return "E";
                    case LogEntry.LoggingSourceRules:
                        return "R";
                    }

//                    switch (model.loggingEventType) {
//                    case LogEntry.LoggingEventTypeTrigger:
//                        return "T";
//                    case LogEntry.LoggingEventTypeExitActionsExecuted:
//                        return "A";
//                    case LogEntry.LoggingEventTypeActiveChange:
//                        return "R";
//                    case LogEntry.LoggingEventTypeExitActionsExecuted:
//                        return "EA";
//                    case LogEntry.LoggingEventTypeEnabledChange:
//                        return "E";
//                    }
                    return "N/A";
                }
            }

            Label {
                width: listView.column2Width
                text: model.source === LogEntry.LoggingSourceSystem ? "Nymea Server" : delegate.device.name
                elide: Text.ElideRight
            }
            Label {
                width: listView.column3Width
                text : {
                    switch (model.source) {
                    case LogEntry.LoggingSourceStates:
                        return delegate.deviceClass.stateTypes.getStateType(model.typeId).displayName;
                    case LogEntry.LoggingSourceSystem:
                        return model.loggingEventType === LogEntry.LoggingEventTypeActiveChange ? "Active changed" : "FIXME"
                    case LogEntry.LoggingSourceActions:
                        return delegate.deviceClass.actionTypes.getActionType(model.typeId).displayName;
                    case LogEntry.LoggingSourceEvents:
                        return delegate.deviceClass.eventTypes.getEventType(model.typeId).displayName;
                    case LogEntry.LoggingSourceRules:
                        return Engine.ruleManager.rules.getRule(model.typeId).name;
                    }
                    return "N/A";
                }
                elide: Text.ElideRight
            }
            Label {
                width: listView.column4Width
                text: model.value
                elide: Text.ElideRight
            }
        }
    }
}
