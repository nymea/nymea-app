import QtQuick 2.9
import Nymea 1.0

ColorIcon {
    id: root

    property Thing thing: null

    readonly property bool isConnected: connectedState === null || connectedState.value === true
    readonly property bool isWireless: thing.thingClass.interfaces.indexOf("wirelessconnectable") >= 0
    readonly property bool hasSignalStrength: signalStrengthState !== null

    readonly property State connectedState: thing.stateByName("connected")
    readonly property State signalStrengthState: thing.stateByName("signalStrength")

    name: {
        if (!isWireless) {
            return connectedState && connectedState.value === true ? "../images/network-wired.svg" : "../images/network-wired-offline.svg"
        }
        if (connectedState && connectedState.value === false) {
            return "../images/network-wifi-offline.svg"
        }

        if (signalStrengthState && signalStrengthState.value === -1) {
            return "../images/network-wifi.svg"
        }

        return "../images/nm-signal-" + NymeaUtils.pad(Math.round(signalStrengthState.value * 4 / 100) * 25, 2) + ".svg"
    }

    color: connectedState && connectedState.value === false
           ? "red"
           : signalStrengthState && signalStrengthState.value < 20
             ? "orange" : keyColor
}
