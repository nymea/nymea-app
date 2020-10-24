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
import "../customviews"

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Weather")
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: root.devicesProxy
        topMargin: app.margins / 2

        delegate: Item {
            id: itemDelegate
            width: parent.width - app.margins
            height: contentItem.height + app.margins
            anchors.horizontalCenter: parent.horizontalCenter

            property bool inline: width > 500

            property Device device: devicesProxy.getDevice(model.id)
            property DeviceClass deviceClass: device.deviceClass

            Pane {
                id: contentItem
                width: parent.width - app.margins
                anchors.centerIn: parent
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
                                ColorIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    name: "../images/dialog-warning-symbolic.svg"
                                    visible: itemDelegate.deviceClass.interfaces.indexOf("connectable") >= 0 && itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("connected").id).value === false
                                    color: "red"
                                }
                            }
                        }

                        WeatherView {
                            Layout.fillWidth: true
                            device: itemDelegate.device
                            deviceClass: itemDelegate.deviceClass
                        }
                    }
                    onClicked: {
                        var device = devicesProxy.get(index);
                        var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)
                        pageStack.push(Qt.resolvedUrl("../devicepages/WeatherDevicePage.qml"), {device: devicesProxy.get(index)})
                    }
                }
            }
        }
    }
}
