import QtQuick 2.9
import Nymea 1.0

ColorIcon {
    id: root

    property Thing thing: null

    readonly property State updateStatusState: thing.stateByName("updateStatus")
    readonly property bool updateAvailable: updateStatusState && updateStatusState.value === "available"
    readonly property bool updateRunning: updateStatusState && updateStatusState.value === "updating"

    name: "../images/system-update.svg"
    color: Style.accentColor

    RotationAnimation on rotation {
        from: 0; to: 360
        duration: 2000
        running: root.updateRunning
        loops: Animation.Infinite
    }
}
