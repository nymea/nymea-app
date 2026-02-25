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

pragma Singleton
import QtQuick
import "../../ui"

StyleBase {
    // This is the default style. No overrides

    backgroundColor: "#ffffff"
    foregroundColor: darkGray
    accentColor: orange
    tileBackgroundColor: lightestGray


    property color lightestGray: "#F4F4F4"

    red: "#EB5E65"
    green: "#49BF84"
    yellow: "#FFCC00"
    white: "#f1f1f1"
    gray: "#B4B1AA"
    darkGray: "#4E4D42"
    orange: "#F4A506"
    blue: "#3C99D5"
    darkBlue: "#237CAE"
    lime: "#99EA53"
    purple: "#F57F7C"

}
