import QtQuick 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "qrc:/ui/components"
import Nymea 1.0

Item {

    DevicesProxy {
        id: garagesFilterModel
        engine: _engine
        shownInterfaces: ["garagegate"]
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

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: app.margins

                    Label {
                        text: garageGateView.device.name
                        font.pixelSize: app.largeFont
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ColorIcon {
                        name: "qrc:/ui/images/shutter/shutter-" + currentImage + ".svg"
                        Layout.fillWidth: true
                        Layout.preferredHeight: width

                        property string currentImage: garageGateView.openState.value === "closed" ? "100" :
                                                garageGateView.openState.value === "open" && garageGateView.intermediatePositionState.value === false ? "000" : "050"

                    }

                    ShutterControls {
                        id: controls
                        Layout.fillWidth: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        device: garageGateView.device
                    }
                }
            }
        }
    }
}
