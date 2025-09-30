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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"

Page {
    id: root
    property alias text: header.text

    // an eventDescriptor object needs to be set and prefilled with either thingId or interfaceName
    property var eventDescriptor: null

    readonly property Thing thing: eventDescriptor && eventDescriptor.thingId ? engine.thingManager.things.getThing(eventDescriptor.thingId) : null

    signal backPressed();
    signal done();

    onEventDescriptorChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: NymeaHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.eventDescriptor.interfaceName !== ""
        onInterfacesModeChanged: root.buildInterface()

//        HeaderButton {
//            imageSource: header.interfacesMode ? "qrc:/icons/view-expand.svg" : "qrc:/icons/view-collapse.svg"
//            visible: root.eventDescriptor.interfaceName === ""
//            onClicked: header.interfacesMode = !header.interfacesMode
//        }
    }

    ListModel {
        id: generatedModel
        ListElement { displayName: ""; eventTypeId: "" }
    }

    function buildInterface() {
        if (header.interfacesMode) {
            if (root.thing) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.thing.thingClass.interfaces.indexOf(iface.name) >= 0) {
                        for (var j = 0; j < iface.eventTypes.count; j++) {
                            var ifaceEt = iface.eventTypes.get(j);
                            var dcEt = root.thing.thingClass.eventTypes.findByName(ifaceEt.name)
                            if (!dcEt) {
                                dcEt = root.thing.thingClass.stateTypes.findByName(ifaceEt.name)
                            }

                            generatedModel.append({displayName: ifaceEt.displayName, eventTypeId: dcEt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.eventDescriptor.interfaceName !== "") {
                listView.model = Interfaces.findByName(root.eventDescriptor.interfaceName).eventTypes
            } else {
                console.warn("You need to set thing or interfaceName");
            }
        } else {
            if (root.thing) {
                generatedModel.clear();
                for (var i = 0; i < root.thing.thingClass.stateTypes.count; i++) {
                    var stateType = root.thing.thingClass.stateTypes.get(i)
                    generatedModel.append({displayName: stateType.displayName, id: stateType.id.toString(), type: "state"})
                }
                for (var i = 0; i < root.thing.thingClass.eventTypes.count; i++) {
                    var eventType = root.thing.thingClass.eventTypes.get(i)
                    generatedModel.append({displayName: eventType.displayName, id: eventType.id.toString(), type: "event"})
                }

                listView.model = generatedModel;
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        clip: true

        section.property: "type"
        section.delegate: ListSectionHeader {
            text: section === "state" ? qsTr("State change") : qsTr("Event")
        }

        delegate: ItemDelegate {
            width: parent.width
            text: model.displayName
            onClicked: {
                if (header.interfacesMode) {
                    if (root.thing) {
                        root.eventDescriptor.eventTypeId = model.eventTypeId;
                        var eventType = root.thing.thingClass.eventTypes.getEventType(model.eventTypeId)
                        if (eventType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), {eventDescriptor: root.eventDescriptor})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else if (root.eventDescriptor.interfaceName !== "") {
                        root.eventDescriptor.interfaceEvent = model.name;
                        if (listView.model.get(index).paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), {eventDescriptor: root.eventDescriptor})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else {
                        console.warn("Neither thingId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.thing) {
                        root.eventDescriptor.eventTypeId = model.id;

                        if (model.type === "state") {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), {eventDescriptor: root.eventDescriptor})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })

                        } else if (model.type === "event") {
                            var eventType = root.thing.thingClass.eventTypes.getEventType(model.id);
                            if (eventType.paramTypes.count > 0) {
                                var paramsPage = pageStack.push(Qt.resolvedUrl("SelectEventDescriptorParamsPage.qml"), {eventDescriptor: root.eventDescriptor})
                                paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                                paramsPage.onCompleted.connect(function() {
                                    pageStack.pop();
                                    root.done();
                                })
                            } else {
                                root.done();
                            }
                        }
                    } else {
                        console.warn("FIXME: not implemented yet");
                    }
                }
            }
        }
    }
}
