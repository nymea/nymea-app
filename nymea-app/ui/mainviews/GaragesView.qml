// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
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

    ThingsProxy {
        id: garagesFilterModel
        engine: _engine
        shownInterfaces: ["garagedoor", "garagegate"]
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.bottomMargin: root.bottomMargin + (pageIndicator.visible ? pageIndicator.height : 0)

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
        imageSource: "qrc:/icons/garage/garage-100.svg"
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
