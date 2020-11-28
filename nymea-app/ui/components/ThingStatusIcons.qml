import QtQuick 2.9
import QtQuick.Layouts 1.1
import Nymea 1.0

RowLayout {
    id: root
    Layout.fillWidth: false

    property Thing thing: null

    property color color: keyColor
    readonly property color keyColor: updateStatusIcon.keyColor

    UpdateStatusIcon {
        id: updateStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: updateAvailable || updateRunning
        Binding { target: updateStatusIcon; property: "color"; value: root.color; when: root.color !== root.keyColor }
    }
    BatteryStatusIcon {
        id: batteryStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: root.thing.setupStatus == Thing.ThingSetupStatusComplete && (hasBatteryLevel || isCritical)
        Binding { target: batteryStatusIcon; property: "color"; value: root.color; when: root.color !== root.keyColor }
    }
    ConnectionStatusIcon {
        id: connectionStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: root.thing.setupStatus == Thing.ThingSetupStatusComplete && (hasSignalStrength || !isConnected)
        Binding { target: connectionStatusIcon; property: "color"; value: root.color; when: root.color !== root.keyColor }
    }
    SetupStatusIcon {
        id: setupStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: setupFailed || setupInProgress
        Binding { target: setupStatusIcon; property: "color"; value: root.color; when: root.color !== root.keyColor }
    }
}
