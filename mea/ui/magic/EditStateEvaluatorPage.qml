import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Mea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: "Conditions"
        onBackPressed: pageStack.pop()
    }

    property var stateEvaluator: null

    StateEvaluatorDelegate {
        width: parent.width
        stateEvaluator: root.stateEvaluator
    }
}
