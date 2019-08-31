import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    readonly property EventType doorbellPressedType: deviceClass.eventTypes.findByName("doorbellPressed")

    GridLayout {
        anchors.fill: parent
        anchors.topMargin: app.margins
        columns: app.landscape ? 2 : 1
        columnSpacing: app.margins
        rowSpacing: app.margins

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColorIcon {
                id: doorbellIcon
                anchors.centerIn: parent
                height: Math.min(parent.width, parent.height)
                width: height
                name: "../images/notification.svg"

                color: keyColor

                SequentialAnimation {
                    id: ringAnimation
                    ColorAnimation { target: doorbellIcon; property: "color"; from: doorbellIcon.keyColor; to: app.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: app.accentColor; to: doorbellIcon.keyColor; duration: 300 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: doorbellIcon.keyColor; to: app.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: app.accentColor; to: doorbellIcon.keyColor; duration: 300 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: doorbellIcon.keyColor; to: app.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: app.accentColor; to: doorbellIcon.keyColor; duration: 300 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: doorbellIcon.keyColor; to: app.accentColor; duration: 200 }
                    ColorAnimation { target: doorbellIcon; property: "color"; from: app.accentColor; to: doorbellIcon.keyColor; duration: 300 }
                }

                Connections {
                    target: root.device
                    onEventTriggered: {
                        print("evenEmitted", params)
                        if (eventTypeId == root.doorbellPressedType.id) {
                            ringAnimation.start();
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                spacing: app.margins

                ThinDivider {
                    visible: !app.landscape
                }

                RowLayout {
                    spacing: app.margins

                    Label {
                        Layout.fillWidth: true
                    }

                    ColorIcon {
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: app.iconSize
                        name: "../images/alarm-clock.svg"
                        color: app.accentColor
                    }

                    Label {
                        text: qsTr("History")
                    }
                    Label {
                        Layout.fillWidth: true
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    model: LogsModelNg {
                        engine: _engine
                        live: true
                        deviceId: root.device.id
                        typeIds: [root.doorbellPressedType.id]
                    }
                    delegate: NymeaListItemDelegate {
                        width: parent.width
                        text: Qt.formatDateTime(model.timestamp)
                        progressive: false
                        textAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
