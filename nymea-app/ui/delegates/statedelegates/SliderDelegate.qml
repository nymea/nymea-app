import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

RowLayout {
    id: root
    width: 150
    signal changed(var value)

    property var value
    property var unit: Types.UnitNone
    property alias from: slider.from
    property alias to: slider.to

    property StateType stateType

    readonly property int decimals: root.stateType.type.toLowerCase() === "int" ? 0 : 1

    Slider {
        id: slider
        Layout.fillWidth: true
        value: root.value
        stepSize: {
            var ret = 1
            for (var i = 0; i < root.decimals; i++) {
                ret /= 10;
            }
            return ret;
        }
        property var lastVibration: new Date()
        property var lastChange: root.value
        onMoved: {
            // Emits moved more often than stepsize, we only want to act when we actually emitted value change
            if (value === lastChange) {
                return;
            }
            lastChange = value;

            if (value === from || value === to) {
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
            } else {
                if (lastVibration.getTime() + 35 < new Date()) {
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                }
                lastVibration = new Date()
            }


            root.changed(value)
        }
    }
    Label {
        text: Types.toUiValue(slider.value, root.unit).toFixed(root.decimals)
    }
}
