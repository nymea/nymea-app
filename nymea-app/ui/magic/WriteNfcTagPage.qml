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
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    property Thing thing: null
    readonly property ThingClass thingClass: thing.thingClass

    header: NymeaHeader {
        text: qsTr("Write NFC tag")
        onBackPressed: {
            root.backPressed();
        }
    }


    NfcHelper {
        id: nfcHelper
    }
//    nfcHelper.writeThingStates(engine, root.thing)

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        Item {
            Layout.preferredWidth: Math.min(root.width / parent.columns, root.height)
            Layout.preferredHeight: app.iconSize * 8

            SequentialAnimation {
                loops: Animation.Infinite
                running: true

                PropertyAction { target: phoneIcon; property: "anchors.horizontalCenterOffset"; value: app.iconSize * 2 }
                PropertyAction { target: phoneIcon; property: "scale"; value: 1.3 }
                NumberAnimation {
                    target: phoneIcon
                    property: "opacity"
                    duration: 500
                    to: 1
                }

                PauseAnimation { duration: 500 }
                ParallelAnimation {
                    NumberAnimation {
                        target: phoneIcon
                        property: "anchors.horizontalCenterOffset"
                        from: app.iconSize * 2
                        to: -app.iconSize * 2
                        duration: 1500
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        target: phoneIcon
                        property: "scale"
                        duration: 1500
                        from: 1.3
                        to: 1
                        easing.type: Easing.InOutQuad
                    }
                }

                ParallelAnimation {
                    loops: 2
                    NumberAnimation {
                        duration: 250
                        target: vibrateCircle
                        property: "scale"
                        from: .8
                        to: 1.5
                    }
                    NumberAnimation {
                        duration: 250
                        target: vibrateCircle
                        property: "opacity"
                        from: 1
                        to: 0
                    }
                }
                PauseAnimation {
                    duration: 500
                }

                NumberAnimation {
                    target: phoneIcon
                    property: "opacity"
                    duration: 500
                    to: 0
                }
            }


            ColorIcon {
                id: nfcIcon
                name: "../images/nfc.svg"
                height: app.iconSize * 2
                width: app.iconSize * 2
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: - app.iconSize * 2
            }

            Item {
                id: phoneIcon
                height: app.iconSize * 5
                width: app.iconSize * 5
                scale: 1.5
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: app.iconSize * 2

                Rectangle {
                    id: vibrateCircle
                    anchors.centerIn: parent
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
//                    border.color: nfcIcon.keyColor
                    border.color: app.accentColor
                    border.width: 2
                    scale: .8
                    opacity: 0
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: phoneIcon.width * .21
                    anchors.rightMargin: phoneIcon.width * .21
                    anchors.topMargin: phoneIcon.height * .1
                    anchors.bottomMargin: phoneIcon.height * .1
                    color: app.backgroundColor
                }

                ColorIcon {
                    name: "../images/smartphone.svg"
                    anchors.fill: parent
                }
            }

        }

        ColumnLayout {

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                text: qsTr("Select the wanted states and tap an NFC tag to store them. When tapping this tag later, they will be restored.").arg(root.thing.name)
                wrapMode: Text.WordWrap
                font.pixelSize: app.smallFont
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.thingClass.stateTypes
                clip: true
                delegate: CheckDelegate {
                    width: parent.width
                    text: model.displayName
                    checked: true
                }
            }
        }
    }
}
