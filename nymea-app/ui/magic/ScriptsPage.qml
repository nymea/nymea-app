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

import QtQuick 2.0
import Nymea 1.0
import QtQuick.Controls 2.2
import "../components"

Page {
    header: NymeaHeader {
        text: qsTr("Scripts")
        onBackPressed: pageStack.pop();

        HeaderButton {
            text: qsTr("Add new script")
            imageSource: "../images/add.svg"
            onClicked: {
                pageStack.push("ScriptEditor.qml");
            }
        }
    }

    QtObject {
        id: d
        property int pendingAction: -1
    }

    Connections {
        target: engine.scriptManager
        onRemoveScriptReply: {
            if (id == d.pendingAction) {
                d.pendingAction = -1;
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: engine.scriptManager.scripts
        delegate: NymeaSwipeDelegate {
            width: parent.width
            text: model.name
            iconName: "../images/script.svg"
            canDelete: true
            onClicked: {
                pageStack.push("ScriptEditor.qml", {scriptId: model.id});
            }

            onDeleteClicked: {
                print("removing script", model.id)
                d.pendingAction = engine.scriptManager.removeScript(model.id);
            }
        }

        EmptyViewPlaceholder {
            anchors.centerIn: parent
            title: qsTr("No scripts are installed yet.")
            text: qsTr("Press \"Add script\" to get started.")
            imageSource: "../images/script.svg"
            buttonText: qsTr("Add script")
            visible: engine.scriptManager.scripts.count === 0
            onButtonClicked: {
                pageStack.push("ScriptEditor.qml");
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
        visible: d.pendingAction != -1
    }
}
