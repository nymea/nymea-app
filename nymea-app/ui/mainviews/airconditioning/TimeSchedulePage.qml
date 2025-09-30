import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import Nymea.AirConditioning

import "qrc:/ui/components"
import "qrc:/ui/customviews"

Page {
    id: root
    property AirConditioningManager acManager: null
    property ZoneInfo zone: null

    readonly property TemperatureWeekSchedule weekSchedule: zone.weekSchedule.clone()


    header: NymeaHeader {
        text: root.zone.name

        onBackPressed: {
            pageStack.pop()
        }

        HeaderButton {
            imageSource: "tick"
            onClicked: {
                acManager.setZoneWeekSchedule(root.zone.id, root.weekSchedule)
                pageStack.pop();
            }
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: editorItem.width
        contentHeight: editorItem.height
        clip: true

        Item {
            id: editorItem
            width: flickable.width
            height: childrenRect.height + Style.margins * 2

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right; margins: Style.margins }

//                RowLayout {
//                    Label {
//                        text: qsTr("Base temperature: %1 %2").arg(Types.toUiValue(zone.standbySetpoint, Types.UnitDegreeCelsius)).arg(Types.toUiUnit(Types.UnitDegreeCelsius))
//                    }
//                }

                Repeater {
                    id: scheduleRepeater
                    model: [
                        qsTr("Monday"),
                        qsTr("Tuesday"),
                        qsTr("Wednesday"),
                        qsTr("Thursday"),
                        qsTr("Friday"),
                        qsTr("Saturday"),
                        qsTr("Sunday")
                    ]
                    property TemperatureDaySchedule scheduleClipboard: null

                    delegate: TemperatureScheduleEditor {
                        title: modelData
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        zone: root.zone
                        daySchedule: weekSchedule.get(index)
                        scheduleClipboard: scheduleRepeater.scheduleClipboard
                        onCopyClicked: {
                            if (scheduleRepeater.scheduleClipboard == daySchedule) {
                                scheduleRepeater.scheduleClipboard = null
                            } else {
                                scheduleRepeater.scheduleClipboard = daySchedule
                            }
                        }
                    }
                }

        //        CheckBox {
        //            text: qsTr("Use sunday schedule for public holidays.")
        //        }
            }
        }

    }




//    Item {
//        id: scheduleEditor
//        anchors.fill: parent
//        anchors.margins: Style.margins

//        Rectangle {
//            id: slider
//            anchors {
//                top: parent.top
//                left: parent.left
//                bottom: parent.bottom
//            }
//            width: Style.largeDelegateHeight
//            color: Style.tileBackgroundColor
//            radius: Style.cornerRadius


//            Repeater {
//                model: root.temperatureSchedules
//                delegate: Rectangle {
//                    readonly property TemperatureSchedule temperatureSchedule: root.temperatureSchedules.get(index)
//                    readonly property int startMinutes: temperatureSchedule.startTime.getHours() * 60 + temperatureSchedule.startTime.getMinutes()
//                    readonly property int endMinutes: temperatureSchedule.endTime.getHours() * 60 + temperatureSchedule.endTime.getMinutes()
//                    readonly property int totalMinutes: 24 * 60
//                    width: scheduleEditor.width
//                    // h : 24 = x : s
//                    y: startMinutes * slider.height / totalMinutes
//                    height: endMinutes * slider.height / totalMinutes - y
//                    radius: Style.cornerRadius
//                    color: Style.tileBackgroundColor
//                    Component.onCompleted: print("**created, startTime", startMinutes, endMinutes, totalMinutes, y, height)
//                }
//            }

//            Repeater {
//                model: 24
//                delegate: Item {
//                    width: parent.width
//                    height: slider.height / 24
//                    y: height * index
//                    Rectangle {
//                        width: parent.width
//                        height: 1
//                        color: Style.gray
//                        visible: index > 0
//                    }
//                    Label {
//                        width: parent.width
//                        text: {
//                            var d = new Date();
//                            d.setHours(index,0,0);
//                            return d.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
//                        }
//                        height: parent.height
//                        horizontalAlignment: Text.AlignHCenter
//                        verticalAlignment: Text.AlignVCenter
//                        font: Style.smallFont
//                    }
//                }
//            }

