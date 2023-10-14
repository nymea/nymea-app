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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property Thing thing: null
    property StateType stateType: null

    readonly property bool isLogged: thing.loggedStateTypeIds.indexOf(stateType.id) >= 0

    readonly property bool canShowGraph: {
        switch (root.stateType.type.toLowerCase()) {
        case "int":
        case "uint":
        case "double":
        case "bool":
            return true;
        }
        print("not showing graph for", root.stateType.type)
        return false;
    }

    header: NymeaHeader {
        text: qsTr("History for %1").arg(root.stateType.displayName)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "delete"
            visible: root.isLogged
            onClicked: {
                var popup = deleteLogsComponent.createObject(root)
                popup.open()
            }

            Component {
                id: deleteLogsComponent
                NymeaDialog {
                    title: qsTr("Remove logs?")
                    text: qsTr("Do you want to remove the log for this state and disable logging?")
                    standardButtons: Dialog.Yes | Dialog.No
                    onAccepted: engine.thingManager.setStateLogging(root.thing.id, root.stateType.id, false)
                }
            }
        }
    }

    NewLogsModel {
        id: logsModel
        engine: _engine
        source: "state-" + root.thing.id + "-" + root.stateType.name
        sortOrder: Qt.DescendingOrder
        live: true
    }

    Component.onCompleted: {
        print("loaded statelogpage for", root.stateType)
    }

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1
        visible: root.isLogged

        Loader {
            Layout.fillWidth: true
            active: root.canShowGraph

            sourceComponent: Component {
                StateChart {
                    thing: root.thing
                    stateType: root.stateType
                }
            }
        }


        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: 400
            model: logsModel
            clip: true
            ScrollBar.vertical: ScrollBar {}

            delegate: NymeaItemDelegate {
                width: listView.width
                property NewLogEntry entry: logsModel.get(index)
                text: Types.toUiValue(entry.values[root.stateType.name], root.stateType.unit) + " " + Types.toUiUnit(root.stateType.unit)
                subText: entry.timestamp.toLocaleString(Qt.locale())
                progressive: false
            }
        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("Logging not enabled")
        text: qsTr("This state is not being logged.")
        imageSource: "../images/logs.svg"
        buttonText: qsTr("Enable logging")
        visible: !root.isLogged
        onButtonClicked: {
            engine.thingManager.setStateLogging(root.thing.id, root.stateType.id, true)
        }
    }
}

