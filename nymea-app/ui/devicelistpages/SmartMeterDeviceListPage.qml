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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Smart meters")
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: root.devicesProxy

        delegate: ItemDelegate {
            id: itemDelegate
            width: parent.width

            property bool inline: width > 500

            property Thing thing: thingsProxy.getThing(model.id)

            bottomPadding: index === ListView.view.count - 1 ? topPadding : 0
            contentItem: Pane {
                id: contentItem
                Material.elevation: 2
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0

                contentItem: ItemDelegate {
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    contentItem: ColumnLayout {
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.mediumFont + app.margins
                            color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .05)
                            RowLayout {
                                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; margins: app.margins }
                                Label {
                                    Layout.fillWidth: true
                                    text: model.name
                                    elide: Text.ElideRight
                                }
                                BatteryStatusIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    thing: itemDelegate.thing
                                    visible: thing.setupStatus == Thing.ThingSetupStatusComplete && (isCritical || hasBatteryLevel)
                                }
                                ConnectionStatusIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    thing: itemDelegate.thing
                                    visible: thing.setupStatus == Thing.ThingSetupStatusComplete && (isWireless || !isConnected)
                                }
                                SetupStatusIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    thing: itemDelegate.thing
                                    visible: setupFailed || setupInProgress
                                }
                            }

                        }
                        GridLayout {
                            id: dataGrid
                            columns: Math.floor(contentItem.width / 120)
                            Layout.margins: app.margins
                            Repeater {
                                model: ListModel {
                                    Component.onCompleted: {
                                        if (itemDelegate.thing.thingClass.interfaces.indexOf("smartmeterproducer") >= 0) {
                                            append( {interfaceName: "smartmeterproducer", stateName: "totalEnergyProduced" })
                                        }
                                        if (itemDelegate.thing.thingClass.interfaces.indexOf("smartmeterconsumer") >= 0) {
                                            append( {interfaceName: "smartmeterconsumer", stateName: "totalEnergyConsumed" })
                                        }
                                        var added = false;
                                        if (itemDelegate.thing.thingClass.interfaces.indexOf("extendedsmartmeterproducer") >= 0) {
                                            append({interfaceName: "extendedsmartmeterconsumer", stateName: "currentPower"});
                                            added = true;
                                        }
                                        if (!added && itemDelegate.thing.thingClass.interfaces.indexOf("extendedsmartmeterconsumer") >= 0) {
                                            append({interfaceName: "extendedsmartmeterconsumer", stateName: "currentPower"});
                                        }
                                    }
                                }

                                delegate: RowLayout {
                                    id: sensorValueDelegate
                                    Layout.preferredWidth: contentItem.width / dataGrid.columns

                                    property StateType stateType: itemDelegate.thing.thingClass.stateTypes.findByName(model.stateName)
                                    property State stateValue: stateType ? itemDelegate.thing.states.getState(stateType.id) : null

                                    ColorIcon {
                                        Layout.preferredHeight: app.iconSize * .8
                                        Layout.preferredWidth: height
                                        Layout.alignment: Qt.AlignVCenter
                                        color: app.interfaceToColor(model.interfaceName)
                                        name: app.interfaceToIcon(model.interfaceName)
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: sensorValueDelegate.stateValue
                                              ? "%1 %2".arg(1.0 * Math.round(Types.toUiValue(sensorValueDelegate.stateValue.value, sensorValueDelegate.stateType.unit) * 100000) / 100000).arg(Types.toUiUnit(sensorValueDelegate.stateType.unit))
                                              : ""
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: app.smallFont
                                    }
                                }
                            }
                        }
                    }
                    onClicked: {
                        enterPage(index, false)
                    }
                }
            }
        }
    }
}
