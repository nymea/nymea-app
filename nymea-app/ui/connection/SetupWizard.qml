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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("First setup")
        backButtonVisible: true
        onBackPressed: root.backPressed()
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("Welcome to %1!").arg(Configuration.systemName)
        text: qsTr("This %1 system has not been set up yet. This wizard will guide you through a few simple steps to set it up.").arg(Configuration.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        buttonText: qsTr("Next")
        onButtonClicked: {
            var page = pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
            page.backPressed.connect(function() {pageStack.pop();})
        }
    }
}
