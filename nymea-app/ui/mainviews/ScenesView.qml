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
        cellHeight: cellWidth

        delegate: MainPageTile {
            width: interfacesGridView.cellWidth
            height: interfacesGridView.cellHeight
            iconName: iconTag ? "../images/" + iconTag.value + ".svg" : "../images/slideshow.svg";
            fallbackIconName: "../images/slideshow.svg"
            iconColor: colorTag ? colorTag.value : app.accentColor;
            text: model.name.toUpperCase()

            property var colorTag: Engine.tagsManager.tags.findRuleTag(model.id, "color")
            property var iconTag: Engine.tagsManager.tags.findRuleTag(model.id, "icon")

            onClicked: Engine.ruleManager.executeActions(model.id)

            Connections {
                target: Engine.tagsManager.tags
                onCountChanged: {
                    colorTag = Engine.tagsManager.tags.findRuleTag(model.id, "color")
                    iconTag = Engine.tagsManager.tags.findRuleTag(model.id, "icon")
                }
            }
        }
    }
}
