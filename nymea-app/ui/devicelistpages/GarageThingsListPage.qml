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
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"

ThingsListPageBase {
    id: root

    property string iconBasename: "../images/garage/garage"

    header: NymeaHeader {
        id: header
        onBackPressed: pageStack.pop()
        text: qsTr("Garage doors")
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.implicitHeight
        topMargin: app.margins / 2

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.ceil(width / 600)
            rowSpacing: 0
            columnSpacing: 0
            Repeater {
                model: root.thingsProxy

                delegate: BigThingTile {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns
                    thing: root.thingsProxy.getThing(model.id)
                    showHeader: false
                    topPadding: 0
                    bottomPadding: 0

                    onClicked: {
                        if (isEnabled) {
                            root.enterPage(index)
                        } else {
                            itemDelegate.wobble()
                        }
                    }

                    property State movingState: thing.stateByName("moving")
                    property State percentageState: thing.stateByName("percentage")

                    readonly property bool isImpulseBased: thing.thingClass.interfaces.indexOf("impulsegaragedoor") >= 0

                    contentItem: RowLayout {
                        spacing: app.margins

                        ColorIcon {
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: app.iconSize
                            color: itemDelegate.movingState && itemDelegate.movingState.value === true
                                   ? Style.accentColor
                                   : Style.iconColor
                            name: itemDelegate.percentageState
                                  ? root.iconBasename + "-" + app.pad(Math.round(itemDelegate.percentageState.value / 10) * 10, 3) + ".svg"
                                  : root.iconBasename + "-050.svg"
                        }

                        Label {
                            Layout.fillWidth: true
                            text: itemDelegate.thing.name
                            elide: Text.ElideRight
                            enabled: itemDelegate.isEnabled
                        }

                        ThingStatusIcons {
                            thing: itemDelegate.thing
                        }

                        ShutterControls {
                            id: shutterControls
                            Layout.fillWidth: false
                            height: parent.height
                            thing: itemDelegate.thing
                            invert: root.invertControls
                            visible: !itemDelegate.isImpulseBased
                            enabled: itemDelegate.isEnabled
                        }
                        ProgressButton {
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: height
                            longpressEnabled: false
                            imageSource: "../images/closable-move.svg"
                            visible: itemDelegate.isImpulseBased
                            enabled: itemDelegate.isEnabled
                            onClicked: {
                                var actionTypeId = itemDelegate.thing.thingClass.actionTypes.findByName("triggerImpulse").id
                                print("Triggering impulse", actionTypeId)
                                engine.thingManager.executeAction(itemDelegate.thing.id, actionTypeId)
                            }
                        }
                    }
                }
            }
        }
    }
}
