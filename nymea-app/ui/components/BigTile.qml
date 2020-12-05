import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import Nymea 1.0

    Item {
    id: root
    implicitHeight: layout.implicitHeight + app.margins

    property Thing thing: null

    property bool showHeader: true

    property alias contentItem: content.contentItem

    property alias leftPadding: content.leftPadding
    property alias rightPadding: content.rightPadding
    property alias topPadding: content.topPadding
    property alias bottomPadding: content.bottomPadding

    readonly property State connectedState: thing.stateByName("connected")
    readonly property bool isConnected: connectedState === null || connectedState.value === true
    readonly property bool isEnabled: thing.setupStatus == Thing.ThingSetupStatusComplete && isConnected

    signal clicked();
    signal pressAndHold();

    function wobble() {
        wobbleAnimation.start();
    }

    onPressAndHold: {
        var contextMenuComponent = Qt.createComponent("../components/ThingContextMenu.qml");
        var contextMenu = contextMenuComponent.createObject(root, { thing: root.thing })
        contextMenu.x = Qt.binding(function() { return (root.width - contextMenu.width) / 2 })
        contextMenu.open()
    }

    transform: Translate { id: wobbleTransform }

    SequentialAnimation {
        id: wobbleAnimation

        PropertyAnimation {
            target: wobbleTransform
            property: "x"
            from: 0
            to: 10
            duration: 50
            easing.type: Easing.OutCirc
        }
        PropertyAnimation {
            target: wobbleTransform
            property: "x"
            from: 10
            to: 0
            duration: 400
            easing.type: Easing.OutElastic
            easing.amplitude: 2
            easing.period: 0.4
        }
    }


    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: app.margins / 2
        radius: 6

        gradient: Gradient {
            GradientStop {
                position: (headerRow.height + app.margins) / background.height
                color: Qt.tint(app.backgroundColor, Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .05))
            }
            GradientStop {
                position: (headerRow.height + app.margins) / background.height
                color:root.showHeader ?
                          Qt.tint(app.backgroundColor, Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .1))
                        : Qt.tint(app.backgroundColor, Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .05))
            }
        }
    }

    ColumnLayout {
        id: layout
        spacing: 0
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins / 2 }

        RowLayout {
            id: headerRow
            visible: root.showHeader
            Layout.margins: app.margins / 2
            Label {
                Layout.fillWidth: true
                text: root.thing.name
                elide: Text.ElideRight
            }
            ThingStatusIcons {
                thing: root.thing
            }
        }

        ItemDelegate {
            id: content
            Layout.fillWidth: true
            height: contentItem.implicitHeight
            onClicked: root.clicked()
            onPressAndHold: root.pressAndHold()
        }
    }
}
