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

import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "../components"
import "../customviews"
import Nymea 1.0

MainViewBase {
    id: root
    title: swipeView.currentItem ? swipeView.currentItem.thing.name : ""

    readonly property bool landscape: width > height

    DevicesProxy {
        id: garagesFilterModel
        engine: _engine
        shownInterfaces: ["garagedoor", "garagegate"]
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.bottomMargin: pageIndicator.visible ? pageIndicator.height : 0

        Repeater {
            model: garagesFilterModel

            delegate: GarageController {
                height: swipeView.height
                width: swipeView.width
                thing: garagesFilterModel.get(index)
            }

        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("There are no garage doors set up yet.")
        text: qsTr("Connect your garage doors in order to control them from here.")
        imageSource: "qrc:/ui/images/garage/garage-100.svg"
        buttonText: qsTr("Add things")
        visible: garagesFilterModel.count === 0 && !engine.thingManager.fetchingData
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }

    PageIndicator {
        id: pageIndicator
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        count: garagesFilterModel.count
        currentIndex: swipeView.currentIndex
        visible: count > 1
    }
}
