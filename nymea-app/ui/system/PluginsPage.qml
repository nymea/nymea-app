import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Plugins")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/configure.svg"
            color: pluginsProxy.showOnlyConfigurable ? app.accentColor : keyColor
            onClicked: {
                pluginsProxy.showOnlyConfigurable = !pluginsProxy.showOnlyConfigurable
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("This list shows the list of installed plugins on this %1 system.").arg(app.systemName)
        }

        ThinDivider {}

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: PluginsProxy {
                id: pluginsProxy
                plugins: engine.deviceManager.plugins
            }
            clip: true

            delegate: NymeaListItemDelegate {
                property var plugin: pluginsProxy.get(index)
                width: parent.width
                iconName: "../images/plugin.svg"
                text: model.name
                progressive: plugin.paramTypes.count > 0
                onClicked: pageStack.push(Qt.resolvedUrl("PluginParamsPage.qml"), {plugin: plugin})
            }
        }
    }

}
