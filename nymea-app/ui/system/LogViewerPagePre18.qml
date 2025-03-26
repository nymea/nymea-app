/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Log viewer")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/down.svg"
            color: root.autoScroll ? Style.accentColor : Style.iconColor
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
        live: true
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

        BusyIndicator {
            anchors.centerIn: parent
            visible: listView.model.busy
        }

        delegate: ItemDelegate {
            id: delegate
            width: parent.width
            property Thing thing: engine.thingManager.things.getThing(model.thingId)
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            contentItem: RowLayout {
                id: contentColumn
                anchors { left: parent.left; right: parent.right; margins: app.margins / 2 }
                ColorIcon {
                    Layout.preferredWidth: Style.iconSize
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    color: {
                        switch (model.source) {
                        case LogEntry.LoggingSourceStates:
                        case LogEntry.LoggingSourceSystem:
                        case LogEntry.LoggingSourceActions:
                        case LogEntry.LoggingSourceEvents:
                            return Style.accentColor
                        case LogEntry.LoggingSourceRules:
                            if (model.loggingEventType === LogEntry.LoggingEventTypeActiveChange) {
                                return model.value === true ? "green" : Style.iconColor
                            }
                            return Style.accentColor
                        }
                    }
                    name: {
                        switch (model.source) {
                        case LogEntry.LoggingSourceStates:
                            return "qrc:/icons/state.svg"
                        case LogEntry.LoggingSourceSystem:
                            return "qrc:/icons/system-shutdown.svg"
                        case LogEntry.LoggingSourceActions:
                            return "qrc:/icons/action.svg"
                        case LogEntry.LoggingSourceEvents:
                            return "qrc:/icons/event.svg"
                        case LogEntry.LoggingSourceRules:
                            return "qrc:/icons/magic.svg"
                        }
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: model.source === LogEntry.LoggingSourceSystem ?
                                      qsTr("%1 Server").arg(Configuration.systemName)
                                    : model.source === LogEntry.LoggingSourceRules ?
                                          engine.ruleManager.rules.getRule(model.typeId).name
                                        : delegate.thing.name
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
                                var stateType = delegate.thing.thingClass.stateTypes.getStateType(model.typeId);
                                return "%1 -> %2 %3".arg(stateType.displayName).arg(Types.toUiValue(model.value, stateType.unit)).arg(Types.toUiUnit(stateType.unit));
                            case LogEntry.LoggingSourceSystem:
                                return model.loggingEventType === LogEntry.LoggingEventTypeActiveChange ? qsTr("System started") : "N/A"
                            case LogEntry.LoggingSourceActions:
                                return "%1 (%2)".arg(delegate.thing.thingClass.actionTypes.getActionType(model.typeId).displayName).arg(model.value);
                            case LogEntry.LoggingSourceEvents:
                                return "%1 (%2)".arg(delegate.thing.thingClass.eventTypes.getEventType(model.typeId).displayName).arg(model.value);
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
