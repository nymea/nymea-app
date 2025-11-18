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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

NymeaSwipeDelegate{
    id: root
    implicitHeight: app.delegateHeight
    progressive: false
    canDelete: true

    property var timeEventItem: null

    readonly property bool isDateBased: timeEventItem.repeatingOption.repeatingMode === RepeatingOption.RepeatingModeNone ||
                                        timeEventItem.repeatingOption.repeatingMode === RepeatingOption.RepeatingModeYearly

    signal removeTimeEventItem();

    onDeleteClicked: root.removeTimeEventItem()

    onClicked: {
        var page = pageStack.push(Qt.resolvedUrl("EditTimeEventItemPage.qml"), {timeEventItem: root.timeEventItem})
        page.onBackPressed.connect(function() {pageStack.pop()})
        page.onDone.connect(function() {
            pageStack.pop()
            print("timeeventItem.time is now", root.timeEventItem.time)
        })
    }

    iconName: "qrc:/icons/alarm-clock.svg"
    text: qsTr("At %1").arg(root.isDateBased ? Qt.formatDateTime(root.timeEventItem.dateTime) : Qt.formatTime(root.timeEventItem.time))
    subText: qsTr("repeated %1").arg(repeatingString)

    property string repeatingString: {
        switch (root.timeEventItem.repeatingOption.repeatingMode) {
        case RepeatingOption.RepeatingModeNone:
            return qsTr("never");
        case RepeatingOption.RepeatingModeHourly:
            return qsTr("hourly");
        case RepeatingOption.RepeatingModeDaily:
            return qsTr("daily");
        case RepeatingOption.RepeatingModeWeekly:
            var weekdays = []
            for (var i = 0; i < root.timeEventItem.repeatingOption.weekDays.length; i++) {
                switch (root.timeEventItem.repeatingOption.weekDays[i]) {
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
            return qsTr("monthly on the %1").arg(root.timeEventItem.repeatingOption.monthDays.join(', '));
        case RepeatingOption.RepeatingModeYearly:
            return qsTr("every year");
        }
    }
}
