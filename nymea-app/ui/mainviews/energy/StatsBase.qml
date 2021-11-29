import QtQuick 2.0
import Nymea 1.0

Item {
    id: root

    property int minutesCount: 10
    property int hoursCount: 12
    property int daysCount: 7
    property int weeksCount: 12
    property int monthsCount: 12

    property var configs: ({
                               minutes: {
                                   startTime: minutesStart,
                                   sampleRate: EnergyLogs.SampleRate1Min,
                                   sampleList: minutesList,
                                   sampleListNames: minutesListNames
                               },
                               hours: {
                                   startTime: hoursStart,
                                   sampleRate: EnergyLogs.SampleRate1Hour,
                                   sampleList: hoursList,
                                   sampleListNames: hoursListNames
                               },
                               days: {
                                   startTime: daysStart,
                                   sampleRate: EnergyLogs.SampleRate1Day,
                                   sampleList: daysList,
                                   sampleListNames: daysListNames
                               },
                               weeks: {
                                   startTime: weeksStart,
                                   sampleRate: EnergyLogs.SampleRate1Week,
                                   sampleList: weeksList,
                                   sampleListNames: weeksListNames
                               },
                               months: {
                                   startTime: monthsStart,
                                   sampleRate: EnergyLogs.SampleRate1Month,
                                   sampleList: monthsList,
                                   sampleListNames: monthsListNames
                               }
                            })

    function minutesStart() {
        var d = new Date();
        d.setMinutes(d.getMinutes() - minutesCount + 1, 0, 0)
        return d;
    }
    function minutesList() {
        var ret = []
        var startTime = minutesStart();
        for (var i = 0; i < minutesCount; i++) {
            var last = new Date(startTime)
            ret.push(last.setTime(last.getTime() + i * 60 * 1000))
        }
        return ret;
    }
    function minutesListNames() {
        var ret = []
        var list = minutesList()
        for (var i = 0; i < list.length; i++) {
            ret.push(new Date(list[i]).toLocaleString(Qt.locale(), "hh:mm"))
        }
        return ret;
    }

    function hoursStart() {
        var d = new Date();
        d.setHours(d.getHours() - hoursCount + 1, 0, 0, 0)
        return d;
    }
    function hoursList() {
        var ret = []
        var startTime = hoursStart();
        for (var i = 0; i < hoursCount; i++) {
            var last = new Date(startTime)
            ret.push(last.setTime(last.getTime() + i * 60 * 60 * 1000))
        }
        return ret;
    }
    function hoursListNames() {
        var ret = [];
        var list = hoursList();
        for (var i = 0; i < list.length; i++) {
            ret.push(new Date(list[i]).toLocaleString(Qt.locale(), "hh"));
        }
        return ret;
    }

    function daysStart() {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setDate(d.getDate() - daysCount + 1);
        return d;
    }

    function daysList() {
        var ret = []
        var startTime = daysStart();
        for (var i = 0; i < daysCount; i++) {
            var last = new Date(startTime)
            ret.push(last.setDate(last.getDate() + i))
        }
        return ret;
    }

    function daysListNames() {
        var ret = []
        var list = daysList();
        for (var i = 0; i < list.length; i++) {
            ret.push(new Date(list[i]).toLocaleString(Qt.locale(), "ddd"))
        }
        return ret;
    }

    function weeksStart() {
        var d = new Date();
        d.setHours(0, 0, 0, 0);
        d.setDate(d.getDate() - d.getDay() - weeksCount * 7);
        return d
    }
    function weeksList() {
        var ret = []
        var startTime = weeksStart();
        for (var i = 0; i < weeksCount; i++) {
            var last = new Date(startTime)
            ret.push(last.setDate(last.getDate() + i * 7))
        }
        return ret;
    }
    function weeksListNames() {
        var ret = []
        var list = weeksList();
        for (var i = 0; i < list.length; i++) {
            var d = new Date(list[i])
            var dayNum = d.getDay() || 7;
            d.setDate(d.getDate() + 4 - dayNum);
            ret.push(Math.ceil((((d - yearStart()) / 86400000) + 1)/7))
        }
        return ret;
    }

    function monthsStart() {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setMonth(d.getMonth() - monthsCount + 1, 1);
        return d;
    }
    function monthsList() {
        var ret = []
        var startTime = monthsStart();
        for (var i = 0; i < monthsCount; i++) {
            var last = new Date(startTime)
            ret.push(last.setMonth(last.getMonth() + i))
        }
        return ret;
    }
    function monthsListNames() {
        var ret = []
        var list = monthsList();
        for (var i = 0; i < list.length; i++) {
            ret.push(new Date(list[i]).toLocaleString(Qt.locale(), "MMM"))
        }
        return ret;
    }

    function yearStart() {
        var d = new Date();
        d.setHours(0,0,0,0);
        d.setDate(1);
        d.setMonth(0);
        return d;
    }

}
