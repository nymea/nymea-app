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
        onScriptRemoved: {
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
            subText: model.id
            canDelete: true
            onDeleteClicked: {
                print("removing script", model.id)
                d.pendingAction = engine.scriptManager.removeScript(model.id);
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
        visible: d.pendingAction != -1
    }
}
