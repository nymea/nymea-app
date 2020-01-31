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

    property var timeEventItem: null

    signal done()
    signal backPressed()

    readonly property bool isDateBased: repeatingBox.currentIndex === 0 ||
                                        repeatingBox.currentIndex === 5
    readonly property bool isWeekDayBased: repeatingBox.currentIndex === 3
    readonly property bool isMonthDayBased: repeatingBox.currentIndex === 4

    header: NymeaHeader {
        text: qsTr("Pick a time")
        onBackPressed: root.backPressed();
    }

    Component.onCompleted: {
        var date = root.isDateBased ? root.timeEventItem.dateTime : root.timeEventItem.time
        print("starting with time:", root.timeEventItem.time, root.timeEventItem.dateTime)
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
                Layout.margins: app.margins
                Layout.fillWidth: !app.landscape

                Label {
                    text: qsTr("Time")
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

                Label {
                    text: qsTr("Repeat")
                    Layout.topMargin: app.margins
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: app.landscape ? app.margins : 0

                    ComboBox {
                        id: repeatingBox
                        model: [qsTr("never"), qsTr("hourly"), qsTr("daily"), qsTr("weekly"), qsTr("monthly"), qsTr("yearly")]

                        currentIndex: {
                            switch (root.timeEventItem.repeatingOption.repeatingMode) {
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
                    text: qsTr("Date")
                    Layout.topMargin: app.margins
                    visible: root.isDateBased
                }

                RowLayout {
                    Layout.fillHeight: !app.landscape
                    Layout.topMargin: app.landscape ? app.margins : 0
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
                    text: qsTr("Weekdays")
                    Layout.topMargin: app.margins
                    visible: root.isWeekDayBased
                }

                DayOfWeekRow {
                    id: weekDayRow
                    property var weekDays: root.timeEventItem.repeatingOption.weekDays
                    visible: root.isWeekDayBased
                    Layout.fillWidth: !app.landscape
                    Layout.topMargin: app.landscape ? app.margins : 0
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
                    Layout.topMargin: app.margins
                    visible: root.isMonthDayBased
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                }

                GridLayout {
                    id: monthDayGrid
                    columns: Math.sqrt(children.length)
                    Layout.fillWidth: !app.landscape
                    Layout.topMargin: app.landscape ? app.margins : 0
                    visible: root.isMonthDayBased
                    property var monthDays: root.timeEventItem.repeatingOption.monthDays
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
                Layout.margins: app.margins
                Layout.alignment: Qt.AlignRight
                text: qsTr("OK")
                onClicked: {
                    if (root.isDateBased) {
                        var date = isNaN(root.timeEventItem.dateTime) ? new Date() : root.timeEventItem.dateTime
                        date.setHours(hourBox.currentIndex);
                        date.setMinutes(minuteBox.currentIndex);
                        date.setDate(dayBox.currentIndex + 1);
                        date.setMonth(monthBox.currentIndex);
                        date.setYear(yearBox.currentText);
                        root.timeEventItem.dateTime = date;
                    } else {
                        var time = isNaN(root.timeEventItem.time) ? new Date() : root.timeEventItem.time
                        time.setHours(hourBox.currentIndex);
                        time.setMinutes(minuteBox.currentIndex)
                        root.timeEventItem.time = time;
                    }

                    switch (repeatingBox.currentIndex) {
                    case 0:
                        root.timeEventItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeNone;
                        break;
                    case 1:
                        root.timeEventItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeHourly;
                        break;
                    case 2:
                        root.timeEventItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeDaily;
                        break;
                    case 3:
                        root.timeEventItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeWeekly;
                        break;
                    case 4:
                        root.timeEventItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeMonthly;
                        break;
                    case 5:
                        root.timeEventItem.repeatingOption.repeatingMode = RepeatingOption.RepeatingModeYearly;
                        break;
                    }

                    if (root.isWeekDayBased) {
                        root.timeEventItem.repeatingOption.weekDays = weekDayRow.weekDays;
                    }
                    if (root.isMonthDayBased) {
                        root.timeEventItem.repeatingOption.monthDays = monthDayGrid.monthDays;
                    }

                    root.done()
                }
            }
        }
    }

}
