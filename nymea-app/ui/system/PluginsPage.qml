import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Plugins")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: Engine.deviceManager.plugins
        clip: true

        delegate: MeaListItemDelegate {
            width: parent.width
            iconName: "../images/plugin.svg"
            text: model.name
            onClicked: pageStack.push(Qt.resolvedUrl("PluginParamsPage.qml"), {plugin: Engine.deviceManager.plugins.get(index)})
        }
    }
}
