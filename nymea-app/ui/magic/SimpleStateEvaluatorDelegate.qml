// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"

SwipeDelegate {
    id: root
    Layout.fillWidth: true
    clip: true

    property StateEvaluator stateEvaluator: null
    property bool showChilds: false

    readonly property Thing thing: stateEvaluator ? engine.thingManager.things.getThing(stateEvaluator.stateDescriptor.thingId) : null
    readonly property Interface iface: stateEvaluator ? Interfaces.findByName(stateEvaluator.stateDescriptor.interfaceName) : null
    readonly property StateType stateType: thing ? thing.thingClass.stateTypes.getStateType(stateEvaluator.stateDescriptor.stateTypeId)
                                                 : iface ? iface.stateTypes.findByName(stateEvaluator.stateDescriptor.interfaceState) : null

    signal deleteClicked();

    Rectangle {
        anchors.fill: parent
        border.color: "black"
        border.width: 1
        color: "transparent"
    }

    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true
            ColorIcon {
                Layout.preferredHeight: childEvaluatorsRepeater.count > 0 ? Style.iconSize * .6 : Style.iconSize
                Layout.preferredWidth: height
                name: root.stateEvaluator && root.stateEvaluator.stateDescriptor.interfaceName.length === 0 ? "qrc:/icons/state.svg" : "qrc:/icons/state-interface.svg"
                color: Style.accentColor
            }

            Label {
                Layout.fillWidth: true
                font.pixelSize: childEvaluatorsRepeater.count > 0 ? app.smallFont : app.mediumFont
                wrapMode: Text.WordWrap
                property string operatorString: {
                    if (!root.stateEvaluator) {
                        return "";
                    }

                    switch (root.stateEvaluator.stateDescriptor.valueOperator) {
                    case StateDescriptor.ValueOperatorEquals:
                        return "=";
                    case StateDescriptor.ValueOperatorNotEquals:
                        return "!=";
                    case StateDescriptor.ValueOperatorGreater:
                        return ">";
                    case StateDescriptor.ValueOperatorGreaterOrEqual:
                        return ">=";
                    case StateDescriptor.ValueOperatorLess:
                        return "<";
                    case StateDescriptor.ValueOperatorLessOrEqual:
                        return "<=";
                    }
                    return "FIXME"
                }

                text: {
                    if (!root.stateType) {
                        return qsTr("Press to edit condition")
                    }

                    var valueText;
                    if (root.stateEvaluator.stateDescriptor.value !== undefined) {
                        valueText = root.stateEvaluator.stateDescriptor.value;
                        switch (root.stateType.type.toLowerCase()) {
                        case "bool":
                            valueText = root.stateEvaluator.stateDescriptor.value === true ? qsTr("Yes") : qsTr("No")
                            break;
                        }
                    } else {
                        print("value thing id:", root.stateEvaluator.stateDescriptor.valueThingId)
                        var valueThing = engine.thingManager.things.getThing(root.stateEvaluator.stateDescriptor.valueThingId)
                        valueText = valueThing.name
                        valueText += ", " + valueThing.thingClass.stateTypes.getStateType(root.stateEvaluator.stateDescriptor.valueStateTypeId).displayName
                    }

                    if (root.thing) {
                        return "%1: %2 %3 %4".arg(root.thing.name).arg(root.stateType.displayName).arg(operatorString).arg(valueText)
                    } else if (root.iface) {
                        return "%1, %2 %3 %4".arg(root.iface.displayName).arg(root.stateType.displayName).arg(operatorString).arg(valueText)
                    }
                    return "--";
                }
            }
        }

        Repeater {
            id: childEvaluatorsRepeater
            model: root.showChilds ? root.stateEvaluator.childEvaluators : null
            delegate: RowLayout {
                id: childEvaluatorDelegate
                Layout.fillWidth: true

                property var stateEvaluator: root.stateEvaluator.childEvaluators.get(index)
                property var stateDescriptor: stateEvaluator.stateDescriptor
                readonly property Thing thing: engine.thingManager.things.getThing(stateDescriptor.thingId)
                readonly property var iface: Interfaces.findByName(stateEvaluator.stateDescriptor.interfaceName)
                readonly property var stateType: thing ? thing.thingClass.stateTypes.getStateType(stateDescriptor.stateTypeId)
                                                        : iface ? iface.stateTypes.findByName(stateEvaluator.stateDescriptor.interfaceState)
                                                                : null

                ColorIcon {
                    Layout.preferredHeight: Style.iconSize * .6
                    Layout.preferredWidth: height
                    name: childEvaluatorDelegate.stateDescriptor.interfaceName.length === 0 ? "qrc:/icons/state.svg" : "qrc:/icons/state-interface.svg"
                    color: Style.accentColor
                }
                Label {
                    font.pixelSize: app.smallFont
                    Layout.fillWidth: true

                    property string operatorString: {
                        switch (childEvaluatorDelegate.stateDescriptor.valueOperator) {
                        case StateDescriptor.ValueOperatorEquals:
                            return "=";
                        case StateDescriptor.ValueOperatorNotEquals:
                            return "!=";
                        case StateDescriptor.ValueOperatorGreater:
                            return ">";
                        case StateDescriptor.ValueOperatorGreaterOrEqual:
                            return ">=";
                        case StateDescriptor.ValueOperatorLess:
                            return "<";
                        case StateDescriptor.ValueOperatorLessOrEqual:
                            return "<=";
                        }
                        return "FIXME"
                    }
                    text: thing ? ("%1 %2: %3 %4 %5%6").arg(root.stateEvaluator.stateOperator === StateEvaluator.StateOperatorAnd ? "and" : "or").arg(childEvaluatorDelegate.thing.name).arg(childEvaluatorDelegate.stateType.displayName).arg(operatorString).arg(childEvaluatorDelegate.stateDescriptor.value).arg(childEvaluatorDelegate.stateEvaluator.childEvaluators.count > 0 ? "..." : "")
                                 : iface ? ("%1 %2: %3 %4 %5%6").arg(root.stateEvaluator.stateOperator === StateEvaluator.StateOperatorAnd ? "and" : "or").arg(childEvaluatorDelegate.iface.displayName).arg(childEvaluatorDelegate.stateType.displayName).arg(operatorString).arg(childEvaluatorDelegate.stateDescriptor.value).arg(childEvaluatorDelegate.stateEvaluator.childEvaluators.count > 0 ? "..." : "")
                                         : "???"
                }
            }
        }
    }

    onPressAndHold: swipe.open(SwipeDelegate.Right)
    swipe.right: MouseArea {
        height: parent.height
        width: height
        anchors.right: parent.right
        Rectangle {
            anchors.fill: parent
            color: "red"
        }

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "qrc:/icons/delete.svg"
            color: "white"
        }
        onClicked: {
            swipe.close()
            root.deleteClicked();
        }
    }
}
