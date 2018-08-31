import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {

    id: root
    header: GuhHeader {
        text: qsTr("About %1").arg(app.systemName)
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        MeaListItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Server UUID:")
            subText: engine.jsonRpcClient.serverUuid
            progressive: false
        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Server version:")
            subText: engine.jsonRpcClient.serverVersion
            progressive: false
        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Protocol version:")
            subText: engine.jsonRpcClient.jsonRpcVersion
            progressive: false
        }
    }
}
