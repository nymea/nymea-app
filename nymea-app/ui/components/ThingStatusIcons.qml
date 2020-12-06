import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

RowLayout {
    id: root
    Layout.fillWidth: false
    spacing: app.margins / 2

    property Thing thing: null

    property color color: Style.iconColor

    signal updateIconClicked();
    signal batteryIconClicked();
    signal connectionIconClicked();
    signal setupIconClicked();

    UpdateStatusIcon {
        id: updateStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: setupStatusIcon.setupStatus == Thing.ThingSetupStatusComplete && connectionStatusIcon.isConnected && (updateAvailable || updateRunning)
        Binding { target: updateStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                var dialogComponent = Qt.createComponent("MeaDialog.qml")
                var currentVersionState = root.thing.stateByName("currentVersion")
                var availableVersionState = root.thing.stateByName("availableVersion")
                var text = qsTr("An update for %1 is available. Do you want to start the update now?").arg(root.thing.name)
                if (currentVersionState) {
                    text += "\n\n" + qsTr("Current version: %1").arg(currentVersionState.value)
                }
                if (availableVersionState) {
                    text += "\n\n" + qsTr("Available version: %1").arg(availableVersionState.value)
                }

                var dialog = dialogComponent.createObject(app,
                                                          {
                                                              headerIcon: "../images/system-update.svg",
                                                              title: qsTr("Update"),
                                                              text: text,
                                                              standardButtons: Dialog.Ok | Dialog.Cancel
                                                          })
                dialog.accepted.connect(function() {
                    print("starting update")
                    engine.thingManager.executeAction(root.thing.id, root.thing.thingClass.actionTypes.findByName("performUpdate").id)
                })
                dialog.open();
                root.updateIconClicked()
            }
        }
    }
    BatteryStatusIcon {
        id: batteryStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: root.thing.setupStatus == Thing.ThingSetupStatusComplete && (hasBatteryLevel || isCritical)
        Binding { target: batteryStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                root.batteryIconClicked()
                var levelStateType = root.thing.thingClass.stateTypes.findByName("batteryLevel");
                var criticalStateType = root.thing.thingClass.stateTypes.findByName("batteryCritical");
                var stateTypes = []
                if (levelStateType) {
                    stateTypes.push(levelStateType.id)
                }
                if (criticalStateType) {
                    stateTypes.push(criticalStateType.id)
                }
                pageStack.push("../devicepages/DeviceLogPage.qml",
                               {
                                   thing: root.thing,
                                   filterTypeIds: stateTypes
                               });
            }
        }
    }
    ConnectionStatusIcon {
        id: connectionStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: root.thing.setupStatus == Thing.ThingSetupStatusComplete && (hasSignalStrength || !isConnected)
        Binding { target: connectionStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                root.connectionIconClicked()
                var signalStateType = root.thing.thingClass.stateTypes.findByName("signalStrength")
                var connectedStateType = root.thing.thingClass.stateTypes.findByName("connected")
                var stateTypes = []
                if (signalStateType) {
                    stateTypes.push(signalStateType.id)
                }
                if (connectedStateType) {
                    stateTypes.push(connectedStateType.id)
                }
                pageStack.push("../devicepages/DeviceLogPage.qml",
                               {
                                   thing: root.thing,
                                   filterTypeIds: stateTypes
                               });
            }
        }
    }
    SetupStatusIcon {
        id: setupStatusIcon
        Layout.preferredHeight: app.smallIconSize
        Layout.preferredWidth: height
        thing: root.thing
        visible: setupFailed || setupInProgress
        Binding { target: setupStatusIcon; property: "color"; value: root.color; when: root.color !== Style.iconColor }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -app.margins / 4
            onClicked: {
                root.setupIconClicked()
                pageStack.push("../thingconfiguration/ConfigureThingPage.qml", { thing: root.thing });
            }
        }
    }
}
