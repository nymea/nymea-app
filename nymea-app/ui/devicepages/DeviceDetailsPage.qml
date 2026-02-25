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
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Nymea

import "../components"
import "../delegates"

Page {
    id: root

    property Thing thing: null

    header: NymeaHeader {
        text: thing ? thing.name : ""
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }


    ListView {
        id: flickable
        anchors.fill: parent
        clip: true

        SwipeDelegateGroup {}

        section.property: "type"
        section.delegate: ListSectionHeader {
            text: {
                switch (parseInt(section)) {
                case ThingModel.TypeStateType:
                    return qsTr("States")
                case ThingModel.TypeEventType:
                    return qsTr("Events")
                }
            }
        }

        model: ThingModel {
            thing: root.thing
            showActions: false
        }
        delegate: SwipeDelegate {
            id: delegate
            width: parent.width

            readonly property StateType stateType: model.type === ThingModel.TypeStateType ? root.thing.thingClass.stateTypes.getStateType(model.id) : null
            readonly property EventType eventType: model.type === ThingModel.TypeEventType ? root.thing.thingClass.eventTypes.getEventType(model.id) : null

            Layout.fillWidth: true
            bottomPadding: 0

            contentItem: Loader {
                id: inlineLoader
                Layout.fillWidth: true
                Layout.preferredHeight: Style.smallDelegateHeight
                sourceComponent: {
                    switch (model.type) {
                    case ThingModel.TypeStateType:
                        return stateComponent;
                    case ThingModel.TypeEventType:
                        return eventComponent;
                    }
                }

                Binding {
                    target: inlineLoader.item
                    when: model.type === ThingModel.TypeStateType
                    property: "stateType"
                    value: delegate.stateType
                }
                Binding {
                    target: inlineLoader.item
                    when: model.type === ThingModel.TypeEventType
                    property: "eventType"
                    value: delegate.eventType
                }
            }
        }
    }

    Component {
        id: stateComponent
        RowLayout {
            id: stateDelegate
            property StateType stateType: null
            readonly property State thingState: stateType ? root.thing.states.getState(stateType.id) : null

            Label {
                Layout.fillWidth: true
                Layout.minimumWidth: parent.width / 2
                text: stateDelegate.stateType.displayName
                elide: Text.ElideRight
            }
            Loader {
                id: stateDelegateLoader
                Layout.fillWidth: true
            }
            Label {
                visible: text.length > 0 && stateDelegate.stateType.unit !== Types.UnitUnixTime
                text: Types.toUiUnit(stateDelegate.stateType.unit)
            }

            Component.onCompleted: updateLoader()
            onStateTypeChanged: updateLoader();

            function updateLoader() {
                if (stateDelegate.stateType == null) {
                    return;
                }

                var sourceComp;
                switch (stateDelegate.stateType.type.toLowerCase()) {
                case "string":
                    sourceComp = "LabelDelegate.qml";
                    break;
                case "stringlist":
                    sourceComp = "ListDelegate.qml";
                    break;
                case "bool":
                    sourceComp = "LedDelegate.qml";
                    break;
                case "int":
                case "uint":
                case "double":
                    if (stateDelegate.stateType.unit === Types.UnitUnixTime) {
                        sourceComp = "DateTimeDelegate.qml";
                    } else {
                        sourceComp = "NumberLabelDelegate.qml";
                    }
                    break;
                case "color":
                    sourceComp = "ColorDelegate.qml";
                    break;
                }
                if (!sourceComp) {
                    sourceComp = "LabelDelegate.qml";
                    print("GenericThingPage: unhandled entry", stateDelegate.stateType.displayName)
                }

                var minValue = stateDelegate.stateType.minValue !== undefined
                        ? stateDelegate.stateType.minValue
                        : stateDelegate.stateType.type.toLowerCase() === "uint"
                          ? 0
                          : -2000000000; // As per QML spec
                var maxValue = stateDelegate.stateType.maxValue !== undefined
                        ? stateDelegate.stateType.maxValue
                        : 2000000000;
                print("pushing delegate for", stateDelegate.stateType.name, "from:", minValue, "to:", maxValue, "possible:", stateDelegate.stateType.possibleValuesDisplayNames)
                stateDelegateLoader.setSource("../delegates/statedelegates/" + sourceComp,
                                              {
                                                  value: root.thing.states.getState(stateType.id).value,
                                                  possibleValues: stateDelegate.stateType.possibleValues,
                                                  possibleValuesDisplayNames: stateDelegate.stateType.possibleValuesDisplayNames,
                                                  from: minValue,
                                                  to: maxValue,
                                                  unit: stateDelegate.stateType.unit,
                                                  writable: false,
                                                  stateType: stateDelegate.stateType
                                              })

            }

            Binding {
                target: stateDelegateLoader.item
                property: "value"
                value: stateDelegate.thingState.value
            }
            Binding {
                target: stateDelegateLoader.item.hasOwnProperty("from") ? stateDelegateLoader.item : null
                property: "from"
                value: stateDelegate.thingState.minValue
            }
            Binding {
                target: stateDelegateLoader.item.hasOwnProperty("to") ? stateDelegateLoader.item : null
                property: "to"
                value: stateDelegate.thingState.maxValue
            }
            Binding {
                target: stateDelegateLoader.item.hasOwnProperty("possibleValues") ? stateDelegateLoader.item : null
                property: "possibleValues"
                value: stateDelegate.thingState.possibleValues
            }
            Binding {
                target: stateDelegateLoader.item.hasOwnProperty("possibleValuesDisplayNames") ? stateDelegateLoader.item : null
                property: "possibleValuesDisplayNames"
                value: {
                    print("updating displayNames", stateDelegate.thingState.possibleValues)
                    var ret = []
                    for (var i = 0; i < stateDelegate.thingState.possibleValues.length; i++) {
                        var possibleValue = stateDelegate.thingState.possibleValues[i]
                        var idx = stateDelegate.stateType.possibleValues.indexOf(possibleValue)
                        print("value:", possibleValue, idx)
                        if (idx >= 0) {
                            ret.push(stateDelegate.stateType.possibleValuesDisplayNames[idx])
                        } else {
                            ret.push(possibleValue)
                        }
                    }
                    return ret
                }
            }
            Binding {
                target: stateDelegateLoader.item.hasOwnProperty("unit") ? stateDelegateLoader.item : null
                property: "unit"
                value: stateDelegate.stateType.unit
            }
        }
    }

    Component {
        id: eventComponent
        RowLayout {
            id: eventComponentItem
            property EventType eventType: null

            Label {
                Layout.fillWidth: true
                text: eventComponentItem.eventType.displayName
            }
            Rectangle {
                id: flashlight
                Layout.preferredHeight: Style.iconSize * .8
                Layout.preferredWidth: height
                color: "lightgray"
                radius: width / 2
                border.color: Style.foregroundColor
                border.width: 1

                SequentialAnimation on color {
                    id: flashlightAnimation
                    running: false
                    ColorAnimation { to: "lightgreen"; duration: 100 }
                    ColorAnimation { to: "lightgray"; duration: 500 }
                }
            }
            Connections {
                target: root.thing
                onEventTriggered: {
                    if (eventTypeId === eventComponentItem.eventType.id) {
                        flashlightAnimation.start();
                    }
                }
            }
        }
    }
}
