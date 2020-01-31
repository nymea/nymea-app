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

SegmentedImage {
    id: segmentedImage

    property var masks: []

    property bool debug: false

    // http://stackoverflow.com/a/1830844/538866
    function isNumeric (n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }

    function getMasksToEnroll () {
        var outMasks = [];
        if (masks && masks.length) {
            masks.forEach(function (mask, i) {
                // Format is "<source>/[x1,y1,w1,h1],…,[xn,yn,wn,hn]"
                // If any value is non-numeric, we drop the mask.
                if (!isNumeric(mask.x) || !isNumeric(mask.y) || !isNumeric(mask.width)
                    || !isNumeric(mask.height))
                    return;

                // Translate the box so as to mirror the mask
                mask.x = (1 - (mask.x + mask.width));

                outMasks.push(mask);
            });
        }
        return outMasks;
    }

    onMasksChanged: segmentedImage.enrollMasks(getMasksToEnroll())

    textureSource: "../images/fingerprint/fingerprint_segmented.png"
    boxesSource: "../images/fingerprint/fingerprint_boxes.json"

    Repeater {
        model: segmentedImage.masks

        Rectangle {
            visible: segmentedImage.debug
            color: "red"
            opacity: 0.25
            x: modelData.x * segmentedImage.implicitWidth
            y: modelData.y * segmentedImage.implicitHeight
            width: modelData.width * segmentedImage.implicitWidth
            height: modelData.height * segmentedImage.implicitHeight

            Component.onCompleted: console.log('Scanner mask (x, y, w, h):', x, y, width, height)
        }
    }
}
