import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0

Item {
    id: root
    implicitHeight: layout.implicitHeight + app.margins

    property alias header: headerContainer.children
    property alias contentItem: content.contentItem

    property alias showHeader: headerContainer.visible

    property alias leftPadding: content.leftPadding
    property alias rightPadding: content.rightPadding
    property alias topPadding: content.topPadding
    property alias bottomPadding: content.bottomPadding

    property bool interactive: true

    signal clicked();
    signal pressAndHold();

    Material.foreground: Style.tileForegroundColor

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
        radius: Style.cornerRadius

        gradient: Gradient {
            GradientStop {
                position: (headerContainer.height + app.margins) / background.height
                color: Style.tileBackgroundColor
            }
            GradientStop {
                position: (headerContainer.height + app.margins) / background.height
                color: headerContainer.visible ?
                          Style.tileOverlayColor
                        : Style.tileBackgroundColor
            }
        }
    }

    ColumnLayout {
        id: layout
        spacing: 0
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins / 2 }

        Item {
            id: headerContainer
            Layout.fillWidth: true
            Layout.margins: app.margins / 2
            visible: children.length > 0
            height: childrenRect.height
        }

        ItemDelegate {
            id: content
            Layout.fillWidth: true
            height: contentItem.implicitHeight
            onClicked: root.clicked()
            hoverEnabled: root.interactive
            onPressAndHold: {
                if (root.interactive) {
                    root.pressAndHold()
                }
            }
        }
    }
}
