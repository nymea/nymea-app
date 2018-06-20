import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Mea 1.0
import "../components"

MeaListItemDelegate {
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


    iconName: "../images/clock-app-symbolic.svg"

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
