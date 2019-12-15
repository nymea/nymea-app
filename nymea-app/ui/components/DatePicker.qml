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
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: app.iconSize
            name: "../images/back.svg"
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
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: app.iconSize
            name: "../images/next.svg"
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
        property bool isLeapYear: false
        property int daysInMonth: isLeapYear ? monthModel.get(root.date.getMonth()).leapDays : monthModel.get(root.date.getMonth()).days
        property int daysInPreviousMonth: isLeapYear ? monthModel.get((root.date.getMonth() + 11) % 12).leapDays : monthModel.get((root.date.getMonth() + 11) % 12).days

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
                color: !isPreviousMonth && !isNextMonth && correctedDayOfMonth == root.date.getDate() ? app.accentColor : "transparent"
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
