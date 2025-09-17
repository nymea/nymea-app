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

import "../components"

NymeaSwipeDelegate {
    id: root
    implicitHeight: app.delegateHeight
    progressive: false
    canDelete: true

    property var calendarItem: null

    readonly property bool isDateBased: calendarItem.repeatingOption.repeatingMode === RepeatingOption.RepeatingModeNone ||
                                        calendarItem.repeatingOption.repeatingMode === RepeatingOption.RepeatingModeYearly

    signal removeCalendarItem();

    onDeleteClicked: root.removeCalendarItem()

    onClicked: {
        var page = pageStack.push(Qt.resolvedUrl("EditCalendarItemPage.qml"), {calendarItem: root.calendarItem})
        page.onBackPressed.connect(function() {pageStack.pop()})
        page.onDone.connect(function() {
            pageStack.pop()
            print("calendarItem.time is now", root.calendarItem.time)
        })
    }


    iconName: "qrc:/icons/clock-app-symbolic.svg"

    text: qsTr("From %1 to %2")
    .arg(root.isDateBased ? Qt.formatDateTime(root.calendarItem.dateTime) : Qt.formatTime(root.calendarItem.startTime))
    .arg(root.isDateBased ? Qt.formatDateTime(new Date(root.calendarItem.dateTime.getTime() + root.calendarItem.duration * 60000)) : Qt.formatTime(new Date(root.calendarItem.startTime.getTime() + root.calendarItem.duration * 60000)))

    subText: qsTr("repeated %3")
    .arg(repeatingString)

    property string repeatingString: {
        switch (root.calendarItem.repeatingOption.repeatingMode) {
        case RepeatingOption.RepeatingModeNone:
            return qsTr("never");
        case RepeatingOption.RepeatingModeHourly:
            return qsTr("hourly");
        case RepeatingOption.RepeatingModeDaily:
            return qsTr("daily");
        case RepeatingOption.RepeatingModeWeekly:
            var weekdays = []
            for (var i = 0; i < root.calendarItem.repeatingOption.weekDays.length; i++) {
                switch (root.calendarItem.repeatingOption.weekDays[i]) {
                case 1:
                    weekdays.push(qsTr("Mon"));
                    break;
                case 2:
                    weekdays.push(qsTr("Tue"));
                    break;
                case 3:
                    weekdays.push(qsTr("Wed"));
                    break;
                case 4:
                    weekdays.push(qsTr("Thu"));
                    break;
                case 5:
                    weekdays.push(qsTr("Fri"));
                    break;
                case 6:
                    weekdays.push(qsTr("Sat"));
                    break;
                case 7:
                    weekdays.push(qsTr("Sun"));
                    break;
                }
            }

            return qsTr("weekly on %1").arg(weekdays.join(', '));
        case RepeatingOption.RepeatingModeMonthly:
            return qsTr("monthly on the %1").arg(root.calendarItem.repeatingOption.monthDays.join(', '));
        case RepeatingOption.RepeatingModeYearly:
            return qsTr("every year");
        }
    }

}
