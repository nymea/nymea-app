import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ToolBar {
    id: root
    height: 50 + (d.menuOpen ? app.iconSize * 3 + app.margins / 2 : 0)
    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    property string title
    property alias model: menuRepeater.model

    QtObject {
        id: d
        property bool menuOpen: false
    }

    RowLayout {
        id: mainRow
        height: 50
        width: parent.width
        opacity: d.menuOpen ? 0 : 1
        Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

        Label {
            id: label
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: app.margins
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: app.mediumFont
            elide: Text.ElideRight
            text: root.title.toLowerCase();
        }

        HeaderButton {
            id: menuButton
            imageSource: "../images/navigation-menu.svg"
            onClicked: d.menuOpen = true
        }
    }

    RowLayout {
        height: 50
        anchors.bottom: menuPanel.top
        width: parent.width
        opacity: d.menuOpen ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: app.margins
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: app.mediumFont
            elide: Text.ElideRight
            text: qsTr("menu")
        }

        HeaderButton {
            imageSource:"../images/close.svg"
            onClicked: d.menuOpen = false
        }
    }

    Flickable {
        id: menuPanel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: app.margins / 2
        width: Math.min(menuRow.childrenRect.width, parent.width)
        height: app.iconSize * 3
        contentWidth: menuRow.childrenRect.width
        opacity: d.menuOpen ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

        Row {
            id: menuRow
            Repeater {
                id: menuRepeater

                MouseArea {
                    height: app.iconSize * 3
                    width: app.iconSize * 3

                    onClicked: {
                        d.menuOpen = false
                        pageStack.push(model.page)
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: app.margins / 2
                        border.width: 1
                        border.color: app.guhAccent
                        color: "transparent"
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: app.margins / 2
                            ColorIcon {
                                name: model.iconSource
                                Layout.preferredHeight: app.iconSize
                                Layout.preferredWidth: app.iconSize
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: model.text
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: app.smallFont - 2
                            }
                        }
                    }
                }
            }
        }
    }
}
