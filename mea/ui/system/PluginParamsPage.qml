import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import "../paramdelegates-ng"
import Mea 1.0

Page {
    id: root
    property var plugin: null

    header: GuhHeader {
        text: qsTr("%1 settings").arg(plugin.name)
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/tick.svg"
            onClicked: {
                Engine.deviceManager.savePluginConfig(root.plugin.pluginId)
            }
        }
    }

    Connections {
        target: Engine.deviceManager
        onSavePluginConfigReply: {
            if (params.params.deviceError == "DeviceErrorNoError") {
                pageStack.pop();
            } else {
                console.warn("Error saving plugin params:", JSON.stringify(params))
                var dialog = errorDialog.createObject(root, {title: "Error", text: "Error saving params: " + JSON.stringify(params.params.deviceError)});
                dialog.open();
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight

        ColumnLayout {
            id: column
            width: parent.width

            Repeater {
                model: plugin.paramTypes

                delegate: ParamDelegate {
                    Layout.fillWidth: true
                    paramType: root.plugin.paramTypes.get(index)
                    param: root.plugin.params.getParam(model.id)
                }
            }
        }
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }
}
