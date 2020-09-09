import QtQuick 2.9
import Nymea 1.0

ColorIcon {
    id: root

    property Thing thing: null

    readonly property bool hasBattery: batteryCriticalState !== null
    readonly property bool hasBatteryLevel: batteryLevelState !== null
    readonly property bool isCritical: batteryCriticalState && batteryCriticalState.value === true
    readonly property int batteryLevel: batteryLevelState ? batteryLevelState.value : 0

    readonly property State batteryCriticalState: thing.stateByName("batteryCritical")
    readonly property State batteryLevelState: thing.stateByName("batteryLevel")

    name: {
        if (!hasBatteryLevel) {
            if (isCritical) {
                return "../images/battery/battery-020.svg"
            }
            return "../images/battery/battery-100.svg"
        }

        var rounded = Math.round(batteryLevel / 10) * 10
        return "../images/battery/battery-" + NymeaUtils.pad(rounded, 3)
    }
}
