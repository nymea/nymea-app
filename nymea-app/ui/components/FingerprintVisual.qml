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
