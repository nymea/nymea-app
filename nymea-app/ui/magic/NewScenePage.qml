import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("New scene")
        onBackPressed: pageStack.pop()
    }

    signal done()


    ListView {
        anchors.fill: parent
        model: RuleTemplatesFilterModel {

            ruleTemplates: RuleTemplates {}
            filterByDevices: DevicesProxy {
                engine: _engine
            }

        }

        delegate: NymeaListItemDelegate {
            text: model.description
        }
    }

}
