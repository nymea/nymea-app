import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Log viewer")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/go-down.svg"
            color: root.autoScroll ? app.accentColor : keyColor
            onClicked: {
                listView.positionViewAtEnd();
                root.autoScroll = !root.autoScroll
            }
        }
    }

    property bool autoScroll: true

    LogsModel {
        id: logsModel
        engine: _engine
        startTime: {
            var date = new Date();
            date.setHours(new Date().getHours() - 2);
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

        onDraggingChanged: {
            if (dragging) {
                root.autoScroll = false;
            }
        }

        ScrollBar.vertical: ScrollBar {}

        onContentYChanged: {
            if (!logsModel.busy && contentY - originY < 5 * height) {
                logsModel.fetchEarlier(1)
            }
        }

        delegate: ItemDelegate {
            id: delegate
            width: parent.width
            property var device: engine.deviceManager.devices.getDevice(model.deviceId)
            property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            contentItem: RowLayout {
                id: contentColumn
                anchors { left: parent.left; right: parent.right; margins: app.margins / 2 }
                ColorIcon {
                    Layout.preferredWidth: app.iconSize
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    color: {
                        switch (model.source) {
                        case LogEntry.LoggingSourceStates:
                        case LogEntry.LoggingSourceSystem:
                        case LogEntry.LoggingSourceActions:
                        case LogEntry.LoggingSourceEvents:
                            return app.accentColor
                        case LogEntry.LoggingSourceRules:
                            if (model.loggingEventType === LogEntry.LoggingEventTypeActiveChange) {
                                return model.value === true ? "green" : keyColor
                            }
                            return app.accentColor
                        }
                    }
                    name: {
                        switch (model.source) {
                        case LogEntry.LoggingSourceStates:
                            return "../images/state.svg"
                        case LogEntry.LoggingSourceSystem:
                            return "../images/system-shutdown.svg"
                        case LogEntry.LoggingSourceActions:
                            return "../images/action.svg"
                        case LogEntry.LoggingSourceEvents:
                            return "../images/event.svg"
                        case LogEntry.LoggingSourceRules:
                            return "../images/magic.svg"
                        }
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: model.source === LogEntry.LoggingSourceSystem ?
                                      qsTr("%1 Server").arg(app.systemName)
                                    : model.source === LogEntry.LoggingSourceRules ?
                                          engine.ruleManager.rules.getRule(model.typeId).name
                                        : delegate.device.name
                            elide: Text.ElideRight
                        }
                        Label {
                            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss")
                            elide: Text.ElideRight
                            font.pixelSize: app.smallFont
                        }
                    }
                    Label {
                        text : {
                            switch (model.source) {
                            case LogEntry.LoggingSourceStates:
                                return "%1 -> %2".arg(delegate.deviceClass.stateTypes.getStateType(model.typeId).displayName).arg(model.value);
                            case LogEntry.LoggingSourceSystem:
                                return model.loggingEventType === LogEntry.LoggingEventTypeActiveChange ? qsTr("System started") : "N/A"
                            case LogEntry.LoggingSourceActions:
                                return "%1 (%2)".arg(delegate.deviceClass.actionTypes.getActionType(model.typeId).displayName).arg(model.value);
                            case LogEntry.LoggingSourceEvents:
                                return "%1 (%2)".arg(delegate.deviceClass.eventTypes.getEventType(model.typeId).displayName).arg(model.value);
                            case LogEntry.LoggingSourceRules:
                                switch (model.loggingEventType) {
                                case LogEntry.LoggingEventTypeTrigger:
                                    return qsTr("Rule triggered");
                                case LogEntry.LoggingEventTypeActionsExecuted:
                                    return qsTr("Actions executed");
                                case LogEntry.LoggingEventTypeActiveChange:
                                    return model.value === true ? qsTr("Rule active") : qsTr("Rule inactive")
                                case LogEntry.LoggingEventTypeExitActionsExecuted:
                                    return qsTr("Exit actions executed");
                                case LogEntry.LoggingEventTypeEnabledChange:
                                    return qsTr("Enabled changed");
                                default:
                                    print("Unhandled logging event type", model.loggingEventType)
                                }
                                return "N/A"
                            default:
                                print("unhandled logging source:", model.source)
                            }
                            return "N/A";
                        }
                        elide: Text.ElideRight
                        font.pixelSize: app.smallFont
                    }
                }
            }
        }
    }
}
