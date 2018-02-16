import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root
    property var device: null

    header: GuhHeader {
        text: "Select event"
    }

    ColumnLayout {
        anchors.fill: parent

        ColumnLayout {
            visible: root.device == null
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                RadioButton {
                    text: "A specific thing"
                    checked: true
                }
                RadioButton {
                    text: "A group of things"
                }
            }

            ListView {
//                Layout.fi
            }
        }

    }

}
