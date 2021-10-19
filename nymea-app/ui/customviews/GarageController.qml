import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import "../components"
import Nymea 1.0

Item {
    id: root
    property Thing thing: null

    readonly property bool isImpulseBased: thing.thingClass.interfaces.indexOf("impulsegaragedoor") >= 0
    readonly property bool isStateful: thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
    readonly property bool isExtended: thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0

    // Stateful garagedoor
    readonly property StateType stateStateType: thing.thingClass.stateTypes.findByName("state")
    readonly property State stateState: stateStateType ? thing.states.getState(stateStateType.id) : null

    // Extended stateful garagedoor
    readonly property StateType percentageStateType: thing.thingClass.stateTypes.findByName("percentage")
    readonly property State percentageState: percentageStateType ? thing.states.getState(percentageStateType.id) : null


    // Backward compatiblity with old garagegate interface
    readonly property StateType intermediatePositionStateType: thing.thingClass.stateTypes.findByName("intermediatePosition")
    readonly property var intermediatePositionState: intermediatePositionStateType ? thing.states.getState(intermediatePositionStateType.id) : null

    Component.onCompleted: {
        print("Creating garage page. Impulse based:", isImpulseBased, "stateful:", isStateful, "extended:", isExtended, "legacy:", intermediatePositionState !== null)
    }

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1
        columnSpacing: 0
        rowSpacing: 0

        Item {
            id: shutterImage
            Layout.preferredWidth: app.landscape ?
                                       Math.min(parent.width - shutterControlsContainer.minimumWidth, parent.height)
                                     : Math.min(Math.min(parent.width, 500), parent.height - shutterControlsContainer.minimumHeight)
            Layout.preferredHeight: width

            Rectangle {
                id: background
                anchors.centerIn: parent
                width: Math.min(500, Math.min(parent.width, parent.height) - Style.hugeMargins * 2)
                height: width
                radius: width / 2
                color: Style.tileBackgroundColor
            }

            Item {
                id: door
                anchors.fill: background
                Canvas {
                    id: canvas
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height + Style.margins
                    anchors.verticalCenterOffset: {
                        if (root.percentageState) {
                            return -height * (1 - (root.percentageState.value / 100))
                        }
                        if (root.stateState && root.stateState.value === "closed") {
                            return 0
                        }
                        if (root.stateState && root.stateState.value === "open") {
                            return -height
                        }
                        return -height / 2
                    }
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        ctx.fillStyle = Style.tileForegroundColor
                        var segments = 10;
                        var segmentHeight = height / segments
                        var barHeight = segmentHeight - Style.smallMargins
                        for (var i = 0; i < segments; i++) {
                            ctx.fillRect(0, i * segmentHeight, width, barHeight)
                        }
                    }
                }
            }


            OpacityMask {
                anchors.fill: background
                source: ShaderEffectSource {
                    sourceItem: door
                    hideSource: true
                }
                maskSource: background
            }
        }

        Item {
            id: shutterControlsContainer
            Layout.fillWidth: true
            Layout.minimumWidth: minimumWidth
            Layout.preferredHeight: Style.bigIconSize * 4
            property int minimumWidth: Style.iconSize * 10
            property int minimumHeight: Style.iconSize * 2.5

            ProgressButton {
                anchors.centerIn: parent
                mode: "highlight"
                visible: root.isImpulseBased
                longpressEnabled: false
                size: Style.bigIconSize
                imageSource: "../images/closable-move.svg"
                busy: busyTimer.running
                onClicked: {
                    var actionTypeId = root.thing.thingClass.actionTypes.findByName("triggerImpulse").id
                    print("Triggering impulse", actionTypeId)
                    engine.thingManager.executeAction(root.thing.id, actionTypeId)
                    busyTimer.start();
                }
                Timer {
                    id: busyTimer
                    interval: 5000
                }
            }

            ShutterControls {
                id: shutterControls
                thing: root.thing
                width: parent.width
                anchors.centerIn: parent
                backgroundEnabled: true
                size: Style.bigIconSize
                visible: !root.isImpulseBased
            }
        }
    }
}
