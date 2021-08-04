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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

SettingsPageBase {
    id: root
    property Thing thing: null
    readonly property ThingClass thingClass: thing ? thing.thingClass : null

    header: NymeaHeader {
        text: root.thingClass.displayName
        onBackPressed: pageStack.pop()
    }

    SettingsPageSectionHeader {
        text: qsTr("Type")
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: root.thingClass.displayName
        subText: root.thingClass.id.toString().replace(/[{}]/g, "")
        progressive: false
        onClicked: {
            PlatformHelper.toClipBoard(subText);
            ToolTip.show(qsTr("ID copied to clipboard"), 500);
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Interfaces")
    }

    Repeater {
        model: root.thingClass.interfaces
        delegate: Label {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            text: modelData
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Parameters")
        visible: root.thingClass.paramTypes.count > 0
    }

    Repeater {
        model: root.thingClass.paramTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.paramTypes.get(index).displayName
            subText: root.thingClass.paramTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Settings")
        visible: root.thingClass.settingsTypes.count > 0
    }

    Repeater {
        model: root.thingClass.settingsTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.settingsTypes.get(index).displayName
            subText: root.thingClass.settingsTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Events")
        visible: root.thingClass.eventTypes.count > 0
    }

    Repeater {
        model: root.thingClass.eventTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.eventTypes.get(index).displayName
            subText: root.thingClass.eventTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("States")
        visible: root.thingClass.stateTypes.count > 0
    }

    Repeater {
        model: root.thingClass.stateTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.stateTypes.get(index).displayName
            subText: root.thingClass.stateTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Actions")
        visible: root.thingClass.actionTypes.count > 0
    }

    Repeater {
        model: root.thingClass.actionTypes
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: root.thingClass.actionTypes.get(index).displayName
            subText: root.thingClass.actionTypes.get(index).id.toString().replace(/[{}]/g, "")
            progressive: false
            onClicked: {
                PlatformHelper.toClipBoard(subText);
                ToolTip.show(qsTr("ID copied to clipboard"), 500);
            }
        }
    }
}
