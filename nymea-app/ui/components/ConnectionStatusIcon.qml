import QtQuick
import Nymea
import NymeaApp.Utils

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
            return connectedState && connectedState.value === true ? "qrc:/icons/connections/network-wired.svg" : "qrc:/icons/connections/network-wired-offline.svg"
        }
        if (connectedState && connectedState.value === false) {
            return "qrc:/icons/connections/nm-signal-00.svg"
        }

        if (!signalStrengthState) {
            return "qrc:/icons/connections/nm-signal-100.svg"
        }

        return "qrc:/icons/connections/nm-signal-" + NymeaUtils.pad(Math.round(signalStrengthState.value * 4 / 100) * 25, 2) + ".svg"
    }

    color: connectedState && connectedState.value === false
           ? Style.red
           : signalStrengthState && signalStrengthState.value < 20
             ? Style.orange : Style.iconColor
}
