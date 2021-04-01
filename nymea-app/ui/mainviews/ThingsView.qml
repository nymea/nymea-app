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
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root

    InterfacesSortModel {
        id: mainModel
        interfacesModel: InterfacesModel {
            engine: _engine
            things: ThingsProxy {
                engine: _engine
            }
            shownInterfaces: app.supportedInterfaces
            showUncategorized: true
        }
    }

    GridView {
        id: interfacesGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2
        model: mainModel

        readonly property int minTileWidth: 172
        readonly property int tilesPerRow: root.width / minTileWidth

        cellWidth: width / tilesPerRow
        cellHeight: cellWidth
        delegate: InterfaceTile {
            width: interfacesGridView.cellWidth
            height: interfacesGridView.cellHeight
            iface: Interfaces.findByName(model.name)
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: engine.thingManager.things.count === 0 && !engine.thingManager.fetchingData
        title: qsTr("Welcome to %1!").arg(Configuration.systemName)
        // Have that split in 2 because we need those strings separated in EditDevicesPage too and don't want translators to do them twice
        text: qsTr("There are no things set up yet.") + "\n" + qsTr("In order for your %1 system to be useful, go ahead and add some things.").arg(Configuration.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
