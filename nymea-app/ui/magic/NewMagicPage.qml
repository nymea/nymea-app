import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root


    header: NymeaHeader {
        text: qsTr("New magic")
        onBackPressed: pageStack.pop()
    }

    RuleTemplates {
        id: ruleTemplates
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: RuleTemplatesFilterModel {
                ruleTemplates: ruleTemplates
            }

            delegate: NymeaListItemDelegate {
                width: parent.width
                text: model.description
            }
        }
    }
}
