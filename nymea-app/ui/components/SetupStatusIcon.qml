import QtQuick
import Nymea

ColorIcon {
    id: root

    property Thing thing: null

    readonly property int setupStatus: thing.setupStatus
    readonly property bool setupInProgress: setupStatus == Thing.ThingSetupStatusInProgress
    readonly property bool setupFailed: setupStatus == Thing.ThingSetupStatusFailed

    name: setupFailed ? "qrc:/icons/dialog-warning-symbolic.svg"
                      : setupInProgress ?  "qrc:/icons/settings.svg" : "qrc:/icons/tick.svg"
    color: setupFailed ? "red" : Style.iconColor

    RotationAnimation on rotation {
        from: 0; to: 360
        duration: 2000
        running: root.setupInProgress
        loops: Animation.Infinite
    }
}
