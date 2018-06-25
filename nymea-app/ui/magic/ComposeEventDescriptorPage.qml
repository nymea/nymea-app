import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

Page {
    id: root
    property var device: null

    header: GuhHeader {
        text: qsTr("Select event")
    }

    ColumnLayout {
        anchors.fill: parent

        ColumnLayout {
            visible: root.device == null
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                RadioButton {
                    text: qsTr("A specific thing")
                    checked: true
                }
                RadioButton {
                    text: qsTr("A group of things")
                }
            }

            ListView {
//                Layout.fi
            }
        }

    }

}
