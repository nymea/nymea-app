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
import QtQuick.Templates 2.2
import QtQuick.Controls.Material 2.2

ApplicationWindow {
    // The app style
    Material.theme: Material.Dark

    // Main background color
    Material.background: "#010a29"

    font.pixelSize: 14
    font.weight: Font.Normal
    font.capitalization: Font.MixedCase
    font.family: "Ubuntu"

    // The core system name.
    property string systemName: "moon"

    // The app name
    property string appName: "moon:app"

    // The header background color
    property color primaryColor: "#010a29"

    // Header font color
    property color headerForegroundColor: "white"

    // The font color
    property color foregroundColor: "#ffffff"

    // The color of selected/highlighted things
    property color accentColor: "#8cc1b6"

    // colors for interfaces, e.g. icons
    property var interfaceColors: {
        "temperaturesensor": "#FF0000",
        "humiditysensor": "#00BFFF",
        "moisturesensor":"#0000FF",
        "lightsensor": "#FFA500",
        "conductivitysensor": "#008000",
        "pressuresensor": "#808080"
    }
}
