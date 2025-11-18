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

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root

    title: swipeView.currentItem ? swipeView.currentItem.thing.name : ""

    ThingsProxy {
        id: mediaDevices
        engine: _engine
        shownInterfaces: ["mediaplayer"]
    }

    SwipeView {
        id: swipeView
        anchors { left: parent.left; top: parent.top; right: parent.right; bottom: parent.bottom; bottomMargin: root.bottomMargin }
        currentIndex: pageIndicator.currentIndex

        Repeater {
            model: mediaDevices
            delegate: MediaPlayer {
                thing: mediaDevices.get(index)
            }
        }
    }
    PageIndicator {
        id: pageIndicator
        count: swipeView.count
        visible: count > 1
        currentIndex: swipeView.currentIndex
        interactive: true
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.bottomMargin
        anchors.horizontalCenter: parent.horizontalCenter
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.thingManager.fetchingData && mediaDevices.count == 0
        title: qsTr("There are no media players set up.")
        text: qsTr("Connect your media players in order to control them from here.")
        imageSource: "qrc:/icons/media.svg"
        buttonText: qsTr("Add things")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
    }
}
