import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Mea 1.0
import "../components"

SwipeDelegate {
    id: root
    implicitHeight: app.delegateHeight

    property var timeEventItem: null

    readonly property bool isDateBased: timeEventItem.repeatingOption.repeatingMode === RepeatingOption.RepeatingModeNone ||
                                        timeEventItem.repeatingOption.repeatingMode === RepeatingOption.RepeatingModeYearly

    signal removeTimeEventItem();

    contentItem: RowLayout {
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: app.iconSize
            name: "../images/alarm-clock.svg"
            color: app.guhAccent
        }

        ColumnLayout {

            Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: qsTr("At %1").arg(root.isDateBased ? Qt.formatDateTime(root.timeEventItem.dateTime) : Qt.formatTime(root.timeEventItem.time))
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("repeated %1").arg(repeatingString)
                elide: Text.ElideRight
                font.pixelSize: app.smallFont

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
        }
    }

    swipe.right: MouseArea {
        height: root.height
        width: height
        anchors.right: parent.right
        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/delete.svg"
            color: "red"
        }
        onClicked: root.removeTimeEventItem()
    }

    onClicked: {
        var page = pageStack.push(Qt.resolvedUrl("EditTimeEventItemPage.qml"), {timeEventItem: root.timeEventItem})
        page.onBackPressed.connect(function() {pageStack.pop()})
        page.onDone.connect(function() {
            pageStack.pop()
            print("timeeventItem.time is now", root.timeEventItem.time)
        })
    }
}
