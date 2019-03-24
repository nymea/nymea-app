import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Select state")
        onBackPressed: pageStack.pop()
    }

    property Device device: null

    signal stateSelected(var stateTypeId);

    ListView {
        anchors.fill: parent

        model: device.deviceClass.stateTypes

        delegate: MeaListItemDelegate {
            width: parent.width
            iconName: "../images/state.svg"
            text: model.displayName
            subText: root.device.states.getState(model.id).value
            prominentSubText: false
            onClicked: {
                root.stateSelected(model.id)
            }
        }
    }
}
