import QtQuick 2.0

Item {
    id: arrows
    width: app.iconSize * 2
    height: parent.height * .6
    clip: true
    visible: state !== ""

    state: "" // "opening", "closing" or ""

    readonly property bool up: arrows.state === "opening"

    // NumberAnimation doesn't reload to/from while it's running. If we switch from closing to opening or vice versa
    // we need to somehow stop and start the animation
    property bool animationHack: true
    onAnimationHackChanged: {
        if (!animationHack) hackTimer.start();
    }
    Timer { id: hackTimer; interval: 1; onTriggered: arrows.animationHack = true }
    onStateChanged: arrows.animationHack = false

    NumberAnimation {
        target: arrowColumn
        property: "y"
        duration: 500
        easing.type: Easing.Linear
        from: arrows.up ? app.iconSize : -app.iconSize
        to: arrows.up ? -app.iconSize : app.iconSize
        loops: Animation.Infinite
        running: arrows.animationHack && (arrows.state === "opening" || arrows.state === "closing")
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
                color: app.accentColor
            }
        }
    }
}
