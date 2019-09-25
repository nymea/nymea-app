import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Item {
    id: root

    signal addRuleClicked(int index)

    property var logsModel: null

    property alias delegate: listView.delegate

    ListView {
        id: listView
        anchors.fill: parent
        model: logsModel
        clip: true

        ScrollBar.vertical: ScrollBar {}

        SwipeDelegateGroup {}

        onContentYChanged: {
            if (!engine.jsonRpcClient.ensureServerVersion("1.10")) {
                if (!logsModel.busy && contentY - originY < 5 * height) {
                    logsModel.fetchEarlier(24)
                }
            }
        }

        delegate: SwipeDelegate {
            id: logEntryDelegate
            width: parent.width
            implicitHeight: app.delegateHeight
            property var device: engine.deviceManager.devices.getDevice(model.deviceId)
            property var deviceClass: engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)
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
                        text: deviceClass.eventTypes.getEventType(model.typeId).displayName + (model.value.length > 0 ? (": " + model.value.trim()) : "")
                        elide: Text.ElideRight
                        font.pixelSize: app.smallFont
                    }
                }
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
                onClicked: root.addRuleClicked(index)
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
