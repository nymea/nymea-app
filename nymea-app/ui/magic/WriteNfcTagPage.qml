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
            pageStack.pop()
        }
    }


    NfcThingActionWriter {
        id: nfcWriter
        engine: _engine
        thing: root.thing
    }
//    nfcHelper.writeThingStates(engine, root.thing)

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        ColumnLayout {
            Layout.preferredWidth: parent.width / parent.columns
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins

            Label {
                Layout.fillWidth: true
                text: {
                    switch (nfcWriter.status) {
                    case NfcThingActionWriter.TagStatusWaiting:
                        return qsTr("Tap an NFC tag to link it to %1.").arg(root.thing.name)
                    case NfcThingActionWriter.TagStatusWriting:
                        return qsTr("Writing NFC tag...")
                    case NfcThingActionWriter.TagStatusWritten:
                        return qsTr("NFC tag linked to %1.").arg(root.thing.name)
                    case NfcThingActionWriter.TagStatusFailed:
                        return qsTr("Failed linking the NFC tag to %1.").arg(root.thing.name)
                    }
                }
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Required tag size: %1 bytes").arg(nfcWriter.messageSize)
                font.pixelSize: app.smallFont
                horizontalAlignment: Text.AlignHCenter
                enabled: false
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.iconSize * 8

                SequentialAnimation {
                    loops: Animation.Infinite
                    running: true

                    PropertyAction { target: phoneIcon; property: "anchors.horizontalCenterOffset"; value: Style.iconSize * 2 }
                    PropertyAction { target: phoneIcon; property: "scale"; value: 1.3 }
                    NumberAnimation { target: phoneIcon; property: "opacity"; duration: 500; to: 1 }
                    PauseAnimation { duration: 500 }
                    ParallelAnimation {
                        NumberAnimation { target: phoneIcon; property: "anchors.horizontalCenterOffset"; from: Style.iconSize * 2; to: -Style.iconSize * 2; duration: 1500; easing.type: Easing.OutQuad }
                        NumberAnimation { target: phoneIcon; property: "scale"; duration: 1500; from: 1.3; to: 1; easing.type: Easing.InOutQuad }
                    }
                    PauseAnimation { duration: 500 }
                    NumberAnimation { target: phoneIcon; property: "opacity"; duration: 500; to: 0 }
                    PauseAnimation { duration: 500 }
                }


                ColorIcon {
                    id: nfcIcon
                    name: "qrc:/icons/nfc.svg"
                    height: Style.iconSize * 2
                    width: Style.iconSize * 2
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: - Style.iconSize * 2
                    visible: nfcWriter.status == NfcThingActionWriter.TagStatusWaiting
                }

                Item {
                    id: phoneIcon
                    height: Style.iconSize * 5
                    width: Style.iconSize * 5
                    scale: 1.5
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: Style.iconSize * 2
                    visible: nfcWriter.status == NfcThingActionWriter.TagStatusWaiting

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: phoneIcon.width * .21
                        anchors.rightMargin: phoneIcon.width * .21
                        anchors.topMargin: phoneIcon.height * .1
                        anchors.bottomMargin: phoneIcon.height * .1
                        color: Style.backgroundColor
                    }

                    ColorIcon {
                        name: "qrc:/icons/smartphone.svg"
                        anchors.fill: parent
                    }
                }

                Rectangle {
                    id: tick
                    anchors.centerIn: parent
                    height: Style.iconSize * 6
                    width: Style.iconSize * 6
                    radius: width / 2
                    color: Style.backgroundColor
                    border.width: 4
                    border.color: Style.foregroundColor
                    opacity: nfcWriter.status == NfcThingActionWriter.TagStatusWaiting ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: 300 } }

                    property bool shown: nfcWriter.status == NfcThingActionWriter.TagStatusWritten || nfcWriter.status == NfcThingActionWriter.TagStatusFailed

                    BusyIndicator {
                        anchors.fill: parent
                        running: visible
                        visible: nfcWriter.status == NfcThingActionWriter.TagStatusWriting
                    }

                    Item {
                        anchors.fill: parent
                        anchors.rightMargin: tick.shown ? 0 : parent.width
                        Behavior on anchors.rightMargin { NumberAnimation { duration: 500 } }
                        clip: true

                        ColorIcon {
                            x: (tick.width - width) / 2
                            y: (tick.height - height) / 2
                            height: Style.iconSize * 4
                            width: Style.iconSize * 4
                            name: nfcWriter.status == NfcThingActionWriter.TagStatusFailed ? "qrc:/icons/close.svg" : "qrc:/icons/tick.svg"
                            color: nfcWriter.status == NfcThingActionWriter.TagStatusFailed ? "red" : "green"
                        }
                    }
                }
            }
        }


        ColumnLayout {
            Layout.preferredWidth: parent.width / parent.columns

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: nfcWriter.actions
                clip: true
                delegate: RuleActionDelegate {
                    ruleAction: nfcWriter.actions.get(index)
                    width: parent.width
                    onRemoveRuleAction: nfcWriter.actions.removeRuleAction(index)
                }
            }

            Button {
                text: qsTr("Add action")
                Layout.fillWidth: true
                Layout.margins: app.margins
                onClicked: {
                    var action = nfcWriter.actions.createNewRuleAction()
                    action.thingId = root.thing.id
                    var page = pageStack.push("SelectRuleActionPage.qml", {ruleAction: action});
                    page.done.connect(function() {
                        nfcWriter.actions.addRuleAction(action);
                        pageStack.pop();
                    })
                    page.backPressed.connect(function() {
                        action.destroy()
                        pageStack.pop();
                    })
                }
            }
        }
    }
}
