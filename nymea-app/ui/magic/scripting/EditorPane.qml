import QtQuick 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import "../../components"

Item {
    id: pane
    implicitHeight: shown ? 40 + 10 * app.smallFont : 25

    readonly property bool shown: (shownOverride === "auto" && autoWouldShow)
                                  || shownOverride == "shown"
    readonly property alias autoWouldShow: d.autoWouldShow
    property string shownOverride: "auto" // "shown", "hidden"

    default property alias panels: contentContainer.data

    QtObject {
        id: d
        property bool autoWouldShow: false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            id: panelHeader
            Layout.fillWidth: true
            Layout.rightMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.maximumHeight: 24
            Layout.minimumHeight: 24

            TabBar {
                id: panelTabs
                Layout.fillHeight: true

                Repeater {
                    model: contentContainer.data

                    TabButton {
                        implicitHeight: panelHeader.height
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: panelHeader.height
                            color: app.backgroundColor
                            Label {
                                anchors.centerIn: parent
                                text: contentContainer.data[index].title
                                font.pixelSize: app.smallFont
                            }
                        }
                        Binding {
                            target: contentContainer.data[index]
                            property: "visible"
                            value: panelTabs.currentIndex === index
                        }
                        Connections {
                            target: contentContainer.data[index]
                            onRaise: {
                                panelTabs.currentIndex = index
                                d.autoWouldShow = true;
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            ColorIcon {
                name: "../images/edit-clear.svg"
                enabled: contentContainer.data[panelTabs.currentIndex].clearEnabled
                color: enabled ? app.accentColor : keyColor
                Layout.preferredHeight: app.iconSize  / 2
                Layout.preferredWidth: height
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: contentContainer.data[panelTabs.currentIndex].clear()
                }
            }

            ColorIcon {
                name: pane.shown ? "../images/down.svg" : "../images/up.svg"
                Layout.preferredHeight: app.iconSize  / 2
                Layout.preferredWidth: height
                color: app.accentColor
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: {
                        if (pane.shown) {
                            if (pane.autoWouldShow) {
                                pane.shownOverride = "hidden"
                            } else {
                                pane.shownOverride = "auto"
                            }
                        } else {
                            if (pane.autoWouldShow) {
                                pane.shownOverride = "auto"
                            } else {
                                pane.shownOverride = "shown"
                            }
                        }
                    }
                }
            }
        }

        ThinDivider {}

        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

        }
    }
}
