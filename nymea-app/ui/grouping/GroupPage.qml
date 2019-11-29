import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: root.groupTag.substring(6)
        onBackPressed: pageStack.pop()
    }

    property string groupTag


    DevicesProxy {
        id: devicesInGroup
        engine: _engine
        filterTagId: root.groupTag
    }

    InterfacesProxy {
        id: interfacesInGroup
        devicesProxyFilter: devicesInGroup
        showStates: true
    }

    ListView {
        anchors.fill: parent
        model: devicesInGroup
        delegate: Label {
            text: model.name
        }
    }

}
