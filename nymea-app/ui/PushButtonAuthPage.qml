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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("Welcome to %1!").arg(app.systemName)
        backButtonVisible: true
        onBackPressed: {
            root.backPressed();
        }
    }

    Component.onCompleted: {
        engine.jsonRpcClient.requestPushButtonAuth("nymea-app (" + PlatformHelper.deviceModel + ")");
    }

    Connections {
        target: engine.jsonRpcClient
        onPushButtonAuthFailed: {
            var popup = errorDialog.createObject(root)
            popup.text = qsTr("Sorry, something went wrong during the setup. Try again please.")
            popup.open();
            popup.accepted.connect(function() {root.backPressed()})
        }
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        anchors.margins: app.margins
        spacing: app.margins * 2

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: Style.accentColor
            text: qsTr("Authentication required")
            wrapMode: Text.WordWrap
            font.pixelSize: app.largeFont
        }

        Image {
            Layout.preferredWidth: app.iconSize * 6
            Layout.preferredHeight: width
            source: "images/nymea-box-setup.svg"
            Layout.alignment: Qt.AlignHCenter
            sourceSize.width: width
            sourceSize.height: height
        }


        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Please press the button on your %1 box to authenticate this device.").arg(app.systemName)
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {

        }
    }
}
