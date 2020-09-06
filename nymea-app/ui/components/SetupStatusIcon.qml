import QtQuick 2.9
import Nymea 1.0

ColorIcon {
    id: root

    property Thing thing: null

    readonly property int setupStatus: thing.setupStatus
    readonly property bool setupInProgress: setupStatus == Thing.ThingSetupStatusInProgress
    readonly property bool setupFailed: setupStatus == Thing.ThingSetupStatusFailed

    name: setupFailed ? "../images/dialog-warning-symbolic.svg"
                      : setupInProgress ?  "../images/settings.svg" : "../images/tick.svg"
    color: setupFailed ? "red" : keyColor

    RotationAnimation on rotation {
        from: 0; to: 360
        duration: 2000
        running: root.setupInProgress
        loops: Animation.Infinite
    }
}
