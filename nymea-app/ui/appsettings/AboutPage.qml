import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("About %1").arg(app.appName)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: imprint.implicitHeight

        Imprint {
            id: imprint
            width: parent.width
            title: app.appName
            githubLink: "https://github.com/guh/nymea-app"

            MeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("App version:")
                subText: appVersion
                progressive: false
                prominentSubText: false
            }
            MeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Qt version:")
                subText: qtVersion
                progressive: false
                prominentSubText: false
            }
        }
    }
}
