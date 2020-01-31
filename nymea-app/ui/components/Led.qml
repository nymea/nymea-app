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

Item {
    id: root
    implicitHeight: app.iconSize * .8
    implicitWidth: height

    // TODO: Convert to enum once we have Qt 5.10
    // on, off, green, orange, red
    property string state: "off"

    Rectangle {
        height: Math.min(parent.height, parent.height)
        width: height
        radius: width / 2
        color: {
            switch (root.state) {
            case "on":
                return app.accentColor
            case "green":
                return "#73c0b3";
            case "off":
                return "lightgray";
            case "orange":
                return "#fedf6f";
            case "red":
                return "#dd7777"
            }
        }
        border.width: 1
        border.color: app.foregroundColor
    }
}
