import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Developer options")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

            Label {
                Layout.fillWidth: true
                text: qsTr("Cloud environment")
            }

            ComboBox {
                currentIndex: model.indexOf(app.settings.cloudEnvironment)
                model: AWSClient.availableConfigs
                onActivated: {
                    app.settings.cloudEnvironment = model[index];
                }
            }
        }
    }
}
