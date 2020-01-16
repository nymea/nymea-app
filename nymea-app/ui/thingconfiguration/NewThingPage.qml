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
        contentItem: Rectangle {
            color: app.primaryColor
            clip: true
            GridLayout {
                anchors.fill: parent
                anchors.margins: app.margins
                columnSpacing: app.margins
                columns: Math.max(1, Math.floor(width / 250)) * 2
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
                        vendors: engine.deviceManager.vendors
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
                            deviceManager: engine.deviceManager
                            shownInterfaces: app.supportedInterfaces
                            onlyConfiguredDevices: false
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
                    Layout.preferredHeight: app.iconSize
                    Layout.minimumWidth: app.iconSize

                    ColorIcon {
                        height: parent.height
                        width: height
                        name: "../images/find.svg"
                    }
                }

                TextField {
                    id: displayNameFilterField
                    Layout.fillWidth: true
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

        model: DeviceClassesProxy {
            id: deviceClassesProxy
            engine: _engine
            filterInterface: typeFilterModel.get(typeFilterComboBox.currentIndex).interfaceName
            filterVendorId: vendorFilterComboBox.currentIndex >= 0 ? vendorsFilterModel.get(vendorFilterComboBox.currentIndex).vendorId : ""
            filterString: displayNameFilterField.displayText
            groupByInterface: true
        }

        delegate: NymeaListItemDelegate {
            id: deviceClassDelegate
            width: parent.width
            text: model.displayName
            subText: engine.deviceManager.vendors.getVendor(model.vendorId).displayName
            iconName: app.interfacesToIcon(deviceClass.interfaces)
            prominentSubText: false
            wrapTexts: false

            property var deviceClass: deviceClassesProxy.get(index)

            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("SetupWizard.qml"), {deviceClass: deviceClassesProxy.get(index)});
                page.done.connect(function() {
                    pageStack.pop(root, StackView.Immediate);
                    pageStack.pop();
                })
            }
        }
    }
}
