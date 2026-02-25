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

ItemDelegate {

    id: root
    property StateEvaluator stateEvaluator: null
    readonly property Thing thing: stateEvaluator ? engine.thingManager.things.getThing(stateEvaluator.stateDescriptor.thingId) : null
    readonly property StateType stateType: thing ? thing.thingClass.stateTypes.getStateType(stateEvaluator.stateDescriptor.stateTypeId) : null

    property bool canDelete: true
    signal deleteClicked()

    function editStateDescriptor(interfaceMode) {
        if (interfaceMode === undefined) {
            interfaceMode = false;
        }

        var page = pageStack.push(Qt.resolvedUrl("SelectThingPage.qml"), {selectInterface: interfaceMode, showStates: true});
        page.backPressed.connect(function() {
            pageStack.pop()
        })
        page.thingSelected.connect(function(thing) {
            root.stateEvaluator.stateDescriptor.interfaceName = "";
            root.stateEvaluator.stateDescriptor.thingId = thing.id;
            var statePage = selectStateDescriptorData()
            statePage.done.connect(function() {
                pageStack.pop(StackView.Immediate)
                pageStack.pop()
            })
        });
        page.interfaceSelected.connect(function(interfaceName) {
            root.stateEvaluator.stateDescriptor.thingId = "";
            root.stateEvaluator.stateDescriptor.interfaceName = interfaceName;
            var statePage = selectStateDescriptorData();
            statePage.done.connect(function() {
                pageStack.pop(StackView.Immediate)
                pageStack.pop()
            })
        });
    }
    function editInterfaceStateDescriptor() {
        editStateDescriptor(true)
    }
    function selectStateDescriptorData() {
        var statePage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorPage.qml"), {text: "Select state", stateDescriptor: root.stateEvaluator.stateDescriptor})
        statePage.backPressed.connect(function() {
            pageStack.pop();
        })
        statePage.done.connect(function() {
            pageStack.pop(statePage, StackView.Immediate);
            pageStack.pop();
//            pageStack.pop();
        })
        return statePage
    }

    contentItem: ColumnLayout {
        SimpleStateEvaluatorDelegate {
            Layout.fillWidth: true
            stateEvaluator: root.stateEvaluator
            swipe.enabled: root.canDelete
            onClicked: {
                print("opening editor:", root.stateEvaluator.stateDescriptor.thingId)
                if (root.stateEvaluator.stateDescriptor.thingId.toString() !== "{00000000-0000-0000-0000-000000000000}") {
                    selectStateDescriptorData()
                } else {
                    var page = pageStack.push(stateQuestionPageComponent);
                }
            }
            onDeleteClicked: {
                root.deleteClicked()
            }
        }

        ComboBox {
            Layout.fillWidth: true
            model: [qsTr("and all of those"), qsTr("or any of those")]
            currentIndex: root.stateEvaluator && root.stateEvaluator.stateOperator === StateEvaluator.StateOperatorAnd ? 0 : 1
            visible: root.stateEvaluator && root.stateEvaluator.childEvaluators.count > 0
            onActivated: (index) => {
                root.stateEvaluator.stateOperator = index === 0 ? StateEvaluator.StateOperatorAnd : StateEvaluator.StateOperatorOr
            }
        }

        Repeater {
            model: root.stateEvaluator ? root.stateEvaluator.childEvaluators : null
            delegate: SimpleStateEvaluatorDelegate {
                Layout.fillWidth: true
                stateEvaluator: root.stateEvaluator.childEvaluators.get(index)
                showChilds: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("EditStateEvaluatorPage.qml"), {stateEvaluator: stateEvaluator})
                }
                onDeleteClicked: {
                    root.stateEvaluator.childEvaluators.remove(index)
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Add a condition")
            onClicked: {
                root.stateEvaluator.addChildEvaluator()
            }
        }
    }

    Component {
        id: stateQuestionPageComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Edit condition...")

                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent

                Repeater {
                    model: ListModel {
                        ListElement {
                            iconName: "qrc:/icons/state.svg"
                            text: qsTr("When one of my things is in a certain state")
                            method: "editStateDescriptor"

                        }
                        ListElement {
                            iconName: "qrc:/icons/state-interface.svg"
                            text: qsTr("When a thing of a given type enters a state")
                            method: "editInterfaceStateDescriptor"
                        }
                    }
                    delegate: NymeaSwipeDelegate {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Style.largeDelegateHeight
                        iconName: model.iconName
                        text: model.text
                        progressive: true
                        iconSize: Style.iconSize * 2

                        onClicked: {
                            root[model.method]()
                        }
                    }
                }
            }
        }
    }
}
