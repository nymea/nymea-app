import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Authentication") + userManager.tokenInfos.count
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    UserManager {
        id: userManager
        engine: _engine
    }

    ColumnLayout {
        id: settingsGrid
        anchors.fill: parent
//        width: Math.min(500, parent.width - app.margins * 2)

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: userManager.tokenInfos

            delegate: NymeaListItemDelegate {
                width: parent.width
                text: model.deviceName
                subText: qsTr("Created on %1").arg(Qt.formatDateTime(model.creationTime, Qt.DefaultLocaleShortDate))
                prominentSubText: false
                progressive: false
            }
        }
    }
}
