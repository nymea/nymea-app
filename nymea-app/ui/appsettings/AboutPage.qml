import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
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
            githubLink: "https://github.com/nymea/nymea-app"

            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("App version:")
                subText: appVersion
                progressive: false
                prominentSubText: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Qt version:")
                subText: qtVersion + (qtBuildVersion !== qtVersion ? " (" + qsTr("Built with %1").arg(qtBuildVersion) + ")" : "")
                progressive: false
                prominentSubText: false
            }
        }
    }
}
