// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"

ColumnLayout {
    id: root
    Layout.minimumHeight: 100
    property string title: ""

    property ZoneInfo zone: null
    property TemperatureDaySchedule daySchedule: null

    property TemperatureDaySchedule scheduleClipboard: null

    signal copyClicked()

    RowLayout {
        Layout.fillWidth: true

        Label {
            Layout.fillWidth: true
            text: root.title
        }

        ProgressButton {
            imageSource: paste ? "edit-paste" : "edit-copy"
            color: root.scheduleClipboard == root.daySchedule ? Style.accentColor : Style.iconColor
            property bool paste: root.scheduleClipboard != null && root.scheduleClipboard != root.daySchedule
            onClicked: {
                if (paste) {
                    daySchedule.clear();
                    for (var i = 0; i < root.scheduleClipboard.count; i++) {
                        var schedule = root.scheduleClipboard.get(i)
                        daySchedule.createSchedule(schedule.startTime, schedule.endTime, schedule.temperature)
                    }
                } else {
                    root.copyClicked()
                }
            }
        }
    }


    QtObject {
        id: d
        property var freeBlocks: {
            var ret = []
            for (var i = 0; i < daySchedule.count; i++) {
                var previous = i == 0 ? null : daySchedule.get(i - 1)
                var previousMins = previous ? previous.endTime.getHours() * 60 + previous.endTime.getMinutes() : 0
                var schedule = daySchedule.get(i)
                var startMins = schedule.startTime.getHours() * 60 + schedule.startTime.getMinutes()
                var endMins = schedule.endTime.getHours() * 60 + schedule.endTime.getMinutes()

                if (startMins > previousMins + 60 * 3) {
                    ret.push({startMins: previousMins, endMins: startMins})
                }
            }
            var last = daySchedule.count > 0 ? daySchedule.get(daySchedule.count - 1) : null
            var lastMins = last ? last.endTime.getHours() * 60 + last.endTime.getMinutes() : 0
            if (lastMins < (21*60)) {
                ret.push({startMins: lastMins, endMins: 24*60})
            }

            return ret
        }
    }

    Rectangle {
        id: slider
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Style.tileBackgroundColor
        radius: Style.cornerRadius
        clip: true


        Repeater {
            model: 24
            delegate: Rectangle {
                height: parent.height
                width: 1
                color: Style.tileOverlayColor
                x: slider.width / 24 * index
                visible: index > 0
            }
        }

        Repeater {
            model: root.daySchedule
            delegate: Rectangle {
                id: blockDelegate
                readonly property TemperatureSchedule schedule: root.daySchedule.get(index)
                readonly property int startMinutes: schedule.startTime.getHours() * 60 + schedule.startTime.getMinutes()
                readonly property int endMinutes: schedule.endTime.getHours() * 60 + schedule.endTime.getMinutes()
                readonly property int totalMinutes: 24 * 60
                height: slider.height
                width: endMinutes * slider.width / totalMinutes - x
                x: startMinutes * slider.width / totalMinutes
                radius: Style.cornerRadius
                color: schedule.temperature >= zone.standbySetpoint ? Style.red : Style.blue

                Rectangle {
                    anchors {
                        left: parent.left;
                        leftMargin: Style.extraSmallMargins
                        verticalCenter: parent.verticalCenter
                    }
                    height: Style.font.pixelSize
                    width: 2
                    radius: width / 2
                    color: Style.white
                }
                Rectangle {
                    anchors {
                        right: parent.right
                        rightMargin: Style.extraSmallMargins
                        verticalCenter: parent.verticalCenter
                    }
                    height: Style.font.pixelSize
                    width: 2
                    radius: width / 2
                    color: Style.white
                }

                Label {
                    anchors { left: parent.left; right: parent.right; margins: Style.extraSmallMargins; top: parent.top }
                    anchors.leftMargin: parent.width >= implicitWidth + Style.smallMargins ? Style.extraSmallMargins : -(implicitWidth + Style.extraSmallMargins)
                    horizontalAlignment: Text.AlignLeft
                    font: Style.extraSmallFont
                    text: blockDelegate.schedule.startTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                }

                Label {
                    anchors { left: parent.left; right: parent.right; margins: Style.smallMargins; verticalCenter: parent.verticalCenter }
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.smallFont
                    text: Types.toUiValue(blockDelegate.schedule.temperature, Types.UnitDegreeCelsius) + "°"
                    elide: Text.ElideRight
                }
                Label {
                    anchors { left: parent.left; right: parent.right; margins: Style.extraSmallMargins; bottom: parent.bottom }
                    anchors.rightMargin: parent.width >= implicitWidth + Style.smallMargins ? Style.extraSmallMargins : -(implicitWidth + Style.extraSmallMargins)
                    horizontalAlignment: Text.AlignRight
                    font: Style.extraSmallFont
                    text: blockDelegate.schedule.endTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
//                    elide: Text.ElideRight
                }

            }
        }



        MouseArea {
            anchors.fill: parent

            property bool moveStart: false
            property bool moveEnd: false
            property TemperatureSchedule previousSchedule: null
            property TemperatureSchedule movedSchedule: null
            property TemperatureSchedule nextSchedule: null

            property int startMouseX: 0
            property int startMins: 0
            property int endMins: 0

            onPressed: {
                movedSchedule = null
                startMouseX = mouseX
                var totalMins = 24 * 60
                for (var i = 0; i < root.daySchedule.count; i++) {
                    var schedule = root.daySchedule.get(i)
                    print("schedule:", schedule.startTime, schedule.endTime)
                    var startMin = schedule.startTime.getHours() * 60 + schedule.startTime.getMinutes()
                    var startPos = startMin * slider.width / totalMins
                    var endMin = schedule.endTime.getHours() * 60 + schedule.endTime.getMinutes()
                    var endPos = endMin * slider.width / totalMins

                    if (Math.abs(startPos - mouseX) < 10) {
                        moveStart = true;
                        print("start")
                    } else if (Math.abs(endPos - mouseX) < 10) {
                        moveEnd = true
                        print("end")
                    } else if (mouseX > startPos && mouseX < endPos) {
                        moveStart = true
                        moveEnd = true
                        print("middle")
                    } else {
                        continue
                    }
                    startMins = startMin
                    endMins = endMin
                    previousSchedule = i > 0 ? root.daySchedule.get(i-1) : null
                    movedSchedule = schedule
                    nextSchedule = i < root.daySchedule.count - 1 ? root.daySchedule.get(i+1) : null
                    break;
                }
            }

            onReleased: {
                moveStart = false;
                moveEnd = false;
                preventStealing = false;
            }

            onClicked: {
                print("clicked")
                if (movedSchedule != null && Math.abs(mouseX - startMouseX) < 5) {
                    print("opening")
                    var dialog = editDialogComponent.createObject(root.parent, {schedule: movedSchedule})
                    dialog.open()

                }
            }

            onPositionChanged: {
                var totalMins = 24 * 60
                var diffX = mouseX - startMouseX

                // dY : height = dM : total
                var diffMins = diffX * totalMins / slider.width
                print("diffX", diffX, "diffMins", diffMins, startMins, startMins + diffMins)

                var newStart = new Date(movedSchedule.startTime);
                var newEnd = new Date(movedSchedule.endTime);

                var newStartMins = startMins + (moveStart ? diffMins : 0);
                var newEndMins = endMins + (moveEnd ? diffMins : 0);

                var snapMinutes = 30

                var leftLimit = previousSchedule ? previousSchedule.endTime.getHours() * 60 + previousSchedule.endTime.getMinutes() + snapMinutes : 0
                var rightLimit = nextSchedule ? nextSchedule.startTime.getHours() * 60 + nextSchedule.startTime.getMinutes() - snapMinutes : totalMins


                if (moveStart && !moveEnd) {
                    newStartMins = Math.max(leftLimit, newStartMins)
                    newStartMins = Math.min(newEndMins - 60, newStartMins)
                } else if (moveEnd && !moveStart) {
                    newEndMins = Math.min(rightLimit, newEndMins)
                    newEndMins = Math.max(newStartMins + 60, newEndMins)
                } else if (moveStart && moveEnd) {
                    newStartMins = Math.max(leftLimit, newStartMins)
                    newEndMins = Math.min(rightLimit, newEndMins)

                    var blockSize = endMins - startMins

                    newStartMins = Math.max(leftLimit, Math.min(newEndMins - blockSize, newStartMins))
                    newEndMins = Math.max(newStartMins + blockSize, newEndMins)

                }

                var startSnapOffset = newStartMins % snapMinutes
                if (startSnapOffset < snapMinutes / 2) {
                    newStartMins -= startSnapOffset
                } else {
                    newStartMins += (snapMinutes - startSnapOffset)
                }
                var endSnapOffset = newEndMins % snapMinutes
                if (endSnapOffset < snapMinutes / 2) {
                    newEndMins -= endSnapOffset
                } else {
                    newEndMins += (snapMinutes - endSnapOffset)
                }
                print("startSnapOffset", startSnapOffset, "endSnapOff", endSnapOffset, "nes start", newStartMins, newEndMins)

                if (newEndMins == totalMins) {
                    newEndMins -= 1
                }

                newStart.setHours(0, newStartMins)
                newEnd.setHours(0, newEndMins)

                if (movedSchedule.startTime.getTime() !== newStart.getTime() || movedSchedule.endTime.getTime() !== newEnd.getTime()) {
                    preventStealing = true;
                }

                movedSchedule.startTime = newStart
                movedSchedule.endTime = newEnd

                print("start time is new", newStart.toLocaleTimeString())
                print("end time is new", newEnd.toLocaleTimeString())

            }
        }

        Repeater {
            model: d.freeBlocks
            delegate: Item {
                id: freeBlockDelegate
                property var block: d.freeBlocks[index]
                x: block.startMins * slider.width / (24*60)
                width: block.endMins * slider.width / (24*60) - x
                height: slider.height

                ProgressButton {
                    anchors.centerIn: parent
                    imageSource: "add"
                    onClicked: {
                        var startTime = new Date()
                        var endTime = new Date()
                        if (root.daySchedule.count == 0) {
                            startTime.setHours(6, 0, 0)
                            endTime.setHours(18, 0, 0)
                        } else {
                            startTime.setHours(0, freeBlockDelegate.block.startMins + 60, 0)
                            endTime.setHours(0, freeBlockDelegate.block.endMins - 60, 0)
                        }

                        root.daySchedule.createSchedule(startTime, endTime, 21)
                    }
                }
            }
        }
    }

    Component {
        id: editDialogComponent
        NymeaDialog {
            id: editDialog
            x: (parent.width - width) / 2
            property TemperatureSchedule schedule: null

            standardButtons: Dialog.NoButton

            Dial {
                id: dial
                Layout.fillWidth: true
                Layout.preferredHeight: width
                activeValue: root.zone.standbySetpoint
                minValue: 10
                maxValue: 30
                precision: 0.5
                value: editDialog.schedule.temperature
                onMoved: editDialog.schedule.temperature = value
                color: activeValue <= value ? Style.red : Style.blue
                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -Style.smallMargins
                    width: parent.contentItem.width * 0.6
                    Label {
                        Layout.fillWidth: true
                        text: Types.toUiUnit(Types.UnitDegreeCelsius)
                        font.pixelSize: Math.min(Style.smallFont.pixelSize, dial.height / 16)
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        Layout.fillWidth: true
                        text: Types.toUiValue(editDialog.schedule.temperature, Types.UnitDegreeCelsius).toFixed(1)
                        font.pixelSize: Math.min(Style.hugeFont.pixelSize, dial.height / 8)
                        horizontalAlignment: Text.AlignHCenter
                        color: zone.currentSetpoint > zone.standbySetpoint
                                 ? Style.red
                                 : zone.currentSetpoint < zone.standbySetpoint
                                   ? Style.blue
                                   : Style.foregroundColor
                    }
                    Label {
                        Layout.fillWidth: true
                        text: Types.toUiValue(zone.standbySetpoint, Types.UnitDegreeCelsius).toFixed(1)
                        font.pixelSize: Math.min(Style.largeFont.pixelSize, dial.height / 12)
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }


                }


            }

            Label {
                Layout.fillWidth: true
                text: editDialog.schedule.startTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                      + " - "
                      + editDialog.schedule.endTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Button {
                    text: qsTr("Remove")
                    Layout.fillWidth: true
                    onClicked: {
                        root.daySchedule.removeSchedule(editDialog.schedule)
                        editDialog.close()
                    }
                }
                Button {
                    text: qsTr("OK")
                    Layout.fillWidth: true
                    onClicked: {
                        editDialog.close()
                    }
                }
            }

        }
    }
}
