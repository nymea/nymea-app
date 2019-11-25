import QtQuick 2.2
import QtQuick.Controls 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import "../../components"

Rectangle {
    id: root
    border.width: 1
    border.color: app.foregroundColor
    color: app.backgroundColor
    height: (Math.min(model.count, 10) * d.entryHeight) + (border.width * 2)
    width: 200

    visible: model.count > 0 && !d.hidden
             && (model.filter.length >= 3 || d.manuallyInvoked)

    property TextArea textArea: null
    property CompletionModel model: null
    property alias font: dummyLabel.font

    signal complete(int index)

    Connections {
        target: root.model
        onCountChanged: {
            d.hidden = false;
            d.currentIndex = 0;
            if (root.model.count == 0) {
                d.manuallyInvoked = false;
            }
        }
    }

    readonly property alias currentIndex: d.currentIndex

    function next() {
        d.currentIndex = (d.currentIndex + 1) % root.model.count
    }

    function previous() {
        d.currentIndex--;
        if (d.currentIndex < 0) {
            d.currentIndex = root.model.count - 1
        }
    }

    function show() {
        if (root.model.count > 1) {
            d.hidden = false;
            d.manuallyInvoked = true;
        }
    }

    function hide() {
        d.hidden = true;
        d.manuallyInvoked = false;
    }

    onCurrentIndexChanged: {
        listView.positionViewAtIndex(currentIndex, ListView.Contain)
    }

    Label {
        id: dummyLabel
    }

    QtObject {
        id: d
        property int entryHeight: dummyLabel.font.pixelSize + 6

        property int currentIndex: 0
        property bool hidden: false
        property bool manuallyInvoked: false
    }


    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: root.border.width
        model: root.model
        ScrollBar.vertical: ScrollBar {
            policy: root.model.count > 10 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        }
        clip: true

        delegate: Rectangle {
            height: d.entryHeight
            width: parent.width
            color: index == root.currentIndex ? app.accentColor : "transparent"
            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredHeight: d.entryHeight
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignVCenter
                    Rectangle {
                        anchors.centerIn: parent
                        height: root.font.pixelSize * .6
                        width: height
                        border.width: 1
                        border.color: "black"
                        visible: !entryIcon.visible
                        color: {
                            switch (model.decoration) {
                            case "type":
                                return "#55fc49";
                            case "keyword":
                                return "yellow";
                            case "property":
                                return "#ff5555";
                            case "method":
                                return "blue";
                            case "event":
                                return "magenta";
                            case "id":
                                return "turquise";
                            default:
                                return "transparent";
                            }
                        }
                    }
                    ColorIcon {
                        id: entryIcon
                        height: root.font.pixelSize
                        width: height
                        anchors.centerIn: parent
                        visible: name != ""
                        color: root.currentIndex == index ? app.backgroundColor : app.accentColor
                        name: {
                            switch (model.decoration) {
                            case "thing":
                                return app.interfacesToIcon(model.decorationProperty.split(","))
                            case "eventType":
                                return Qt.resolvedUrl("../../images/event.svg")
                            case "stateType":
                                return Qt.resolvedUrl("../../images/state.svg")
                            case "actionType":
                                return Qt.resolvedUrl("../../images/action.svg")
                            }
                            return ""
                        }
                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    Layout.fillWidth: true
                    text: model.displayText
                    color: app.foregroundColor
                    width: parent.width
                    elide: Text.ElideRight
                    font: root.font
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.complete(index)
                }
            }
        }
    }
}