//        }
//        MouseArea {
//            anchors.fill: parent

//            property bool moveStart: false
//            property bool moveEnd: false
//            property TemperatureSchedule movedSchedule: null

//            property int startMouseY: 0
//            property int startMins: 0
//            property int endMins: 0

//            onPressed: {
//                startMouseY = mouseY
//                var totalMins = 24 * 60
//                for (var i = 0; i < root.temperatureSchedules.count; i++) {
//                    var schedule = root.temperatureSchedules.get(i)
//                    print("schedule:", schedule.startTime, schedule.endTime)
//                    var startMin = schedule.startTime.getHours() * 60 + schedule.startTime.getMinutes()
//                    var startPos = startMin * slider.height / totalMins
//                    var endMin = schedule.endTime.getHours() * 60 + schedule.endTime.getMinutes()
//                    var endPos = endMin * slider.height / totalMins

//                    startMins = startMin
//                    endMins = endMin
//                    movedSchedule = schedule
//                    if (Math.abs(startPos - mouseY) < 10) {
//                        moveStart = true;
//                        print("start")
//                        break;
//                    } else if (Math.abs(endPos - mouseY) < 10) {
//                        moveEnd = true
//                        print("end")
//                        break;
//                    } else if (mouseY > startPos && mouseY < endPos) {
//                        moveStart = true
//                        moveEnd = true
//                        print("middle")
//                        break;
//                    }
//                }
//            }
//            onReleased: {
//                moveStart = false;
//                moveEnd = false;
//                movedSchedule = null
//            }

//            onPositionChanged: {
//                var totalMins = 24 * 60
//                var diffY = mouseY - startMouseY
//                // dY : height = dM : total
//                var diffMins = diffY * totalMins / slider.height
//                print("diffY", diffY, "diffMins", diffMins, startMins, startMins + diffMins)

//                var newStart = new Date(movedSchedule.startTime);
//                var newEnd = new Date(movedSchedule.endTime);

//                var newStartMins = startMins + (moveStart ? diffMins : 0);
//                var newEndMins = endMins + (moveEnd ? diffMins : 0);


//                if (moveStart && !moveEnd) {
//                    newStartMins = Math.max(0, newStartMins)
//                    newStartMins = Math.min(newEndMins - 60, newStartMins)
//                } else if (moveEnd && !moveStart) {
//                    newEndMins = Math.min(totalMins - 1, newEndMins)
//                    newEndMins = Math.max(newStartMins + 60, newEndMins)
//                } else if (moveStart && moveEnd) {
//                    newStartMins = Math.max(0, newStartMins)
//                    newEndMins = Math.min(totalMins - 1, newEndMins)

//                    var blockSize = endMins - startMins

//                    newStartMins = Math.max(0, Math.min(newEndMins - blockSize, newStartMins))
//                    newEndMins = Math.max(newStartMins + blockSize, newEndMins)

//                }



//                newStart.setHours(0, newStartMins)
//                newEnd.setHours(0, newEndMins)

//                movedSchedule.startTime = newStart
//                movedSchedule.endTime = newEnd

//                print("start time is new", newStart.toLocaleTimeString())
//                print("end time is new", newEnd.toLocaleTimeString())

//            }
//        }

//        ProgressButton {
//            anchors.centerIn: parent
//            imageSource: "add"
//            onClicked: {
//                var startTime = new Date()
//                startTime.setHours(7, 0, 0)
//                var endTime = new Date()
//                endTime.setHours(22, 0 , 0)
//                root.temperatureSchedules.createTemperatureSchedule(startTime, endTime, 21)
//            }
//        }
//    }


}
