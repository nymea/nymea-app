import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "../components"

Item {
    id: root
    // %1 will be replaced with count
    property string text

    signal addRuleClicked(var value)

    property var logsModel: null

    ColumnLayout {
        anchors.fill: parent

        Label {
            id: titleLabel
            Layout.fillWidth: true
            Layout.margins: app.margins
            wrapMode: Text.WordWrap
            text: root.text.arg(logsModel.count)
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
            onCountChanged: positionViewAtEnd()
            delegate: ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    ColumnLayout {
                        Layout.fillWidth: true
                        RowLayout {
                            Layout.fillWidth: true

                            ColorIcon {
                                Layout.preferredHeight: timeStampLabel.height
                                Layout.preferredWidth: height
                                name: "../images/clock-app-symbolic.svg"
                            }

                            Label {
                                id: timeStampLabel
                                Layout.fillWidth: true
                                text: Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss")
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: qsTr("Data:")
                            }
                            Label {
                                Layout.fillWidth: true
                                text: model.value.trim()
                                elide: Text.ElideRight
                            }
                        }
                    }
                    HeaderButton {
                        imageSource: "../images/magic.svg"
                        color: {
                            for (var i = 0; i < rulesFilterModel.count; i++) {
                                var rule = rulesFilterModel.get(i);
                                for (var j = 0; j < rule.eventDescriptors.count; j++) {
                                    var eventDescriptor = rule.eventDescriptors.get(j);
                                    if (eventDescriptor.eventTypeId === root.logsModel.typeId) {
                                        var matching = true;
                                        for (var k = 0; k < eventDescriptor.paramDescriptors.count; k++) {
                                            var paramDescriptor = eventDescriptor.paramDescriptors.get(k);
                                            if (paramDescriptor.value === model.value) {
                                                return app.guhAccent;
                                            }
                                        }
                                    }
                                }
                            }
                            return keyColor;
                        }

                        onClicked: root.addRuleClicked(model.value)
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
