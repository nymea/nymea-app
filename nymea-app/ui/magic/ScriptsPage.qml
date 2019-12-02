import QtQuick 2.0
import Nymea 1.0
import QtQuick.Controls 2.2
import "../components"

Page {
    header: NymeaHeader {
        text: qsTr("Scripts")
        onBackPressed: pageStack.pop();

        HeaderButton {
            text: qsTr("Add new script")
            imageSource: "../images/add.svg"
            onClicked: {
                pageStack.push("ScriptEditor.qml");
            }
        }
    }

    QtObject {
        id: d
        property int pendingAction: -1
    }

    Connections {
        target: engine.scriptManager
        onRemoveScriptReply: {
            if (id == d.pendingAction) {
                d.pendingAction = -1;
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: engine.scriptManager.scripts
        delegate: NymeaListItemDelegate {
            width: parent.width
            text: model.name
            iconName: "../images/script.svg"
            canDelete: true
            onClicked: {
                pageStack.push("ScriptEditor.qml", {scriptId: model.id});
            }

            onDeleteClicked: {
                print("removing script", model.id)
                d.pendingAction = engine.scriptManager.removeScript(model.id);
            }
        }

        EmptyViewPlaceholder {
            anchors.centerIn: parent
            title: qsTr("No scripts are installed yet.")
            text: qsTr("Press \"Add script\" to get started.")
            imageSource: "../images/script.svg"
            buttonText: qsTr("Add script")
            visible: engine.scriptManager.scripts.count === 0
            onButtonClicked: {
                pageStack.push("ScriptEditor.qml");
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
        visible: d.pendingAction != -1
    }
}
