import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "qrc:/ui/components"
import Nymea 1.0

Item {
    id: root
    readonly property string title: qsTr("Garage gates")
    readonly property string icon: Qt.resolvedUrl("qrc:/ui/images/shutter/shutter-050.svg")

    DevicesProxy {
        id: garagesFilterModel
        engine: _engine
        shownInterfaces: ["garagegate"]
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        text: qsTr("There are no garage gates set up yet.")
        imageSource: "qrc:/ui/images/shutter/shutter-050.svg"
        buttonText: qsTr("Set up now")
        visible: garagesFilterModel.count === 0
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent

        Repeater {
            model: garagesFilterModel

            Item {
                id: garageGateView
                width: swipeView.width
                height: swipeView.height

                readonly property Device device: garagesFilterModel.get(index)

                readonly property StateType openStateType: device.deviceClass.stateTypes.findByName("state")
                readonly property State openState: openStateType ? device.states.getState(openStateType.id) : null

                readonly property StateType intermediatePositionStateType: device.deviceClass.stateTypes.findByName("intermediatePosition")
                readonly property State intermediatePositionState: intermediatePositionStateType ? device.states.getState(intermediatePositionStateType.id) : null

                GridLayout {
                    id: layout
                    anchors.fill: parent
                    anchors.margins: app.margins
                    columns: app.landscape ? 2 : 1

                    Label {
                        id: label
                        text: garageGateView.device.name
                        font.pixelSize: app.largeFont
                        Layout.preferredWidth: layout.width
                        Layout.columnSpan: parent.columns
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.minimumWidth: app.landscape ? layout.width / 2 : layout.width

                        ColorIcon {
                            height: Math.min(parent.height, parent.width)
                            width: height
                            anchors.centerIn: parent
                            name: "qrc:/ui/images/shutter/shutter-" + currentImage + ".svg"
                            property string currentImage: garageGateView.openState.value === "closed" ? "100" :
                                                    garageGateView.openState.value === "open" && garageGateView.intermediatePositionState.value === false ? "000" : "050"
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: controls.implicitHeight
                        Layout.minimumWidth: app.landscape ? layout.width / 2 : layout.width

                        ShutterControls {
                            id: controls
                            device: garageGateView.device
                            spacing: (parent.width - app.iconSize*2*children.length) / (children.length - 1)
                        }
                    }
                }
            }
        }
    }

    PageIndicator {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        count: garagesFilterModel.count
        currentIndex: swipeView.currentIndex
    }
}
