import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Cloud settings")
        onBackPressed: pageStack.pop();
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        Label {
            Layout.fillWidth: true
            text: Engine.jsonRpcClient.cloudConnected
        }

        SwitchDelegate {
            Layout.fillWidth: true
            text: qsTr("Cloud connection enabled")
            checked: Engine.basicConfiguration.cloudEnabled
            onToggled: {
                Engine.basicConfiguration.cloudEnabled = checked;
            }
        }
    }
}
