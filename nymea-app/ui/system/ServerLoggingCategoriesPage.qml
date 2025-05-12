/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2024, nymea GmbH
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Server logging categories")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ServerDebugManager {
        id: serverDebugManager
        engine: _engine
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.height
        visible: serverDebugManager.fetchingData

        BusyIndicator {
            anchors.centerIn: parent
            visible: serverDebugManager.fetchingData
            running: visible
        }
    }

    // ColumnLayout {
    //     anchors.fill: parent

    //     ListFilterInput {
    //         id: filterInput
    //         Layout.fillWidth: true
    //     }


    //     ListView {
    //         ScrollBar.vertical: ScrollBar {}

    //         clip: true
    //         section.property: "baseInterface"
    //         section.criteria: ViewSection.FullString
    //         section.delegate: ListSectionHeader {
    //             text: app.interfaceToString(section)
    //         }

    //         SwipeDelegateGroup {}
    //     }

    // }





    RowLayout {
        Layout.margins: Style.margins
        Item {
            Layout.fillWidth: true
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Critical")
            elide: Text.ElideRight
            font: Style.smallFont
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Warning")
            elide: Text.ElideRight
            font: Style.smallFont
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Info")
            elide: Text.ElideRight
            font: Style.smallFont
        }
        Label {
            Layout.preferredWidth: Style.smallDelegateHeight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Debug")
            elide: Text.ElideRight
            font: Style.smallFont
        }
    }

    ThinDivider {}

    Repeater {
        model: ServerLoggingCategoriesProxy {
            loggingCategories: serverDebugManager.categories
            typeFilter: ServerLoggingCategoriesProxy.TypeFilterSystem
        }

        delegate: ItemDelegate {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.smallDelegateHeight
            contentItem: RowLayout {
                height: parent.height
                Label {
                    Layout.fillWidth: true
                    text: model.name
                    elide: Text.ElideRight
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelCritical
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelCritical)
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelWarning
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelWarning)
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelInfo
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelInfo)
                }
                RadioButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Style.smallDelegateHeight
                    checked: model.level === ServerLoggingCategory.LevelDebug
                    onClicked: serverDebugManager.setLoggingLevel(model.name, ServerLoggingCategory.LevelDebug)
                }
            }
        }
    }


}
