import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    title: qsTr("WiFi list options")

    property WirelessAccessPointsProxy wirelessAccessPointsProxy: null

    header: Item {

        height: 28 + 2 * Style.margins

        RowLayout {
            anchors.fill: parent
            spacing: app.margins

            HeaderButton {
                id: backButton
                objectName: "backButton"
                imageSource: "qrc:/icons/back.svg"
                onClicked: pageStack.pop();
            }

            Label {
                Layout.fillWidth: true
                id: titleLabel
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                font.pixelSize: app.largeFont
            }
        }
    }

    Settings {
        id: settings
        property bool wirelessShowDuplicates: false
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: app.margins


        NymeaItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Show all networks")
            subText: qsTr("Multiple networks with the same name get filterd out")
            prominentSubText: false
            progressive: false
            additionalItem: Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: settings.wirelessShowDuplicates
                onCheckedChanged:  {
                    settings.wirelessShowDuplicates = checked
                    wirelessAccessPointsProxy.showDuplicates = checked
                }
            }
        }
    }
}
