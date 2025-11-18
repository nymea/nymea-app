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

import QtQuick 2.0
import Nymea 1.0

Item {
    id: root

    property int minutesCount: 9
    property int hoursCount: 10
    property int daysCount: 7
    property int weeksCount: 10
    property int monthsCount: 6
    property int yearsCount: 5

    property var configs: ({
                               minutes: {
                                   count: minutesCount,
                                   startTime: minutesStart,
                                   sampleRate: EnergyLogs.SampleRate1Min,
                                   toLabel: minuteLabel,
                                   toLongLabel: minuteLongLabel,
                                   toRangeLabel: minuteRangeLabel
                               },
                               hours: {
                                   count: hoursCount,
                                   startTime: hoursStart,
                                   sampleRate: EnergyLogs.SampleRate1Hour,
                                   toLabel: hourLabel,
                                   toLongLabel: hourLongLabel,
                                   toRangeLabel: hourRangeLabel
                               },
                               days: {
                                   count: daysCount,
                                   startTime: daysStart,
                                   sampleRate: EnergyLogs.SampleRate1Day,
                                   toLabel: dayLabel,
                                   toLongLabel: dayLongLabel,
                                   toRangeLabel: dayRangeLabel
                               },
                               weeks: {
                                   count: weeksCount,
                                   startTime: weeksStart,
                                   sampleRate: EnergyLogs.SampleRate1Week,
                                   toLabel: weekLabel,
                                   toLongLabel: weekLongLabel,
                                   toRangeLabel: weekRangeLabel
                               },
                               months: {
                                   count: monthsCount,
                                   startTime: monthsStart,
                                   sampleRate: EnergyLogs.SampleRate1Month,
                                   toLabel: monthLabel,
                                   toLongLabel: monthLongLabel,
                                   toRangeLabel: monthRangeLabel
                               },
                               years: {
                                   count: yearsCount,
                                   startTime: yearStart,
                                   sampleRate: EnergyLogs.SampleRate1Year,
                                   toLabel: yearLabel,
                                   toLongLabel: yearLongLabel,
                                   toRangeLabel: yearRangeLabel
                               }
                            })

    function calculateTimestamp(baseTime, sampleRate, offset) {
        var timestamp = new Date(baseTime);
        if (sampleRate === EnergyLogs.SampleRate1Year) {
            timestamp.setFullYear(baseTime.getFullYear() + offset)
        } else if (sampleRate === EnergyLogs.SampleRate1Month) {
            timestamp.setMonth(baseTime.getMonth() + offset)
        } else if (sampleRate === EnergyLogs.SampleRate1Week) {
            timestamp.setDate(baseTime.getDate() + offset * 7)
        } else if (sampleRate === EnergyLogs.SampleRate1Day) {
            timestamp.setDate(baseTime.getDate() + offset)
        } else if (sampleRate === EnergyLogs.SampleRate1Hour) {
            timestamp.setHours(timestamp.getHours() + offset)
        } else {
            timestamp.setTime(baseTime.getTime() + (sampleRate * 60000 * offset))
        }
        return timestamp;
    }

    function minutesStart() {
        var d = new Date();
        d.setMinutes(d.getMinutes() - minutesCount + 1, 0, 0)
        return d;
    }
    function minuteLabel(date) {
        return date.toLocaleString(Qt.locale(), "hh:mm")
    }
    function minuteLongLabel(date) {
        return date.toLocaleString(Qt.locale(), Locale.ShortFormat)
    }
    function minuteRangeLabel(date) {
        return date.toLocaleString(Qt.locale(), Locale.ShortFormat) + " - " + new Date(date.getTime() + root.minutesCount * 60000).toLocaleString(Qt.locale(), Locale.ShortFormat)
    }


    function hoursStart() {
        var d = new Date();
        d.setHours(d.getHours() - hoursCount + 1, 0, 0, 0)
        return d;
    }
    function hourLabel(date) {
        return date.toLocaleString(Qt.locale(), "hh")
    }
    function hourLongLabel(date) {
        return date.toLocaleString(Qt.locale(), Locale.ShortFormat)
    }
    function hourRangeLabel(date) {
        return date.toLocaleString(Qt.locale(), Locale.ShortFormat) + " - " +  new Date(date.getTime() + root.hoursCount * 60 * 60000).toLocaleString(Qt.locale(), Locale.ShortFormat)
    }

    function daysStart() {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setDate(d.getDate() - daysCount + 1);
        return d;
    }
    function dayLabel(date) {
        return date.toLocaleString(Qt.locale(), "ddd")
    }
    function dayLongLabel(date) {
        return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
    }
    function dayRangeLabel(date) {
        return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " - " + new Date(date.getTime() + root.daysCount * 24 * 60 * 60000).toLocaleDateString(Qt.locale(), Locale.ShortFormat)
    }

    function weeksStart() {
        var d = new Date();
        d.setHours(0, 0, 0, 0);
//        print("now is:", d, "weeksCount:", weeksCount)
        // We'll start the week on Monday for now, given that's international ISO standard. For US and Canada we may want to introduce a setting at some point.
        // JS Date starts on Sunday though, so we'll have to adjust
        var dayOfWeek = (d.getDay() + 6) % 7
//        print("getDay", d.getDay(), "dayOfWeek", dayOfWeek, "getDate", d.getDate())
        d.setDate(d.getDate() - dayOfWeek - (weeksCount - 1) * 7);
        return d
    }
    function weekLabel(date) {
        var yearStart = new Date(date);
        yearStart.setHours(0,0,0,0);
        yearStart.setDate(1);
        yearStart.setMonth(0);
        return Math.ceil((((date - yearStart) / 86400000) + 1)/7)
    }
    function weekLongLabel(date) {
        var endDate = new Date(date)
        endDate.setDate(endDate.getDate() + 6)
        return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " - " + endDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
    }
    function weekRangeLabel(date) {
        var endDate = new Date(date)
        endDate.setDate(endDate.getDate() + (7 * root.weeksCount))
        return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " - " + endDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
    }


    function monthsStart() {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setMonth(d.getMonth() - monthsCount + 1, 1);
        return d;
    }
    function monthLabel(date) {
        return date.toLocaleString(Qt.locale(), "MMM")
    }
    function monthLongLabel(date) {
        return date.toLocaleString(Qt.locale(), "MMMM yyyy")
    }
    function monthRangeLabel(date) {
        var endDate = new Date(date);
        endDate.setMonth(date.getMonth() + monthsCount - 1)
        return date.toLocaleString(Qt.locale(), "MMMM yyyy") + " - " + endDate.toLocaleString(Qt.locale(), "MMMM yyyy")
    }

    function yearStart() {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setFullYear(d.getFullYear() - yearsCount + 1, 0, 1)
        return d;
    }
    function yearLabel(date) {
        return date.toLocaleString(Qt.locale(), "yyyy")
    }
    function yearLongLabel(date) {
        return date.toLocaleString(Qt.locale(), "yyyy")
    }
    function yearRangeLabel(date) {
        return ""
    }

}
