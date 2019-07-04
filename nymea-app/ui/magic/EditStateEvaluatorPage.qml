import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Conditions")
        onBackPressed: pageStack.pop()
    }

    property var stateEvaluator: null

    StateEvaluatorDelegate {
        width: parent.width
        stateEvaluator: root.stateEvaluator
        canDelete: false
    }
}
