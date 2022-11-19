import QtQuick 2.0
import QtQuick.Controls 2.2
import Nymea 1.0

ListView {
    id: root
    currentIndex: 1
    orientation: ListView.Horizontal
    property alias swipeEnabled: edgeDragArea.enabled

    property alias header: contentItem.header
    property alias children: contentItem.contentChildren
    default property alias data: contentItem.contentData
    property alias background: contentItem.background
    snapMode: ListView.SnapToItem
    highlightRangeMode: ListView.StrictlyEnforceRange
    interactive: false
    StackView.visible: isSecondInStack || isTopMost

    readonly property bool isTopMost: StackView.index == StackView.view.depth - 1
    readonly property bool isSecondInStack: StackView.index == StackView.view.depth - 2
    readonly property Item topMostItem: StackView.view.currentItem

    onCurrentIndexChanged: {
        if(currentIndex === 0) {
            pageStack.pop()
            console.log("popped")
        }
    }

    model: VisualItemModel {
        Item {
            height: root.height
            width: root.width
        }

        Page {
            id: contentItem
            height: root.height
            width: root.width
        }
    }

    MouseArea {
        id: edgeDragArea
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: 10
        onMouseXChanged: {
            root.contentX = root.width - mouseX
        }
        onReleased: {
            root.positionViewAtIndex(1, ListView.SnapPosition)
        }
    }
}

