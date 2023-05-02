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

import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.calendar 1.0
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

Page {
    id: root

    property var calendarItem: null

    signal done()
    signal backPressed()

    readonly property bool isDateBased: repeatingBox.currentIndex === 0 ||
                                        repeatingBox.currentIndex === 5
    readonly property bool isWeekDayBased: repeatingBox.currentIndex === 3
    readonly property bool isMonthDayBased: repeatingBox.currentIndex === 4

    header: NymeaHeader {
        text: qsTr("Pick a time frame")
        onBackPressed: root.backPressed();
    }

    Component.onCompleted: {
        var date = root.isDateBased ? root.calendarItem.dateTime : root.calendarItem.startTime
        print("starting with time:", root.calendarItem.startTime, root.calendarItem.dateTime)
        if (isNaN(date)) {
            console.log("Date in rule not valid, using current datetime");
            date = new Date();
        }
        hourBox.currentIndex = date.getHours();
        minuteBox.currentIndex = date.getMinutes();
        dayBox.currentIndex = date.getDate() - 1;
        monthBox.currentIndex = date.getMonth();
        print("should set year to", date.getFullYear())
        yearBox.currentIndex = date.getFullYear() - 1970;

        var endDate = new Date(date.getTime() + root.calendarItem.duration * 60000);
        toHourBox.currentIndex = endDate.getHours();
        toMinuteBox.currentIndex = endDate.getMinutes();
        toDayBox.currentIndex = endDate.getDate() - 1;
        toMonthBox.currentIndex = endDate.getMonth();
        toYearBox.currentIndex = endDate.getFullYear() - 1970
    }

    function pad(num, size) {
        var s = "000000000" + num;
        return s.substr(s.length-size);
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight

        ColumnLayout {
            id: mainColumn
            anchors { left: parent.left; top: parent.top; right: parent.right }

            GridLayout {
                columns: app.landscape ? 2 : 1
                Layout.alignment: app.landscape ? Qt.AlignHCenter : Qt.AlignLeft
                Layout.margins: Style.margins
                Layout.fillWidth: !app.landscape

                Label {
                    text: qsTr("From")
                }

                RowLayout {
                    ComboBox {
                        id: hourBox
                        model: {
                            if (!enabled) {
                                return ["--"]
                            }

                            var ret = [];
                            for (var i = 0; i < 24; i++) {
                                ret.push(pad(i, 2));
                            }
                            return ret;
                        }
                        enabled: repeatingBox.currentIndex !== 1
                    }
                    Label {
                        text: ":"
                    }
                    ComboBox {
                        id: minuteBox
                        model: {
                            var ret = [];
                            for (var i = 0; i < 60; i++) {
                                ret.push(pad(i, 2));
                            }
                            return ret;
                        }
                    }
                }

                RowLayout {
                    Layout.fillHeight: !app.landscape
                    Layout.topMargin: app.landscape ? Style.margins : 0
                    visible: root.isDateBased
                    ComboBox {
                        id: dayBox
                        Layout.fillWidth: true
                        model: {
                            var ret = [];
                            for (var i = 1; i < 31; i++) {
                                ret.push(pad(i, 2));
                            }
                            return ret;
                        }
                    }
                    ComboBox {
                        id: monthBox
                        Layout.fillWidth: true
                        model: [
                            qsTr("Jan"),
                            qsTr("Feb"),
                            qsTr("Mar"),
                            qsTr("Apr"),
                            qsTr("May"),
                            qsTr("Jun"),
                            qsTr("Jul"),
                            qsTr("Aug"),
                            qsTr("Sep"),
                            qsTr("Oct"),
                            qsTr("Nov"),
                            qsTr("Dez")
                        ]
                    }
                    ComboBox {
                        id: yearBox
                        Layout.fillWidth: true
                        model: {
                            var ret = [];
                            for (var i = 1970; i < 2100; i++) {
                                ret.push(i);
                            }
                            return ret;
                        }
                    }
                }

                Label {
                    text: qsTr("To")
                }

                RowLayout {
                    ComboBox {
                        id: toHourBox
                        model: {
                            if (!enabled) {
                                return ["--"]
                            }

                            var ret = [];
                            for (var i = 0; i < 24; i++) {
                                ret.push(pad(i, 2));
                            }
                            return ret;
                        }
                        enabled: repeatingBox.currentIndex !== 1
                    }
                    Label {
                        text: ":"
                    }
                    ComboBox {
                        id: toMinuteBox
                        model: {
                            var ret = [];
                            for (var i = 0; i < 60; i++) {
                                ret.push(pad(i, 2));
                            }
                            return ret;
                        }
                    }
                }

                RowLayout {
                    Layout.fillHeight: !app.landscape
                    Layout.topMargin: app.landscape ? Style.margins : 0
                    visible: root.isDateBased
                    ComboBox {
                        id: toDayBox
                        Layout.fillWidth: true
                        model: {
                            var ret = [];
                            for (var i = 1; i < 31; i++) {
                                ret.push(pad(i, 2));
                            }
                            return ret;
                        }
                        onActivated: {
                            var date = root.calendarItem.dateTime
                            date.setDate(index)
                            root.calendarItem.dateTime = date;
                        }
                    }
                    ComboBox {
                        id: toMonthBox
                        Layout.fillWidth: true
                        model: [
                            qsTr("Jan"),
                            qsTr("Feb"),
                            qsTr("Mar"),
                            qsTr("Apr"),
                            qsTr("May"),
                            qsTr("Jun"),
                            qsTr("Jul"),
                            qsTr("Aug"),
                            qsTr("Sep"),
                            qsTr("Oct"),
                            qsTr("Nov"),
                            qsTr("Dez")
                        ]
                    }
                    ComboBox {
                        id: toYearBox
                        Layout.fillWidth: true
                        model: {
                            var ret = [];
                            for (var i = 1970; i < 2100; i++) {
                                ret.push(i);
                            }
                            return ret;
                        }
                    }
                }

                Label {
                    text: qsTr("Repeat")
                    Layout.topMargin: Style.margins
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: app.landscape ? Style.margins : 0

                    ComboBox {
                        id: repeatingBox
                        Layout.fillWidth: true
                        model: [qsTr("never"), qsTr("hourly"), qsTr("daily"), qsTr("weekly"), qsTr("monthly"), qsTr("yearly")]

                        currentIndex: {
                            switch (root.calendarItem.repeatingOption.repeatingMode) {
                            case RepeatingOption.RepeatingModeNone:
                                return 0;
                            case RepeatingOption.RepeatingModeHourly:
                                return 1;
                            case RepeatingOption.RepeatingModeDaily:
                                return 2;
                            case RepeatingOption.RepeatingModeWeekly:
                                return 3;
                            case RepeatingOption.RepeatingModeMonthly:
                                return 4;
                            case RepeatingOption.RepeatingModeYearly:
                                return 5;
                            }
                            return 0;
                        }
                    }
                }



                Label {
                    text: qsTr("Weekdays")
                    Layout.topMargin: Style.margins
                    visible: root.isWeekDayBased
                }

                DayOfWeekRow {
                    id: weekDayRow
                    property var weekDays: root.calendarItem.repeatingOption.weekDays
                    visible: root.isWeekDayBased
                    Layout.fillWidth: !app.landscape
                    Layout.topMargin: app.landscape ? Style.margins : 0
                    delegate: ToolButton {
                        text: model.shortName
                        checked: weekDayRow.weekDays.indexOf(index + 1) >= 0
                        onClicked: {
                            var copy = weekDayRow.weekDays
                            var idx = copy.indexOf(index + 1);
                            if (idx >= 0) {
                                copy.splice(idx, 1);
                            } else {
                                copy.push(index + 1)
                            }
                            weekDayRow.weekDays = copy
                        }
                    }
                }


                Label {
                    text: qsTr("Day of month")
                    Layout.topMargin: Style.margins
                    visible: root.isMonthDayBased
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                }

                GridLayout {
                    id: monthDayGrid
                    columns: Math.sqrt(children.length)
                    Layout.fillWidth: !app.landscape
                    Layout.topMargin: app.landscape ? Style.margins : 0
                    visible: root.isMonthDayBased
                    property var monthDays: root.calendarItem.repeatingOption.monthDays
                    Repeater {
                        model: 31
                        delegate: ToolButton {
                            Layout.fillWidth: true
                            checked: monthDayGrid.monthDays.indexOf(index + 1) >= 0
                            text: modelData + 1
                            onClicked: {
                                var copy = monthDayGrid.monthDays
                                var idx = copy.indexOf(index + 1);
                                if (idx >= 0) {
                                    copy.splice(idx, 1);
                                } else {
                                    copy.push(index + 1)
                                }
                                monthDayGrid.monthDays = copy
                            }
                        }
                    }
                }

            }

            Button {
                Layout.fillWidth: !app.landscape
                Layout.margins: Style.margins
                Layout.alignment: Qt.AlignRight
                text: qsTr("OK")
                onClicked: {
                    if (root.isDateBased) {
                        var date = isNaN(root.calendarItem.dateTime) ? new Date() : root.calendarItem.dateTime
                        date.setHours(hourBox.currentIndex);
                        date.setMinutes(minuteBox.currentIndex);
                        date.setDate(dayBox.currentIndex + 1);
                        date.setMonth(monthBox.currentIndex);
                        date.setFullYear(yearBox.currentText);
                        root.calendarItem.dateTime = date;

                        var endDate = new Date();
                        endDate.setHours(toHourBox.currentIndex);
                        endDate.setMinutes(toMinuteBox.currentIndex);
                        endDate.setDate(toDayBox.currentIndex + 1);
                        endDate.setMilliseconds(toMonthBox.currentIndex);
                        endDate.setFullYear(toYearBox.currentText);
                        root.calendarItem.duration = (endDate.getTime() - date.getTime()) / 60000;
                    } else {
                        var time = isNaN(root.calendarItem.startTime) ? new Date() : root.calendarItem.startTime
                        time.setHours(hourBox.currentIndex);
                        time.setMinutes(minuteBox.currentIndex)
                        root.calendarItem.startTime = time;

                        var endTime = new Date(time);
                        endTime.setHours(toHourBox.currentIndex);
                        endTime.setMinutes(toMinuteBox.currentIndex);
                        root.calendarItem.duration = (endTime.getTime() - time.getTime()) / 60000;
                        if (endTime.getTime() < time.getTime()) {
                            root.calendarItem.duration += (60 * 24)
                        }
                    }

                    switch (repeatingBox.currentIndex) {
                    case 0:
                        root.calendarItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeNone;
                        break;
                    case 1:
                        root.calendarItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeHourly;
                        break;
                    case 2:
                        root.calendarItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeDaily;
                        break;
                    case 3:
                        root.calendarItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeWeekly;
                        break;
                    case 4:
                        root.calendarItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeMonthly;
                        break;
                    case 5:
                        root.calendarItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeYearly;
                        break;
                    }

                    if (root.isWeekDayBased) {
                        root.calendarItem.repeatingOption.weekDays = weekDayRow.weekDays;
                    }
                    if (root.isMonthDayBased) {
                        root.calendarItem.repeatingOption.monthDays = monthDayGrid.monthDays;
                    }

                    root.done()
                }
            }
        }
    }
}
