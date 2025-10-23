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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

// Legacy for jsonrpc < 8.0

Page {
    id: root

    property Thing thing: null
    property alias device: root.thing
    property var filterTypeIds: []

    header: NymeaHeader {
        text: qsTr("History for %1").arg(root.thing.name)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/filters.svg"
            color: logsModelNg.filterEnabled ? Style.accentColor : Style.iconColor
            onClicked: logsModelNg.filterEnabled = !logsModelNg.filterEnabled
            visible: root.filterTypeIds.length === 0
        }
    }

    LogsModelNg {
        id: logsModelNg
        engine: _engine
        thingId: root.thing.id
        typeIds: root.filterTypeIds.length > 0
                 ? root.filterTypeIds
                 : filterEnabled
                   ? [filterDeviceModel.getData(filterComboBox.currentIndex, ThingModel.RoleId)]
                   : []
        live: true

        property bool filterEnabled: false
    }

    ThingModel {
        id: filterDeviceModel
        thing: root.thing
    }

    Pane {
        id: filterPane
        anchors { left: parent.left; top: parent.top; right: parent.right }
        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

        height: logsModelNg.filterEnabled ? implicitHeight + app.margins * 2 : 0
        Material.elevation: 1

        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        contentItem: Item {
            clip: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: app.margins
                spacing: app.margins
                Label {
                    text: qsTr("Filter by")
                }

                ComboBox {
                    id: filterComboBox
                    Layout.fillWidth: true
                    textRole: "displayName"
                    model: filterDeviceModel
                }
            }
        }
    }

    Loader {
        id: graphLoader
        anchors {
            left: parent.left
            top: filterPane.bottom
            right: parent.right
        }

        readonly property StateType stateType: root.thing.thingClass.stateTypes.getStateType(root.filterTypeIds[0])

        readonly property bool canShowGraph: {
            if (stateType === null) {
                return false
            }

            if (stateType.unit === Types.UnitUnixTime) {
                return false;
            }

            switch (stateType.type.toLowerCase()) {
            case "uint":
            case "int":
            case "double":
            case "bool":
                return true;
            }
            print("not showing graph for", stateType.type)
            return false;
        }

        Component.onCompleted: {
            if (root.filterTypeIds.length === 0) {
                return;
            }
            if (!canShowGraph) {
                return;
            }

            var source = Qt.resolvedUrl("../customviews/GenericTypeGraph.qml");
            setSource(source, {thing: root.thing, stateType: stateType})
        }
    }


    ListView {
        anchors { left: parent.left; top: graphLoader.bottom; right: parent.right; bottom: parent.bottom }
        clip: true
        model: logsModelNg
        ScrollBar.vertical: ScrollBar {}

        BusyIndicator {
            anchors.centerIn: parent
            visible: logsModelNg.busy
        }

        delegate: ItemDelegate {
            id: entryDelegate
            width: root.width

            property StateType stateType: model.source === LogEntry.LoggingSourceStates ? root.thing.thingClass.stateTypes.getStateType(model.typeId) : null
            property EventType eventType: model.source === LogEntry.LoggingSourceEvents ? root.thing.thingClass.eventTypes.getEventType(model.typeId) : null
            property ActionType actionType: model.source === LogEntry.LoggingSourceActions ? root.thing.thingClass.actionTypes.getActionType(model.typeId) : null

            contentItem: RowLayout {
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
                            text: {
                                switch (model.source) {
                                case LogEntry.LoggingSourceStates:
                                    return entryDelegate.stateType.displayName
                                case LogEntry.LoggingSourceEvents:
                                    return entryDelegate.eventType.displayName
                                case LogEntry.LoggingSourceActions:
                                    return entryDelegate.actionType.displayName
                                }
                            }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            font: Style.smallFont
                        }
                        Label {
                            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy hh:mm:ss")
                            elide: Text.ElideRight
                            font.pixelSize: app.smallFont
                            color: Style.mediumGray
                            enabled: true
                        }
                    }

                    RowLayout {
                        Loader {
                            id: valueLoader
                            Layout.fillWidth: true
                            sourceComponent: {
                                switch (model.source) {
                                case LogEntry.LoggingSourceStates:
                                    switch (entryDelegate.stateType.type.toLowerCase()) {
                                    case "bool":
                                        return boolComponent;
                                    case "color":
                                        return colorComponent
                                    case "double":
                                        return floatLabelComponent;
                                    default:
                                        if (entryDelegate.stateType.unit == Types.UnitUnixTime) {
                                            return dateTimeComponent
                                        }

                                        return labelComponent

                                    }
                                case LogEntry.LoggingSourceActions:
                                    return labelComponent;
                                case LogEntry.LoggingSourceEvents:

                                    break;
                                }

                                return labelComponent
                            }
                            Binding {
                                when: entryDelegate.stateType != null
                                target: valueLoader.item;
                                property: "value";
                                value: entryDelegate.stateType ? Types.toUiValue(model.value, entryDelegate.stateType.unit) : model.value
                            }
                            Binding {
                                when: entryDelegate.stateType != null
                                target: entryDelegate.stateType && valueLoader.item.hasOwnProperty("unitString") ? valueLoader.item : null;
                                property: "unitString"
                                value: entryDelegate.stateType ? Types.toUiUnit(entryDelegate.stateType.unit) : ""
                            }
                            Binding {
                                when: entryDelegate.actionType != null
                                target: valueLoader.item;
                                property: "value";
                                value: {
                                    if (entryDelegate.actionType == null) {
                                        return ""
                                    }

                                    var ret = ""
                                    var values = model.value.split(",")
                                    for (var i = 0; i < entryDelegate.actionType.paramTypes.count; i++) {
                                        var paramType = entryDelegate.actionType.paramTypes.get(i)
                                        ret += Types.toUiValue(values[i], paramType.unit) + " " + Types.toUiUnit(paramType.unit)
                                    }
                                    return ret
                                }
                            }
                            Binding {
                                when: entryDelegate.eventType != null
                                target: valueLoader.item;
                                property: "value";
                                value: {
                                    if (entryDelegate.eventType == null) {
                                        return ""
                                    }

                                    var ret = ""
                                    var values = model.value.split(",")
                                    for (var i = 0; i < entryDelegate.eventType.paramTypes.count; i++) {
                                        var paramType = entryDelegate.eventType.paramTypes.get(i)
                                        ret += Types.toUiValue(values[i], paramType.unit) + " " + Types.toUiUnit(paramType.unit)
                                    }
                                    return ret
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: labelComponent
        Label {
            property var value
            property string unitString
            text: value + " " + unitString
            font: Style.smallFont
            elide: Text.ElideRight
        }
    }

    Component {
        id: floatLabelComponent
        Label {
            property double value
            property string unitString
            text: value.toFixed(value > 1000 ? 0 : 2) + " " + unitString
            font: Style.smallFont
            elide: Text.ElideRight
        }
    }

    Component {
        id: dateTimeComponent
        Label {
            property var value
            font: Style.smallFont
            text: Qt.formatDateTime(new Date(value * 1000), Qt.DefaultLocaleShortDate)
        }
    }

    Component {
        id: boolComponent
        RowLayout {
            id: boolLed
            property var value
            Led {
                implicitHeight: app.smallFont
                state: boolLed.value === "true" ? "on" : "off"
            }
            Label {
                font: Style.smallFont
                text: boolLed.value === "true" ? qsTr("Yes") : qsTr("No")
                Layout.fillWidth: true
            }
        }
    }

    Component {
        id: colorComponent
        Item {
            property var value
            implicitHeight: app.smallFont
            Rectangle {
                height: parent.height
                width: height * 2
                color: parent.value
                //                radius: width / 2
                border.color: Style.foregroundColor
                border.width: 1
            }
        }
    }
}
