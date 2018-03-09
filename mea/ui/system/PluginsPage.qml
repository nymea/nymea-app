import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Mea 1.0

Page {
    id: root
    header: GuhHeader {
        text: "Plugins"
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: Engine.deviceManager.plugins
        clip: true

        delegate: ItemDelegate {
            width: parent.width
            contentItem: RowLayout {
                Label {
                    Layout.fillWidth: true
                    text: model.name
                }
                Image {
                    source: "../images/next.svg"
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: height
                }
            }
            onClicked: pageStack.push(Qt.resolvedUrl("PluginParamsPage.qml"), {plugin: Engine.deviceManager.plugins.get(index)})
        }
    }

}
