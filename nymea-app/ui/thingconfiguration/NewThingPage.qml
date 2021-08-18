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

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Set up new thing")
        onBackPressed: {
            pageStack.pop();
        }
    }

    Pane {
        id: filterPane
        anchors { left: parent.left; top: parent.top; right: parent.right }
        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

        height: implicitHeight + app.margins * 2
        Material.elevation: 1
        z: 1

        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        contentItem: Item {
            clip: true
            GridLayout {
                anchors.fill: parent
                anchors.margins: app.margins
                columnSpacing: app.margins
                columns: Math.max(1, Math.floor(width / 250)) * 2
                Label {
                    text: qsTr("Vendor")
                    color: Style.headerForegroundColor
                }

                ComboBox {
                    id: vendorFilterComboBox
                    Layout.fillWidth: true
                    textRole: "displayName"
                    currentIndex: -1
                    VendorsProxy {
                        id: vendorsProxy
                        vendors: engine.thingManager.vendors
                    }
                    model: ListModel {
                        id: vendorsFilterModel
                        dynamicRoles: true

                        Component.onCompleted: {
                            append({displayName: qsTr("All"), vendorId: ""})
                            for (var i = 0; i < vendorsProxy.count; i++) {
                                var vendor = vendorsProxy.get(i);
                                append({displayName: vendor.displayName, vendorId: vendor.id})
                            }
                            vendorFilterComboBox.currentIndex = 0
                        }
                    }
                }
                Label {
                    text: qsTr("Type")
                    color: Style.headerForegroundColor
                }

                ComboBox {
                    id: typeFilterComboBox
                    Layout.fillWidth: true
                    textRole: "displayName"
                    InterfacesSortModel {
                        id: interfacesSortModel
                        interfacesModel: InterfacesModel {
                            engine: _engine
                            shownInterfaces: app.supportedInterfaces
                            showUncategorized: false
                        }
                    }
                    model: ListModel {
                        id: typeFilterModel
                        ListElement { interfaceName: ""; displayName: qsTr("All") }

                        Component.onCompleted: {
                            for (var i = 0; i < interfacesSortModel.count; i++) {
                                append({interfaceName: interfacesSortModel.get(i), displayName: app.interfaceToString(interfacesSortModel.get(i))});
                            }
                        }
                    }
                }

                Item {
                    Layout.preferredHeight: Style.iconSize
                    Layout.minimumWidth: Style.iconSize

                    ColorIcon {
                        height: parent.height
                        width: height
                        name: "../images/find.svg"
                    }
                }

                TextField {
                    id: displayNameFilterField
                    Layout.fillWidth: true
                    color: Style.headerForegroundColor
                }
            }
        }
    }

    GroupedListView {
        anchors {
            left: parent.left
            top: filterPane.bottom
            right: parent.right
            bottom: parent.bottom
        }

        model: ThingClassesProxy {
            id: thingClassesProxy
            engine: _engine
            filterInterface: typeFilterModel.get(typeFilterComboBox.currentIndex).interfaceName
            filterVendorId: vendorFilterComboBox.currentIndex >= 0 ? vendorsFilterModel.get(vendorFilterComboBox.currentIndex).vendorId : ""
            filterString: displayNameFilterField.displayText
            groupByInterface: true
        }

        delegate: NymeaSwipeDelegate {
            id: tingClassDelegate
            width: parent.width
            text: model.displayName
            subText: engine.thingManager.vendors.getVendor(model.vendorId).displayName
            iconName: app.interfacesToIcon(thingClass.interfaces)
            prominentSubText: false
            wrapTexts: false

            property ThingClass thingClass: thingClassesProxy.get(index)

            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("SetupWizard.qml"), {thingClass: thingClassesProxy.get(index)});
                page.done.connect(function() {
                    pageStack.pop(root, StackView.Immediate);
                    pageStack.pop();
                })
                page.aborted.connect(function() {
                    pageStack.pop();
                })
            }
        }
    }
}
