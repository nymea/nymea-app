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


import QtQuick 2.4
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

        fragmentShader: "/ui/shaders/coloricon.frag.qsb"
    }
}
