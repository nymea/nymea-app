/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by  Florian Boucault <florian.boucault@canonical.com>
 */

import QtQuick 2.4

Item {
    id: segImg
    property alias textureSource: segmentRenderer.source
    property alias boxesSource: segmentBoundingBoxes.source

    implicitWidth: segmentRenderer.implicitWidth
    implicitHeight: segmentRenderer.implicitHeight

    // Ready to enroll.
    signal ready()

    function enrollMasks(masks) {
        if (masks && masks.length) {
            var segments = [];
            masks.forEach(function (mask, i) {
                var hitBox = [mask.x, mask.y, mask.width, mask.height];
                segments = segments.concat(segmentBoundingBoxes.computeIntersections(hitBox));
            });
            segmentRenderer.animate(segments);
        }
    }

    SegmentRenderer {
        id: segmentRenderer
        segmentsCount: segmentBoundingBoxes.count
    }

    SegmentBoundingBoxes {
        id: segmentBoundingBoxes
        onReady: segImg.ready()
    }
}
