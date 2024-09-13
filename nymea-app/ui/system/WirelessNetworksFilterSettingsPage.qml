import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.1

import "qrc:/ui/components"
import Nymea 1.0

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
                imageSource: "../images/back.svg"
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
