import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import QtQuick.Controls.Material 2.2
import "../components"

Item {
    id: root

    readonly property int count: interfacesGridView.count

    GridView {
        id: interfacesGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2

        readonly property int minTileWidth: 180
        readonly property int minTileHeight: 180
        readonly property int tilesPerRow: root.width / minTileWidth

        model: RulesFilterModel {
            rules: Engine.ruleManager.rules
            filterExecutable: true
        }
        cellWidth: width / tilesPerRow
        cellHeight: Math.max(cellWidth, minTileHeight)
        delegate: Item {
            id: scenesDelegate
            width: interfacesGridView.cellWidth
            height: interfacesGridView.cellHeight

            property var colorTag: Engine.tagsManager.tags.findRuleTag(model.id, "color")
            property var iconTag: Engine.tagsManager.tags.findRuleTag(model.id, "icon")
            Connections {
                target: Engine.tagsManager.tags
                onCountChanged: {
                    colorTag = Engine.tagsManager.tags.findRuleTag(model.id, "color")
                    iconTag = Engine.tagsManager.tags.findRuleTag(model.id, "icon")
                }
            }

            Pane {
                anchors.fill: parent
                anchors.margins: app.margins / 2
                Material.elevation: 1

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Engine.ruleManager.executeActions(model.id)
                    }
                }

                ColumnLayout {
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: app.margins

                    ColorIcon {
                        Layout.preferredHeight: app.iconSize * 2
                        Layout.preferredWidth: height
                        Layout.alignment: Qt.AlignHCenter
                        name: scenesDelegate.iconTag ? "../images/" + scenesDelegate.iconTag.value + ".svg" : "../images/slideshow.svg";
                        color: scenesDelegate.colorTag ? scenesDelegate.colorTag.value : app.guhAccent;
                    }

                    Label {
                        Layout.fillWidth: true
                        text: model.name
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

}
