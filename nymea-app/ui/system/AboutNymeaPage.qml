import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {

    id: root
    header: NymeaHeader {
        text: qsTr("About %1:core").arg(app.systemName)
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: imprint.implicitHeight

        Imprint {
            id: imprint
            width: parent.width
            title: qsTr("%1:core").arg(app.systemName)
            githubLink: "https://github.com/guh/nymea"

            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Connection:")
                subText: engine.connection.currentConnection.url
                progressive: false
                prominentSubText: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Server UUID:")
                subText: engine.jsonRpcClient.serverUuid
                progressive: false
                prominentSubText: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Server version:")
                subText: engine.jsonRpcClient.serverVersion
                progressive: false
                prominentSubText: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("JSON-RPC version:")
                subText: engine.jsonRpcClient.jsonRpcVersion
                progressive: false
                prominentSubText: false
            }
        }
    }
}
