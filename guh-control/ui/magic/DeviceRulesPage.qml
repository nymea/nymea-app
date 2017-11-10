import QtQuick 2.8
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

Page {
    id: root

    property var device: null

    header: GuhHeader {
        text: qsTr("Magic involving %1").arg(root.device.name)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/add.svg"
            visible: rulesListView.count > 0
            onClicked: addRule()
        }
    }

    function addRule() {
        pageStack.push(Qt.resolvedUrl("NewThingMagicPage.qml"), {device: root.device, text: "Add magic"})
    }

    ListView {
        id: rulesListView
        anchors.fill: parent

        model: RulesFilterModel {
            id: rulesFilterModel
            rules: Engine.ruleManager.rules
            filterEventDeviceId: root.device.id
        }

        delegate: ItemDelegate {
            text: model.name
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        spacing: app.margins * 2
        visible: rulesListView.count == 0

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("There's no magic involving %1.").arg(root.device.name)
            font.pixelSize: app.largeFont
        }
        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Add some using the wizard stick!")
            font.pixelSize: app.largeFont
        }

        AbstractButton {
            height: app.iconSize * 4
            width: height
            anchors.horizontalCenter: parent.horizontalCenter

            ColorIcon {
                anchors.fill: parent
                name: "../images/magic.svg"
            }

            onClicked: addRule()
        }
    }
}
