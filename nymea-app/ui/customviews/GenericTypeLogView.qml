import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Item {
    id: root
    // %1 will be replaced with count
    property string text

    signal addRuleClicked(var value)

    property var logsModel: null

    property alias delegate: listView.delegate

    ColumnLayout {
        anchors.fill: parent

        Label {
            id: titleLabel
            Layout.fillWidth: true
            Layout.margins: app.margins
            wrapMode: Text.WordWrap
            text: root.text.arg(logsModel.count).arg((logsModel.endTime.getTime() - logsModel.startTime.getTime())/ 1000 / 60 / 60 /24)
        }

        ThinDivider {}

        RulesFilterModel {
            id: rulesFilterModel
            rules: Engine.ruleManager.rules
            filterDeviceId: root.logsModel.deviceId
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: logsModel
            clip: true
//            onCountChanged: positionViewAtEnd()

            onContentYChanged: {
                if (!logsModel.busy && contentY - originY < 5 * height) {
                    logsModel.fetchEarlier(24)
                }
            }

            delegate: SwipeDelegate {
                id: logEntryDelegate
                width: parent.width
                implicitHeight: app.delegateHeight
                property var device: Engine.deviceManager.devices.getDevice(model.deviceId)
                property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)
                contentItem: RowLayout {
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: height
                        name: "../images/event.svg"
                        color: app.accentColor
                    }

                    ColumnLayout {
                        Label {
                            id: timeStampLabel
                            Layout.fillWidth: true
                            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss")
                        }
                        Label {
                            Layout.fillWidth: true
                            text: "%1: %2".arg(deviceClass.eventTypes.getEventType(model.typeId).displayName).arg(model.value.trim())
                            elide: Text.ElideRight
                            font.pixelSize: app.smallFont
                        }
                    }
//                    ColorIcon {
//                        Layout.preferredWidth: app.iconSize
//                        Layout.preferredHeight: width
//                        name: "../images/magic.svg"
//                        color: {
//                            for (var i = 0; i < rulesFilterModel.count; i++) {
//                                var rule = rulesFilterModel.get(i);
//                                for (var j = 0; j < rule.eventDescriptors.count; j++) {
//                                    var eventDescriptor = rule.eventDescriptors.get(j);
//                                    if (eventDescriptor.eventTypeId === root.logsModel.typeId) {
//                                        var matching = true;
//                                        for (var k = 0; k < eventDescriptor.paramDescriptors.count; k++) {
//                                            var paramDescriptor = eventDescriptor.paramDescriptors.get(k);
//                                            if (paramDescriptor.value === model.value) {
//                                                return app.accentColor;
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            return keyColor;
//                        }

//                    }
                }
                swipe.right: MouseArea {
                    height: logEntryDelegate.height
                    width: height
                    anchors.right: parent.right
                    ColorIcon {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        name: "../images/magic.svg"
                    }
                    onClicked: root.addRuleClicked(model.value)
                }
                onClicked: {
                    if (swipe.complete) {
                        swipe.close()
                    } else {
                        swipe.open(SwipeDelegate.Right)
                    }
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                visible: root.logsModel.busy
                running: visible
            }
        }
    }
}
