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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

ThingPageBase {
    id: root

    readonly property bool landscape: width > height
    readonly property bool isExtended: thing.thingClass.interfaces.indexOf("extendedawning") >= 0
    readonly property State percentageState: thing.stateByName("percentage")
    readonly property State movingState: thing.stateByName("moving")

    GridLayout {
        anchors.fill: parent
        columns: root.landscape ? 2 : 1

        ColorIcon {
            id: shutterImage
            Layout.preferredWidth: root.landscape ?
                                       Math.min(parent.width - shutterControlsContainer.minimumWidth, parent.height) - app.margins
                                     : Math.min(Math.min(500, parent.width), parent.height - shutterControlsContainer.minimumHeight)
            Layout.preferredHeight: width
            Layout.alignment: Qt.AlignHCenter
            name: "../images/awning/awning-" + app.pad(Math.round(root.percentageState.value / 10) * 10, 3) + ".svg"
            visible: isExtended
        }


        Item {
            id: shutterControlsContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: app.margins * 2
            property int minimumWidth: app.iconSize * 2.7 * 3
            property int minimumHeight: app.iconSize * 4.5

            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: app.margins

                Slider {
                    id: percentageSlider
                    width: parent.width
                    from: 0
                    to: 100
                    stepSize: 1
                    visible: isExtended

                    Binding {
                        target: percentageSlider
                        property: "value"
                        value: root.percentageState.value
                        when: !percentageSlider.pressed
                    }

                    onPressedChanged: {
                        if (pressed) {
                            return
                        }
                        print("should move", value)

                        var actionType = root.thing.thingClass.actionTypes.findByName("percentage");
                        var params = [];
                        var percentageParam = {}
                        percentageParam["paramTypeId"] = actionType.paramTypes.findByName("percentage").id;
                        percentageParam["value"] = value
                        params.push(percentageParam);
                        engine.thingManager.executeAction(root.thing.id, actionType.id, params);
                    }
                }

                ShutterControls {
                    id: shutterControls
                    thing: root.thing
                    invert: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: (parent.width - app.iconSize*2*children.length) / (children.length - 1)
                }
            }
        }
    }
}
