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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("General settings")
    busy: d.pendingCommand !== -1

    QtObject {
        id: d
        property int pendingCommand: -1
    }

    Connections {
        target: engine.systemController
        onRestartReply: handleReply(id, success)
        onRebootReply: handleReply(id, success)
        onShutdownReply: handleReply(id, success)

        function handleReply(id, success) {
            if (id === d.pendingCommand) {
                d.pendingCommand = -1
                if (!success) {
                    var component = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
                    var popup = component.createObject(root);
                    popup.open()
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("General")
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        spacing: app.margins

        Label {
            text: qsTr("Name")
            Layout.fillWidth: true
        }
        TextField {
            id: nameTextField
            Layout.fillWidth: true
            text: engine.nymeaConfiguration.serverName
        }
        Button {
            text: qsTr("OK")
            visible: nameTextField.displayText !== engine.nymeaConfiguration.serverName
            onClicked: engine.nymeaConfiguration.serverName = nameTextField.displayText
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Date and time")
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        visible: engine.jsonRpcClient.ensureServerVersion("4.1") && engine.systemController.automaticTimeAvailable
        Label {
            text: qsTr("Set date and time automatically")
            Layout.fillWidth: true
        }
        CheckBox {
            checked: engine.systemController.automaticTime
            onClicked: {
                engine.systemController.automaticTime = checked
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        spacing: app.margins
        Layout.preferredHeight: dateButton.implicitHeight
        visible: engine.jsonRpcClient.ensureServerVersion("4.1")
        Label {
            text: qsTr("Date")
            Layout.fillWidth: true
        }
        Label {
            text: engine.systemController.serverTime.toLocaleDateString()
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
        }
        Button {
            id: dateButton
            visible: !engine.systemController.automaticTime && engine.systemController.timeManagementAvailable
            contentItem: Item {
                ColorIcon {
                    name: "../images/edit.svg"
                    color: Style.foregroundColor
                    anchors.centerIn: parent
                    height: parent.height
                    width: height
                }
            }

            onClicked: {
                var popup = datePickerComponent.createObject(root, {dateTime: engine.systemController.serverTime})
                popup.accepted.connect(function() {
                    print("setting new date", popup.dateTime)
                    engine.systemController.serverTime = popup.dateTime
                })
                popup.open();

            }
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        spacing: app.margins
        Layout.preferredHeight: timeButton.implicitHeight
        visible: engine.jsonRpcClient.ensureServerVersion("4.1")
        Label {
            text: qsTr("Time")
            Layout.fillWidth: true
        }
        Label {
            text: engine.systemController.serverTime.toLocaleTimeString(Locale.ShortTimeString)
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
        }
        Button {
            id: timeButton
            visible: !engine.systemController.automaticTime && engine.systemController.timeManagementAvailable
            contentItem: Item {
                ColorIcon {
                    name: "../images/edit.svg"
                    color: Style.foregroundColor
                    anchors.centerIn: parent
                    height: parent.height
                    width: height
                }
            }

            onClicked: {
                var popup = timePickerComponent.createObject(root, {hour: engine.systemController.serverTime.getHours(), minute: engine.systemController.serverTime.getMinutes()})
                popup.accepted.connect(function() {
                    var date = new Date(engine.systemController.serverTime)
                    date.setHours(popup.hour);
                    date.setMinutes(popup.minute)
                    engine.systemController.serverTime = date;
                })
                popup.open();

            }
        }
    }


    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        spacing: app.margins
        visible: engine.jsonRpcClient.ensureServerVersion("4.1")
        Label {
            Layout.fillWidth: true
            text: qsTr("Time zone")
        }
        ComboBox {
            Layout.minimumWidth: 200
            model: engine.systemController.timeZones
            currentIndex: model.indexOf(engine.systemController.serverTimeZone)
            onActivated: {
                engine.systemController.serverTimeZone = currentText;
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("System")
        visible: engine.systemController.powerManagementAvailable
    }

    Button {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("Restart %1").arg(Configuration.systemName)
        visible: engine.systemController.powerManagementAvailable && engine.jsonRpcClient.ensureServerVersion("5.1")
        onClicked: {
            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
            var text = qsTr("Are you sure you want to restart %1 now?").arg(Configuration.systemName)
            var popup = dialog.createObject(app,
                                            {
                                                headerIcon: "../images/dialog-warning-symbolic.svg",
                                                title: qsTr("Restart %1").arg(Configuration.systemName),
                                                text: text,
                                                standardButtons: Dialog.Ok | Dialog.Cancel
                                            });
            popup.open();
            popup.accepted.connect(function() {
                d.pendingCommand = engine.systemController.restart()
            })
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("Reboot %1 system").arg(Configuration.systemName)
        visible: engine.systemController.powerManagementAvailable
        onClicked: {
            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
            var text = qsTr("Are you sure you want to reboot your %1 sytem now?").arg(Configuration.systemName)
            var popup = dialog.createObject(app,
                                            {
                                                headerIcon: "../images/dialog-warning-symbolic.svg",
                                                title: qsTr("Reboot %1 system").arg(Configuration.systemName),
                                                text: text,
                                                standardButtons: Dialog.Ok | Dialog.Cancel
                                            });
            popup.open();
            popup.accepted.connect(function() {
                d.pendingCommand = engine.systemController.reboot()
            })
        }
    }
    Button {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("Shut down %1 system").arg(Configuration.systemName)
        visible: engine.systemController.powerManagementAvailable
        onClicked: {
            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
            var text = qsTr("Are you sure you want to shut down your %1 sytem now?").arg(Configuration.systemName)
            var popup = dialog.createObject(app,
                                            {
                                                headerIcon: "../images/dialog-warning-symbolic.svg",
                                                title: qsTr("Shut down %1 system").arg(Configuration.systemName),
                                                text: text,
                                                standardButtons: Dialog.Ok | Dialog.Cancel
                                            });
            popup.open();
            popup.accepted.connect(function() {
                d.pendingCommand = engine.systemController.shutdown()
            })
        }
    }


    Component {
        id: timePickerComponent
        Dialog {
            id: timePicker
            property int maxSize: Math.min(parent.width, parent.height)
            property int size: Math.min(maxSize, 500)
            property alias hour: p.hour
            property alias minute: p.minute
            width: size - 80
            height: size
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            TimePicker {
                id: p
                width: parent.width
                height: parent.height
            }
            standardButtons: Dialog.Ok | Dialog.Cancel
        }
    }

    Component {
        id: datePickerComponent
        Dialog {
            id: datePicker
            property int maxSize: Math.min(parent.width, parent.height)
            property int size: Math.min(maxSize, 500)
            property alias dateTime: p.date
            width: size - 80
            height: size
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            DatePicker {
                id: p
                width: parent.width
                height: parent.height
                date: datePicker.dateTime
            }
            standardButtons: Dialog.Ok | Dialog.Cancel
        }
    }
}
