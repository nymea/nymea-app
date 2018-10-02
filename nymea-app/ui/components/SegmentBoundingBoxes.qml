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

QtObject {
    id: segmentBoundingBoxes

    property string source
    onSourceChanged: parseBoundingBoxes(source)

    property var boundingBoxes: []
    property real width
    property real height
    property int count: boundingBoxes.length

    // The API cannot be used reliably before this signal has been emitted.
    signal ready()

    function parseBoundingBoxes(source) {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                var b = [];
                var json = JSON.parse(xhr.responseText);
                boundingBoxes = json["boxes"];
                width = json["width"];
                height = json["height"];
                ready();
            }
        }
        xhr.send();
    }

    function intersects(box1, box2) {
        // TODO: optimize
        var x11 = box1[0];
        var y11 = box1[1];
        var x12 = box1[0] + box1[2];
        var y12 = box1[1] + box1[3];
        var x21 = box2[0];
        var y21 = box2[1];
        var x22 = box2[0] + box2[2];
        var y22 = box2[1] + box2[3];
        var x_overlap = Math.max(0, Math.min(x12,x22) - Math.max(x11,x21));
        var y_overlap = Math.max(0, Math.min(y12,y22) - Math.max(y11,y21));
        return (x_overlap / Math.min(box1[2], box2[2]) > 0.25
             && y_overlap / Math.min(box1[3], box2[3]) > 0.25);
    }

    function computeIntersections(hitBox) {
        var absoluteHitBox = [hitBox[0] * width, hitBox[1] * height,
                              hitBox[2] * width, hitBox[3] * height];

        var intersections = [];
        for (var i in boundingBoxes) {
            var boundingBox = boundingBoxes[i];
            if (intersects(absoluteHitBox, boundingBox)) {
                intersections.push(i);
            }
        }

        return intersections;
    }
}
