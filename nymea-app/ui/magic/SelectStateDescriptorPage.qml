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

import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either thingId or interfaceName
    property var stateDescriptor: null

    readonly property Thing thing: stateDescriptor && stateDescriptor.thingId ? engine.thingManager.things.getThing(stateDescriptor.thingId) : null

    signal backPressed();
    signal done();

    onStateDescriptorChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: NymeaHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.stateDescriptor && root.stateDescriptor.interfaceName && root.stateDescriptor.interfaceName.length > 0
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "../images/view-expand.svg" : "../images/view-collapse.svg"
            visible: root.stateDescriptor && root.stateDescriptor.interfaceName.length === 0
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: generatedModel
        ListElement { displayName: ""; stateTypeId: "" }
    }

    function buildInterface() {
        print("building interface:", header.interfacesMode, root.stateDescriptor, root.stateDescriptor.interfaceName)
        if (header.interfacesMode) {
            if (root.thing) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.thing.thingClass.interfaces.indexOf(iface.name) >= 0) {
                        print("root has thing class:", iface.name, iface.stateTypes.count)
                        for (var j = 0; j < iface.stateTypes.count; j++) {
                            var ifaceSt = iface.stateTypes.get(j);
                            print("ifaceSt:", ifaceSt, j, iface.stateTypes.count)
                            var dcSt = root.thing.thingClass.stateTypes.findByName(ifaceSt.name)
                            print("adding:", ifaceSt.displayName, dcSt.id)
                            generatedModel.append({displayName: ifaceSt.displayName, stateTypeId: dcSt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.stateDescriptor.interfaceName !== "") {
                listView.model = Interfaces.findByName(root.stateDescriptor.interfaceName).stateTypes
            } else {
                console.warn("You need to set thing or interfaceName");
            }
        } else {
            if (root.thing) {
                listView.model = thingClass.stateTypes;
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        delegate: ItemDelegate {
            text: model.displayName
            width: parent.width
            onClicked: {
                if (header.interfacesMode) {
                    if (root.thing) {
                        print("selected:", model.stateTypeId)
                        root.stateDescriptor.stateTypeId = model.stateTypeId;
                        var stateType = root.thing.thingClass.stateTypes.getStateType(model.stateTypeId)
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })
                    } else if (root.stateDescriptor.interfaceName !== "") {
                        root.stateDescriptor.interfaceState = model.name;
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })
                    } else {
                        console.warn("Neither thingId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.thing) {
                        var stateType = root.thingClass.stateTypes.getStateType(model.id);
                        root.stateDescriptor.stateTypeId = model.id;
                        var paramsPage = pageStack.push(Qt.resolvedUrl("SelectStateDescriptorParamsPage.qml"), {stateDescriptor: root.stateDescriptor})
                        paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                        paramsPage.onCompleted.connect(function() {
                            pageStack.pop();
                            root.done();
                        })

                        print("have type", stateType.id)
                    } else {
                        console.warn("FIXME: not implemented yet");
                    }
                }
            }
        }
    }
}
