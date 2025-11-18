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

import QtQuick 2.4
import QtGraphicalEffects 1.0
import Nymea 1.0

Item {
    id: icon
    width: size
    height: size
    implicitHeight: image.implicitHeight
    implicitWidth: image.implicitWidth

    property alias name: icon.source
    property string source
    property alias color: colorizedImage.outColor
    property int margins: 0
    property int size: Style.iconSize

    property alias status: image.status

    Image {
        id: image
        anchors.fill: parent
        anchors.margins: parent ? parent.margins : 0
        source: width > 0 && height > 0 && icon.source ?
                    icon.source.endsWith(".svg") ? icon.source
                                               : "qrc:/icons/" + icon.source + ".svg"
                                                 : ""
        sourceSize {
            width: width
            height: height
        }
        cache: true
    }

    ShaderEffect {
        id: colorizedImage
        objectName: "shader"

        anchors.fill: parent

        // Whether or not a color has been set.
        visible: image.status == Image.Ready && outColor != inColor

        property Image source: image
        property color outColor: Style.iconColor
        // Colorize only pixels of this color, leave the rest untouched.
        // This needs to match the basic color of the icon set
        property color inColor: "#808080"
        property real threshold: 0.1

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform highp vec4 outColor;
            uniform highp vec4 inColor;
            uniform lowp float threshold;
            uniform lowp float qt_Opacity;
            void main() {
                lowp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                gl_FragColor = mix(vec4(outColor.rgb, 1.0) * sourceColor.a, sourceColor, step(threshold, distance(sourceColor.rgb / sourceColor.a, inColor.rgb))) * qt_Opacity;
            }"
    }
}
