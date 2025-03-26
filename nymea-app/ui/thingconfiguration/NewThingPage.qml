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
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property string filterInterface: ""

    header: NymeaHeader {
        text: qsTr("Set up new thing")
        onBackPressed: {
            pageStack.pop();
        }
    }

    function startWizard(thingClass) {
        var page = pageStack.push(Qt.resolvedUrl("SetupWizard.qml"), {thingClass: thingClass});
        page.done.connect(function() {
            pageStack.pop(root, StackView.Immediate);
            pageStack.pop();
        })
        page.aborted.connect(function() {
            pageStack.pop();
        })
    }

    ColumnLayout {
        anchors.fill: parent

        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            columnSpacing: app.margins
            columns: Math.max(1, Math.floor(width / 250)) * 2
            visible: root.filterInterface == ""
            z: 1
            Label {
                text: qsTr("Vendor")
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
                    size: Style.iconSize
                    name: "qrc:/icons/find.svg"
                }
            }

            TextField {
                id: displayNameFilterField
                Layout.fillWidth: true
            }
        }

        GroupedListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            bottomMargin: packagesFilterModel.count > 0 ? height : 0

            model: ThingClassesProxy {
                id: thingClassesProxy
                engine: _engine
                filterInterface: root.filterInterface != "" ? root.filterInterface : typeFilterModel.get(typeFilterComboBox.currentIndex).interfaceName
                includeProvidedInterfaces: true
                filterVendorId: vendorFilterComboBox.currentIndex >= 0 ? vendorsFilterModel.get(vendorFilterComboBox.currentIndex).vendorId : ""
                filterString: displayNameFilterField.displayText
                groupByInterface: true
            }

            onContentYChanged: print("contentY", contentY, contentHeight, originY)

            delegate: NymeaItemDelegate {
                id: tingClassDelegate
                width: parent.width
                text: model.displayName
                subText: engine.thingManager.vendors.getVendor(model.vendorId).displayName
                iconName: app.interfacesToIcon(thingClass.interfaces)
                prominentSubText: false
                wrapTexts: false

                property ThingClass thingClass: thingClassesProxy.get(index)

                onClicked: {
                    root.startWizard(thingClass)
                }
            }

            EmptyViewPlaceholder {
                anchors.centerIn: parent
                width: parent.width - Style.margins * 2
                opacity: packagesFilterModel.count > 0 &&
                         (thingClassesProxy.count == 0 || listView.contentY >= listView.contentHeight + listView.originY)
                         ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Style.shortAnimationDuration } }
                visible: opacity > 0
                title: qsTr("Looking for something else?")
                text: qsTr("Try to install more plugins.")
                imageSource: "qrc:/icons/save.svg"
                buttonText: qsTr("Install plugins")
                onButtonClicked: {
                    pageStack.push(Qt.resolvedUrl("/ui/system/PackageListPage.qml"), {filter: "nymea-plugin-"})
                }
                PackagesFilterModel {
                    id: packagesFilterModel
                    packages: engine.systemController.packages
                    nameFilter: "nymea-plugin-"
                }
            }
        }
    }

}
