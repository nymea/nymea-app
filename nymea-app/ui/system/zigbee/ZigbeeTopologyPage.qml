import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "qrc:/ui/components"
import Nymea 1.0

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("ZigBee network topology")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property ZigbeeManager zigbeeManager: null
    property ZigbeeNetwork network: null

    readonly property int nodeDistance: 150
    readonly property int nodeSize: Style.iconSize + Style.margins
    readonly property double scale: 1


    Component.onCompleted: {
        zigbeeManager.refreshNeighborTables(network.networkUuid)

        reload();
        for (var i = 0; i < network.nodes.count; i++) {
            network.nodes.get(i).neighborsChanged.connect(function() {root.reload()})
        }
    }

    Connections {
        target: root.network.nodes
        onNodeAdded: {
            root.reload()
            node.neighborsChanged.connect(function() {root.reload()});
        }
    }

    function generateNodeList() {
        d.nodeItems = []
        var coordinator = {}
        var routers = []
        var endDevices = []
        for (var i = 0; i < root.network.nodes.count; i++) {
            var node = root.network.nodes.get(i);
            switch (node.type) {
            case ZigbeeNode.ZigbeeNodeTypeRouter:
                routers.push(node)
                break;
            case ZigbeeNode.ZigbeeNodeTypeEndDevice:
                endDevices.push(node);
                break;
            case ZigbeeNode.ZigbeeNodeTypeCoordinator:
                coordinator = node;
                break;
            }
        }

        var startAngle = -90

        var x = root.nodeDistance * Math.cos(startAngle * Math.PI / 180)
        var y = root.nodeDistance * Math.sin(startAngle * Math.PI / 180)
        d.nodeItems.push(createNodeItem(coordinator, x, y, startAngle))

        var handledEndDevices = []

        var angle = 360 / (routers.length + 1);
        for (var i = 0; i < routers.length; i++) {
            var router = routers[i]
            var nodeAngle = startAngle + angle * (i + 1);
            var x = root.nodeDistance * Math.cos(nodeAngle * Math.PI / 180)
            var y = root.nodeDistance * Math.sin(nodeAngle * Math.PI / 180)
            d.nodeItems.push(createNodeItem(routers[i], x, y, nodeAngle));


            var neighborCounter = 0;
            for (var j = 0; j < router.neighbors.length; j++) {
                var neighborNode = root.network.nodes.getNodeByNetworkAddress(router.neighbors[j].networkAddress)
                if (!neighborNode) {
                    continue
                }

                if (neighborNode.type == ZigbeeNode.ZigbeeNodeTypeEndDevice) {
                    if (handledEndDevices.indexOf(neighborNode.networkAddress) >= 0) {
                        continue;
                    }
                    handledEndDevices.push(neighborNode.networkAddress)


                    var neighborAngle  = nodeAngle + neighborCounter * 8
                    var neighborDistance = root.nodeDistance * 1.5 * root.scale + neighborCounter * root.nodeSize * 0.75 * root.scale

                    x = neighborDistance * Math.cos(neighborAngle * Math.PI / 180)
                    y = neighborDistance * Math.sin(neighborAngle * Math.PI / 180)
                    d.nodeItems.push(createNodeItem(neighborNode, x, y, angle))

                    neighborCounter++
                }
            }
        }

        var unconnectedNodes = []
        for (var i = 0; i < network.nodes.count; i++) {
            var node = network.nodes.get(i)
            if (node.type == ZigbeeNode.ZigbeeNodeTypeEndDevice && handledEndDevices.indexOf(node.networkAddress) < 0) {
                print("Adding unconnected node:","0x" + node.networkAddress.toString(16))
                unconnectedNodes.push(node)
            }
        }
        var cellWidth = root.nodeSize * 2
        var cellHeight = root.nodeSize * 2
        var maxColumns = (root.width - Style.bigMargins * 2) / cellWidth
        var columns = Math.min(unconnectedNodes.length, maxColumns)
        var rowWidth = columns * cellWidth
        print("columns:", columns, "maxCols", maxColumns)
        for (var i = 0; i < unconnectedNodes.length; i++) {
            var node = unconnectedNodes[i]
            var column = i % columns;
            var row = Math.floor(i / columns)
            var x = cellWidth * column + cellWidth / 2 - rowWidth / 2
            var y = Style.margins + cellHeight * row + root.nodeSize - root.height / 3
            var point = root.mapToItem(canvas, x, y)
            d.nodeItems.push(createNodeItem(node, point.x, point.y, 0))
        }
    }


    function createNodeItem(node, x, y, angle) {
        var icon = "/ui/images/zigbee.svg"
        var thing = null
        if (node.networkAddress == 0) {
            icon = "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        } else {
            for (var i = 0; i < engine.thingManager.things.count; i++) {
                var t = engine.thingManager.things.get(i)
//                print("checking thing", t.name)
                var param = t.paramByName("ieeeAddress")
                if (param && param.value == node.ieeeAddress) {
                    thing = t;
                    break;
                }
            }
        }

        if (thing) {
            icon = app.interfacesToIcon(thing.thingClass.interfaces)
        }

        var nodeItem = {
            node: node,
            x: x,
            y: y,
            edges: [],
            image: imageComponent.createObject(canvas, {
                                                   x: Qt.binding(function() { return x + (canvas.width - Style.iconSize) / 2}),
                                                   y: Qt.binding(function() { return y + (canvas.height - Style.iconSize) / 2}),
                                                   name: icon,
                                                   color: Style.accentColor
                                               }),
            thing: thing

        }
//        print("creared node", thing ? thing.name : "", " at", x, y)
        d.adjustSize(x, y)
        return nodeItem
    }

    function reload() {
        print("Reloading network map")
        while (d.nodeItems.length > 0) {
            var nodeItem = d.nodeItems.shift()
            nodeItem.image.destroy();
        }
//        d.selectedNodeItem= null
        d.minX = 0
        d.minY = 0
        d.maxX = 0
        d.maxY = 0
        d.size = 0
        generateNodeList();
        canvas.requestPaint()
        flickable.contentX = (flickable.contentWidth - flickable.width) / 2
        flickable.contentY = (flickable.contentHeight - flickable.height) / 2
    }

    QtObject {
        id: d
        property var nodeItems: []

        property int selectedNodeAddress: -1
        readonly property ZigbeeNode selectedNode: selectedNodeAddress >= 0 ? network.nodes.getNodeByNetworkAddress(selectedNodeAddress) : null

        property int minX: 0
        property int minY: 0
        property int maxX: 0
        property int maxY: 0
        property int size: 0

        function adjustSize(x, y) {
            minX = Math.min(minX, x)
            minY = Math.min(minY, y)
            maxX = Math.max(maxX, x)
            maxY = Math.max(maxY, y)
            var minWidth = Math.max(-minX, maxX) * 2
            var minHeight = Math.max(-minY, maxY) * 2
            size = Math.max(minWidth, minHeight) + root.nodeSize * 2
        }

    }

    Component {
        id: imageComponent
        ColorIcon {
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent

        contentWidth: canvas.width
        contentHeight: canvas.height
//        interactive: true
//        flickableDirection: Flickable.HorizontalAndVerticalFlick

        Canvas {
            id: canvas
            width: Math.max(d.size, flickable.width)
            height: Math.max(d.size, flickable.height)
            clip: true

            onPaint: {
//                print("**** height:", canvas.height, "width", canvas.width)
                var ctx = getContext("2d");
                ctx.reset();

                var center = { x: canvas.width / 2, y: canvas.height / 2 };
                ctx.translate(center.x, center.y)

                paintNodeList(ctx);
            }

            function paintNodeList(ctx) {
                for (var i = 0; i < d.nodeItems.length; i++) {
                    paintEdges(ctx, d.nodeItems[i], false)
                }
                for (var i = 0; i < d.nodeItems.length; i++) {
                    paintEdges(ctx, d.nodeItems[i], true)
                }
                for (var i = 0; i < d.nodeItems.length; i++) {
                    paintNode(ctx, d.nodeItems[i])
                }
            }

            function paintEdges(ctx, nodeItem, selected) {
                for (var i = 0; i < nodeItem.node.neighbors.length; i++) {
                    var neighbor = nodeItem.node.neighbors[i]
                    //                print("ege from", nodeItem.node.networkAddress, "to", neighbor, "LQI", neighbor.lqi, "depth:", neighbor.depth)
                    for (var k = 0; k < d.nodeItems.length; k++) {
                        if (d.nodeItems[k].node.networkAddress == neighbor.networkAddress) {
                            var toNodeItem = d.nodeItems[k]
                            if (nodeItem.node.networkAddress === d.selectedNodeAddress || toNodeItem.node.networkAddress === d.selectedNodeAddress) {
                                if (selected) {
                                    paintEdge(ctx, nodeItem, d.nodeItems[k], neighbor.lqi, true)
                                }
                            } else {
                                if (!selected) {
                                    paintEdge(ctx, nodeItem, d.nodeItems[k], neighbor.lqi, false)
                                }
                            }
                            continue
                        }
                    }
                }
            }

            function paintNode(ctx, nodeItem) {
                ctx.save()
                ctx.beginPath();
                ctx.fillStyle = nodeItem.node.networkAddress === d.selectedNodeAddress ? Style.tileOverlayColor : Style.tileBackgroundColor
                ctx.strokeStyle = nodeItem.node.networkAddress === d.selectedNodeAddress ? Style.accentColor : Style.tileBackgroundColor
                ctx.arc(root.scale * nodeItem.x, root.scale * nodeItem.y, root.scale * root.nodeSize / 2, 0, 2 * Math.PI);
                ctx.fill();
//                ctx.stroke();
                ctx.fillStyle = Style.foregroundColor
                ctx.font = "" + Style.extraSmallFont.pixelSize + "px Ubuntu";
                var text = ""
                if (nodeItem.thing) {
                    text = nodeItem.thing.name
                } else {
                    text = nodeItem.node.model
                }
                if (text.length > 10) {
                    text = text.substring(0, 9) + "…"
                }

                var textSize = ctx.measureText(text)
                //            ctx.fillText(text, scale * (nodeItem.x ), scale * (nodeItem.y ))
                ctx.fillText(text, scale * (nodeItem.x - textSize.width / 2), scale * (nodeItem.y + root.nodeSize / 2 + Style.extraSmallFont.pixelSize))

                ctx.closePath();

                ctx.restore();
            }

            function paintEdge(ctx, fromNodeItem, toNodeItem, lqi, selected) {
                ctx.save()
                var percent = lqi / 255;
                var goodColor = Style.green
                var badColor = Style.red
                var resultRed = goodColor.r + percent * (badColor.r - goodColor.r);
                var resultGreen = goodColor.g + percent * (badColor.g - goodColor.g);
                var resultBlue = goodColor.b + percent * (badColor.b - goodColor.b);

                if (selected) {
                    ctx.lineWidth = 2
                    ctx.strokeStyle = Qt.rgba(resultRed, resultGreen, resultBlue, 1)
                } else {
                    ctx.lineWidth = 1
                    var alpha = d.selectedNodeAddress >= 0 ? .2 : 1
                    ctx.strokeStyle = Qt.rgba(resultRed, resultGreen, resultBlue, alpha)
                }
                ctx.beginPath();
                ctx.moveTo(scale * fromNodeItem.x, scale * fromNodeItem.y)
                ctx.lineTo(scale * toNodeItem.x, scale * toNodeItem.y)

                ctx.stroke();

                ctx.closePath()
                ctx.restore();
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    print("clicked:", mouseX, mouseY)
                    var translatedMouseX = mouseX - canvas.width / 2
                    var translatedMouseY = mouseY - canvas.height / 2
                    d.selectedNodeAddress = -1
                    for (var i = 0; i < d.nodeItems.length; i++) {
                        var nodeItem = d.nodeItems[i]
                        //                    print("nodeItem at:", root.scale * nodeItem.x, root.scale * nodeItem.y)
                        if (Math.abs(root.scale * nodeItem.x - translatedMouseX) < (root.scale * root.nodeSize / 2)
                                && Math.abs(root.scale * nodeItem.y - translatedMouseY) < (root.scale * root.nodeSize / 2)) {
                            d.selectedNodeAddress = nodeItem.node.networkAddress;
                            print("sleecting", nodeItem.node.networkAddress)
                        }
                    }

                    canvas.requestPaint();
                }
            }
        }
    }


    BigTile {
        visible: d.selectedNodeAddress >= 0
        anchors {
            top: parent.top
            right: parent.right
            margins: Style.margins
        }

        width: 260
        header: RowLayout {
            width: parent.width - Style.smallMargins
            spacing: Style.smallMargins
            Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                ThingsProxy {
                    id: selectedThingsProxy
                    engine: _engine
                    paramsFilter: {"ieeeAddress": d.selectedNode ? d.selectedNode.ieeeAddress : "---"}
                }

                text: d.selectedNodeAddress < 0
                      ? ""
                      : d.selectedNodeAddress === 0
                        ? Configuration.systemName
                        : selectedThingsProxy.count > 0
                          ? selectedThingsProxy.get(0).name
                          : network.nodes.getNodeByNetworkAddress(d.selectedNode).model
            }
            ColorIcon {
                size: Style.smallIconSize
                name: {
                    if (!d.selectedNodeItem) {
                        return "";
                    }

                    var signalStrength = d.selectedNodeItem.node.lqi * 100 / 255
                    if (signalStrength === 0)
                        return "/ui/images/connections/nm-signal-00.svg"
                    if (signalStrength <= 25)
                        return "/ui/images/connections/nm-signal-25.svg"
                    if (signalStrength <= 50)
                        return "/ui/images/connections/nm-signal-50.svg"
                    if (signalStrength <= 75)
                        return "/ui/images/connections/nm-signal-75.svg"
                    if (signalStrength <= 100)
                        return "/ui/images/connections/nm-signal-100.svg"
                }
            }
            ColorIcon {
                size: Style.smallIconSize
                name: "/ui/images/things.svg"
            }
            ColorIcon {
                size: Style.smallIconSize
                name: "/ui/images/add.svg"
            }
        }

        contentItem: ListView {
            id: tableListView
            spacing: app.margins
            implicitHeight: Math.min(root.height / 4, count * Style.smallIconSize)
            clip: true
            model: d.selectedNode ? d.selectedNode.neighbors.length : 0

            delegate: RowLayout {
                id: neighborTableDelegate
                width: tableListView.width
                property ZigbeeNodeNeighbor neighbor: d.selectedNode.neighbors[index]
                property ZigbeeNode neighborNode: root.network.nodes.getNodeByNetworkAddress(neighbor.networkAddress)
                property Thing neighborNodeThing: {
                    for (var i = 0; i < engine.thingManager.things.count; i++) {
                        var thing = engine.thingManager.things.get(i)
                        var param = thing.paramByName("ieeeAddress")
                        if (param && param.value == neighborNode.ieeeAddress) {
                            return thing
                        }
                    }
                    return null
                }

                Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    font: Style.smallFont
                    text: neighborTableDelegate.neighbor.networkAddress === 0
                          ? Configuration.systemName
                          : neighborTableDelegate.neighborNodeThing
                            ? neighborTableDelegate.neighborNodeThing.name
                            : neighborTableDelegate.neighborNode
                              ? neighborTableDelegate.neighborNode.model
                              : "0x" + neighborTableDelegate.neighbor.networkAddress.toString(16)
                }
                Label {
                    text: (neighborTableDelegate.neighbor.lqi * 100 / 255).toFixed(0) + "%"
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    Layout.preferredWidth: Style.smallIconSize + Style.smallMargins
                    font: Style.smallFont
                    text: neighborTableDelegate.neighbor.depth
                    horizontalAlignment: Text.AlignRight
                }
                ColorIcon {
                    size: Style.smallIconSize
                    name: "add"
                    opacity: neighborTableDelegate.neighbor.permitJoining ? 1 : 0
                }
            }
        }
    }
}
