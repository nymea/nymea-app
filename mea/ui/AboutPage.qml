import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("About %1").arg(app.systemName)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    GridLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
        rowSpacing: app.margins
        columns: 2


        Image {
            Layout.preferredHeight: app.iconSize * 5
            Layout.columnSpan: 2
            Layout.fillWidth: true
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            source: "../guh-logo.svg"
        }

        Label {
            text: qsTr("App version:")
        }
        Label {
            text: appVersion
        }
        Label {
            text: qsTr("Qt version:")
        }
        Label {
            text: qtVersion
        }

    }
}
