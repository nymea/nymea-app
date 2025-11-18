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

import QtQuick 2.3
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0

ColumnLayout {
    id: root

    property date date

    RowLayout {
        Layout.fillWidth: true
        ColorIcon {
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            name: "qrc:/icons/back.svg"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var newDate = new Date(root.date)
                    newDate.setMonth(root.date.getMonth() - 1)
                    root.date = newDate
                }
            }
        }
        Label {
            text: root.date.toLocaleDateString()
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
        ColorIcon {
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            name: "qrc:/icons/next.svg"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var newDate = new Date(root.date)
                    newDate.setMonth(root.date.getMonth() + 1)
                    root.date = newDate
                }
            }
        }
    }

    ThinDivider {}

    ListModel {
        id: monthModel
        ListElement { text: qsTr("January"); days: 31; leapYearDays: 31 }
        ListElement { text: qsTr("February"); days: 28; leapYearDays: 29 }
        ListElement { text: qsTr("March"); days: 31; leapYearDays: 31 }
        ListElement { text: qsTr("April"); days: 30; leapYearDays: 30 }
        ListElement { text: qsTr("May"); days: 31; leapYearDays: 31 }
        ListElement { text: qsTr("June"); days: 30; leapYearDays: 30 }
        ListElement { text: qsTr("July"); days: 31; leapYearDays: 31 }
        ListElement { text: qsTr("August"); days: 31; leapYearDays: 31 }
        ListElement { text: qsTr("September"); days: 30; leapYearDays: 30 }
        ListElement { text: qsTr("October"); days: 31; leapYearDays: 31 }
        ListElement { text: qsTr("November"); days: 30; leapYearDays: 30 }
        ListElement { text: qsTr("December"); days: 31; leapYearDays: 31 }
    }

    ListModel {
        id: weekModel
        ListElement { text: qsTr("Mon") }
        ListElement { text: qsTr("Tue") }
        ListElement { text: qsTr("Wed") }
        ListElement { text: qsTr("Thu") }
        ListElement { text: qsTr("Fri") }
        ListElement { text: qsTr("Sat") }
        ListElement { text: qsTr("Sun") }
    }

    RowLayout {
        Repeater {
            model: weekModel
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                Label {
                    anchors.centerIn: parent
                    text: model.text
                }
            }
        }
    }

    GridLayout {
        id: daysGrid
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 7
        columnSpacing: 0
        rowSpacing: 0

        property date firstOfMonth: new Date(root.date.getFullYear(), root.date.getMonth(), 1)
        property int offset: ((firstOfMonth.getDay() - 1) % 7 + 7) % 7
        property bool isLeapYear: firstOfMonth.getFullYear() % 4 == 0 && firstOfMonth.getFullYear() % 100 != 0
        property int daysInMonth: isLeapYear ? monthModel.get(root.date.getMonth()).leapYearDays : monthModel.get(root.date.getMonth()).days
        property int daysInPreviousMonth: isLeapYear ? monthModel.get((root.date.getMonth() + 11) % 12).leapYearDays : monthModel.get((root.date.getMonth() + 11) % 12).days

        Repeater {
            model: 6 * 7

            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                radius: width / 2
                property int dayOfMonth: index - daysGrid.offset + 1
                property bool isPreviousMonth: dayOfMonth < 1
                property bool isNextMonth: dayOfMonth > daysGrid.daysInMonth
                property int correctedDayOfMonth: isPreviousMonth ? daysGrid.daysInPreviousMonth + dayOfMonth
                                                                  : isNextMonth ? dayOfMonth - daysGrid.daysInMonth : dayOfMonth
                color: !isPreviousMonth && !isNextMonth && correctedDayOfMonth == root.date.getDate() ? Style.accentColor : "transparent"
                Label {
                    anchors.centerIn: parent
                    opacity: isPreviousMonth || isNextMonth ? 0.6 : 1

                    text: correctedDayOfMonth
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var newDate = new Date(root.date)
                        newDate.setDate(dayOfMonth)
                        root.date = newDate
                    }
                }
            }
        }
    }
}
