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
    title: qsTr("Look and feel")

    SettingsPageSectionHeader {
        text: qsTr("Appearance")
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        visible: !styleController.locked
        Label {
            Layout.fillWidth: true
            text: "Style"
        }
        ComboBox {
            model: styleController.allStyles
            currentIndex: styleController.allStyles.indexOf(styleController.currentStyle)

            onActivated: {
                styleController.currentStyle = model[index]
            }
        }

        Connections {
            target: styleController
            onCurrentStyleChanged: {
                var popup = styleChangedDialog.createObject(root)
                popup.open()
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        visible: !kioskMode && Qt.platform.os !== "ios"
        Label {
            Layout.fillWidth: true
            text: qsTr("View mode")
        }
        ComboBox {
            model: [qsTr("Windowed"), qsTr("Maximized"), qsTr("Fullscreen"), qsTr("Automatic")]
            currentIndex: {
                switch (settings.viewMode) {
                case ApplicationWindow.Windowed:
                    return 0;
                case ApplicationWindow.Maximized:
                    return 1;
                case ApplicationWindow.FullScreen:
                    return 2;
                case ApplicationWindow.AutomaticVisibility:
                    return 3;
                }
            }

            onActivated: {
                switch (currentIndex) {
                case 0:
                    settings.viewMode = ApplicationWindow.Windowed;
                    break;
                case 1:
                    settings.viewMode = ApplicationWindow.Maximized;
                    break;
                case 2:
                    settings.viewMode = ApplicationWindow.FullScreen;
                    break;
                case 3:
                    settings.viewMode = ApplicationWindow.AutomaticVisibility;
                    break;
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Regional")
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        Label {
            Layout.fillWidth: true
            text: qsTr("Unit system")
        }
        ComboBox {
            id: unitsComboBox
            currentIndex: settings.units === "metric" ? 0 : 1
            model: [ qsTr("Metric"), qsTr("Imperial") ]
            onActivated: {
                settings.units = index == 0 ? "metric" : "imperial";
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Behavior")
    }

    CheckDelegate {
        Layout.fillWidth: true
        text: qsTr("Return to home on idle")
        checked: settings.returnToHome
        onClicked: settings.returnToHome = checked
    }

    CheckDelegate {
        id: screenOffCheck
        Layout.fillWidth: true
        text: qsTr("Turn screen off when idle")
        visible: PlatformHelper.canControlScreen
        checked: PlatformHelper.screenTimeout > 0
        onClicked: PlatformHelper.screenTimeout = (checked ? 15000 : 0)
    }

    ItemDelegate {
        Layout.fillWidth: true
        Layout.preferredHeight: screenOffCheck.height
        visible: PlatformHelper.screenTimeout > 0
        topPadding: 0
        contentItem: RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Screen off timeout")
            }
            SpinBox {
                value: PlatformHelper.screenTimeout / 1000
                onValueModified: {
                    PlatformHelper.screenTimeout = value * 1000
                }
            }
            Label {
                text: qsTr("seconds")
            }
        }
    }

    ItemDelegate {
        Layout.fillWidth: true
        visible: PlatformHelper.canControlScreen
        topPadding: 0
        contentItem: RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Screen brightness")
            }
            Slider {
                Layout.fillWidth: true
                value: PlatformHelper.screenBrightness
                onMoved: PlatformHelper.screenBrightness = value
                from: 0
                to: 100
                stepSize: 1
            }
        }
    }


    Component {
        id: styleChangedDialog
        Dialog {
            width: Math.min(parent.width * .8, contentLabel.implicitWidth)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            title: qsTr("Style changed")

            standardButtons: Dialog.Ok

            ColumnLayout {
                id: content
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Label {
                    id: contentLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr("The application needs to be restarted for style changes to take effect.")
                }
            }
        }
    }
}
