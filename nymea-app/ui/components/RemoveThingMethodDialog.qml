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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

Dialog {
    id: root
    width: Math.min(parent.width * .8, contentLabel.implicitWidth + app.margins * 2)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true

    property Thing thing: null
    property var rulesList: null

    ColumnLayout {
        width: parent.width
        Label {
            id: contentLabel
            text: qsTr("This thing is currently used in one or more rules:")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        ThinDivider {}
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.iconSize * Math.min(count, 5)
            model: rulesList
            interactive: contentHeight > height
            delegate: Label {
                height: Style.iconSize
                width: parent.width
                elide: Text.ElideRight
                text: engine.ruleManager.rules.getRule(modelData).name
                verticalAlignment: Text.AlignVCenter
            }
        }
        ThinDivider {}

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Remove all those rules")
            progressive: false
            onClicked: {
                engine.thingManager.removeThing(root.thing.id, ThingManager.RemovePolicyCascade)
                root.close()
                root.destroy();
            }
        }

        NymeaSwipeDelegate {
            text: qsTr("Update rules, removing this thing")
            Layout.fillWidth: true
            progressive: false
            onClicked: {
                engine.thingManager.removeThing(root.thing.id, ThingManager.RemovePolicyUpdate)
                root.close()
                root.destroy();
            }
        }

        NymeaSwipeDelegate {
            text: qsTr("Don't remove this thing")
            Layout.fillWidth: true
            progressive: false
            onClicked: {
                root.close()
                root.destroy();
            }
        }
    }
}
