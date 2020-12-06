import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
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

        ColorIcon {
            id: shutterImage
            Layout.preferredWidth: app.landscape ?
                                       Math.min(parent.width - shutterControlsContainer.minimumWidth, parent.height) - app.margins
                                     : Math.min(Math.min(parent.width, 500), parent.height - shutterControlsContainer.minimumHeight)
            Layout.preferredHeight: width
            Layout.alignment: Qt.AlignHCenter
            property string currentImage: {
                if (root.isExtended) {
                    return NymeaUtils.pad(Math.round(root.percentageState.value / 10), 2) + "0"
                }
                if (root.intermediatePositionStateType) {
                    return root.stateState.value === "closed" ? "100"
                            : root.intermediatePositionState.value === false ? "000" : "050"
                }
                return "100"
            }
            name: "../images/garage/garage-" + currentImage + ".svg"

            Item {
                id: arrows
                anchors.centerIn: parent
                width: app.iconSize * 2
                height: parent.height * .6
                clip: true
                visible: root.stateStateType && (root.stateState.value === "opening" || root.stateState.value === "closing")
                property bool up: root.stateState && root.stateState.value === "opening"

                // NumberAnimation doesn't reload to/from while it's running. If we switch from closing to opening or vice versa
                // we need to somehow stop and start the animation
                property bool animationHack: true
                onAnimationHackChanged: {
                    if (!animationHack) hackTimer.start();
                }
                Timer { id: hackTimer; interval: 1; onTriggered: arrows.animationHack = true }
                Connections { target: root.stateState; onValueChanged: arrows.animationHack = false }

                NumberAnimation {
                    target: arrowColumn
                    property: "y"
                    duration: 500
                    easing.type: Easing.Linear
                    from: arrows.up ? app.iconSize : -app.iconSize
                    to: arrows.up ? -app.iconSize : app.iconSize
                    loops: Animation.Infinite
                    running: arrows.animationHack && root.stateState && (root.stateState.value === "opening" || root.stateState.value === "closing")
                }

                Column {
                    id: arrowColumn
                    width: parent.width

                    Repeater {
                        model: arrows.height / app.iconSize + 1
                        ColorIcon {
                            name: arrows.up ? "../images/up.svg" : "../images/down.svg"
                            width: parent.width
                            height: width
                            color: Style.accentColor
                        }
                    }
                }
            }
        }

        Item {
            id: shutterControlsContainer
            Layout.fillWidth: true
            Layout.minimumWidth: minimumWidth
            Layout.fillHeight: true
            property int minimumWidth: app.iconSize * 10
            property int minimumHeight: app.iconSize * 2.5

            ProgressButton {
                anchors.centerIn: parent
                visible: root.isImpulseBased
                longpressEnabled: false
                imageSource: "../images/closable-move.svg"
                onClicked: {
                    var actionTypeId = root.thing.thingClass.actionTypes.findByName("triggerImpulse").id
                    print("Triggering impulse", actionTypeId)
                    engine.thingManager.executeAction(root.thing.id, actionTypeId)
                }
            }

            ShutterControls {
                id: shutterControls
                thing: root.thing
                width: parent.width
                anchors.centerIn: parent
                spacing: (parent.width - app.iconSize*2*children.length) / (children.length - 1)
                visible: !root.isImpulseBased
            }
        }
    }
}
