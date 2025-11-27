// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "qrc:/ui/components"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("ZigBee network map")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        HeaderButton {
            imageSource: "qrc:/icons/help.svg"
            text: qsTr("Help")
            onClicked: {
                var popup = zigbeeHelpDialog.createObject(app)
                popup.open()
            }
        }
    }

    property ZigbeeManager zigbeeManager: null
    property ZigbeeNetwork network: null

    readonly property int nodeDistance: Style.iconSize * 2
    readonly property int nodeSize: Style.iconSize + Style.margins
    property double scale: 1
    readonly property double minScale: 0.5
    readonly property double maxScale: 1.5


    Component.onCompleted: {
        zigbeeManager.refreshNeighborTables(network.networkUuid)

        reload();
        for (var i = 0; i < network.nodes.count; i++) {
            network.nodes.get(i).neighborsChanged.connect(root.reloadDelayed)
        }
    }
    Component.onDestruction: {
        for (var i = 0; i < network.nodes.count; i++) {
            network.nodes.get(i).neighborsChanged.disconnect(root.reloadDelayed)
        }
    }

    Connections {
        target: root.network.nodes
        onNodeAdded: {
            root.reload()
            node.neighborsChanged.connect(root.reloadDelayed);
        }
    }

    function reload() {
        print("Reloading network map")
        generateNodeList();
        generateEdges();
        canvas.requestPaint()
//        print("repainting", flickable.contentX, flickable.contentY)
        if (flickable.contentX == 0 && flickable.contentY == 0) {
            flickable.contentX = (flickable.contentWidth - flickable.width) / 2
            flickable.contentY = (flickable.contentHeight - flickable.height) / 2
        }
    }

    function reloadDelayed() {
        reloadTimer.start()
    }

    Timer {
        id: reloadTimer
        interval: 500
        repeat: false
        running: false
        onTriggered: reload()
    }

    QtObject {
        id: d
        property var nodeItems: ({})
        property var edges: ({})

        property int selectedNodeAddress: -1
        readonly property var selectedNodeItem: nodeItems[selectedNodeAddress]

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
            var minWidth = Math.max(-minX, maxX) * 2 * root.maxScale
            var minHeight = Math.max(-minY, maxY) * 2 * root.maxScale
            size = Math.max(minWidth, minHeight) + root.nodeSize + Style.hugeMargins * 2
        }
    }

    function generateNodeList() {
        var nodeItems = ({})
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

        var routersCircumference = Math.max(5, routers.length) * (root.nodeSize + root.nodeDistance)// * root.scale
        var distanceFromCenter = routersCircumference / 2 / Math.PI

        routers.unshift(coordinator)

        var handledEndDevices = []

        var angle = 360 / routers.length;
        for (var i = 0; i < routers.length; i++) {
            var router = routers[i]
            var nodeAngle = startAngle + angle * i;
            var x = distanceFromCenter * Math.cos(nodeAngle * Math.PI / 180)
            var y = distanceFromCenter * Math.sin(nodeAngle * Math.PI / 180)
            nodeItems[router.networkAddress] = createNodeItem(router, x, y, nodeAngle);


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
                    var neighborDistance = (distanceFromCenter + (root.nodeDistance + root.nodeSize)) + neighborCounter * root.nodeDistance * .5

                    x = neighborDistance * Math.cos(neighborAngle * Math.PI / 180)
                    y = neighborDistance * Math.sin(neighborAngle * Math.PI / 180)
                    nodeItems[neighborNode.networkAddress] = createNodeItem(neighborNode, x, y, angle)

                    neighborCounter++
                }
            }
        }

        var unconnectedNodes = []
        for (var i = 0; i < network.nodes.count; i++) {
            var node = network.nodes.get(i)
            if (node.type == ZigbeeNode.ZigbeeNodeTypeEndDevice && handledEndDevices.indexOf(node.networkAddress) < 0) {
//                print("Adding unconnected node:","0x" + node.networkAddress.toString(16))
                unconnectedNodes.push(node)
            }
        }
        var cellWidth = root.nodeSize * 2
        var cellHeight = root.nodeSize * 2
        var maxColumns = (root.width - Style.bigMargins * 2) / cellWidth
        var columns = Math.min(unconnectedNodes.length, maxColumns)
        var rowWidth = columns * cellWidth
        var rows = Math.floor(unconnectedNodes.length / columns)
        for (var i = 0; i < unconnectedNodes.length; i++) {
            var node = unconnectedNodes[i]
            var column = i % columns;
            var row = Math.floor(i / columns)
            var x = nodeItems[coordinator.networkAddress].x + (column + 0.5) * cellWidth - rowWidth / 2
            var y = nodeItems[coordinator.networkAddress].y - root.nodeSize * (5 + rows) + cellHeight * row
            nodeItems[node.networkAddress] = createNodeItem(node, x, y, 0)
        }

        for (var networkAddress in d.nodeItems) {
            if (!nodeItems.hasOwnProperty(networkAddress)) {
                d.nodeItems[networkAddress].image.destroy();
            }
        }

        d.nodeItems = nodeItems
    }

    function createNodeItem(node, x, y, angle) {
        d.adjustSize(x, y)

        if (d.nodeItems.hasOwnProperty(node.networkAddress)) {
            d.nodeItems[node.networkAddress].x = x;
            d.nodeItems[node.networkAddress].y = y;
            d.nodeItems[node.networkAddress].image.x = Qt.binding(function() { return x * root.scale + (canvas.width - Style.iconSize * root.scale) / 2});
            d.nodeItems[node.networkAddress].image.y = Qt.binding(function() { return y * root.scale + (canvas.height - Style.iconSize * root.scale) / 2});

            d.nodeItems[node.networkAddress].angle = angle;
            return d.nodeItems[node.networkAddress]
        }

        var icon = "qrc:/icons/zigbee.svg"
        var thing = null
        if (node.networkAddress === 0) {
            icon = "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        } else {
            for (var i = 0; i < engine.thingManager.things.count; i++) {
                var t = engine.thingManager.things.get(i)
                //                print("checking thing", t.name)
                var param = t.paramByName("ieeeAddress")
                if (param && param.value === node.ieeeAddress) {
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
                                                   x: Qt.binding(function() { return x * root.scale + (canvas.width - Style.iconSize * root.scale) / 2}),
                                                   y: Qt.binding(function() { return y * root.scale + (canvas.height - Style.iconSize * root.scale) / 2}),
                                                   size: Qt.binding(function() {return Style.iconSize * root.scale}),
                                                   name: icon,
                                                   color: Style.accentColor
                                               }),
            thing: thing

        }
        return nodeItem
    }

    function generateEdges() {
        var edges = ({})
        for (var networkAddress in d.nodeItems) {
            var fromNodeItem = d.nodeItems[networkAddress]
            var fromAddress = fromNodeItem.node.networkAddress
            for (var i = 0; i < fromNodeItem.node.neighbors.length; i++) {
                var neighbor = fromNodeItem.node.neighbors[i]
//                print("have neighbor", neighbor.networkAddress)
                var toAddress = neighbor.networkAddress
                if (!d.nodeItems.hasOwnProperty(toAddress)) {
                    continue;
                }
                var toNodeItem = d.nodeItems[toAddress]

                var edgeKey = fromAddress < toAddress ? fromAddress + "+" + toAddress : toAddress + "+" + fromAddress;
                if (edges.hasOwnProperty(edgeKey)) {
                    continue;
                }

                var fromLqi = neighbor.lqi
                var toLqi = fromLqi
                for (var j = 0; j < toNodeItem.node.neighbors.length; j++) {
                    if (toNodeItem.node.neighbors[j].networkAddress === fromAddress) {
                        toLqi = toNodeItem.node.neighbors[j].lqi
                        break;
                    }
                }

                edges[edgeKey] = {
                    fromNodeItem: fromNodeItem,
                    toNodeItem: toNodeItem,
                    fromLqi: fromLqi,
                    toLqi: toLqi
                }
            }
        }
        d.edges = edges
    }

    Component {
        id: imageComponent
        ColorIcon {
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true

        contentWidth: canvas.width
        contentHeight: canvas.height

        Canvas {
            id: canvas
            width: Math.max(d.size, flickable.width)
            height: Math.max(d.size, flickable.height)
            clip: true

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var center = { x: canvas.width / 2, y: canvas.height / 2 };
                ctx.translate(center.x, center.y)

                paintNodeList(ctx);
            }

            function paintNodeList(ctx) {
                for (var edgeKey in d.edges) {
                    paintEdge(ctx, d.edges[edgeKey], false)
                }

                if (d.selectedNodeItem) {
                    paintRoutes(ctx, d.selectedNodeItem)
                }
                for (var networkAddress in d.nodeItems) {
                    paintNode(ctx, d.nodeItems[networkAddress])
                }
            }

            function paintRoutes(ctx, nodeItem) {
                var node = nodeItem.node
                var nextHop = -1
                if (node.type === ZigbeeNode.ZigbeeNodeTypeRouter) {
                    for (var i = 0; i < node.routes.length; i++) {
                        if (node.routes[i].destinationAddress === 0) {
                            nextHop = node.routes[i].nextHopAddress
                            paintRoute(ctx, nodeItem, nextHop);
                        }
                    }
                } else if (node.type === ZigbeeNode.ZigbeeNodeTypeEndDevice) {
                    for (var i = 0; i < network.nodes.count; i++) {
                        for (var j = 0; j < network.nodes.get(i).neighbors.length; j++) {
                            if (network.nodes.get(i).neighbors[j].networkAddress === node.networkAddress) {
                                nextHop = network.nodes.get(i).networkAddress
                                paintRoute(ctx, nodeItem, nextHop);
                            }
                        }
                    }
                }
            }

            function paintRoute(ctx, fromNodeItem, nextHopAddress) {
                if (!d.nodeItems.hasOwnProperty(nextHopAddress)) {
                    return;
                }
                var toNodeItem = d.nodeItems[nextHopAddress]
                var fromAddress = fromNodeItem.node.networkAddress

                var edgeKey = fromAddress < nextHopAddress ? fromAddress + "+" + nextHopAddress : nextHopAddress + "+" + fromAddress
                paintEdge(ctx, d.edges[edgeKey], true)

                paintRoutes(ctx, toNodeItem)

            }

            function paintNode(ctx, nodeItem) {
                ctx.save()
                ctx.beginPath();
                ctx.fillStyle = nodeItem.node.networkAddress === d.selectedNodeAddress ? Style.tileOverlayColor : Style.tileBackgroundColor
                ctx.strokeStyle = nodeItem.node.networkAddress === d.selectedNodeAddress ? Style.accentColor : Style.tileBackgroundColor
                ctx.arc(nodeItem.x * root.scale, nodeItem.y * root.scale, root.scale * root.nodeSize / 2, 0, 2 * Math.PI);
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
                ctx.fillText(text, nodeItem.x * root.scale - (textSize.width / 2), nodeItem.y * root.scale + (root.scale * root.nodeSize / 2 + Style.extraSmallFont.pixelSize))

                ctx.closePath();

                ctx.restore();
            }

            function paintEdge(ctx, edge, forceSelection) {
                ctx.save();
                var haveSelection = d.selectedNodeItem !== undefined
                var fromSelected = edge.fromNodeItem === d.selectedNodeItem
                var toSelected = edge.toNodeItem === d.selectedNodeItem
                var fromPercent = 1.0 * edge.fromLqi / 255;
                var fromColor = Qt.rgba(
                            Style.red.r + fromPercent * (Style.green.r - Style.red.r),
                            Style.red.g + fromPercent * (Style.green.g - Style.red.g),
                            Style.red.b + fromPercent * (Style.green.b - Style.red.b),
                            haveSelection && !fromSelected && !forceSelection ? .2 : 1
                            )
                var toPercent = 1.0 * edge.toLqi / 255;
                var toColor = Qt.rgba(
                            Style.red.r + toPercent * (Style.green.r - Style.red.r),
                            Style.red.g + toPercent * (Style.green.g - Style.red.g),
                            Style.red.b + toPercent * (Style.green.b - Style.red.b),
                            haveSelection && !toSelected && !forceSelection ? .2 : 1
                            )
                var fromX = root.scale * edge.fromNodeItem.x
                var fromY = root.scale * edge.fromNodeItem.y
                var toX = root.scale * edge.toNodeItem.x
                var toY = root.scale * edge.toNodeItem.y

                var gradient = ctx.createLinearGradient(fromX, fromY, toX, toY);
                gradient.addColorStop(0, fromColor);
                gradient.addColorStop(1, toColor)
                ctx.lineWidth = forceSelection ? 3 : fromSelected || toSelected ? 2 : 1
                ctx.strokeStyle = gradient;
                ctx.beginPath();
                ctx.moveTo(fromX, fromY)
                ctx.lineTo(toX, toY)
                ctx.stroke();
                ctx.closePath()

                ctx.restore();
            }


            PinchArea {
                anchors.fill: parent
                property double startScale: 0
                onPinchStarted: {
                    startScale = root.scale
                    print("pinch started", startScale)
                }

                onPinchUpdated: {
                    print("pinch updated:", pinch.scale)
                    var scaleDiff = pinch.scale - 1
                    root.scale = Math.min(root.maxScale, Math.max(root.minScale, startScale + scaleDiff))
                    root.reload()
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        print("clicked:", mouseX, mouseY)
                        var translatedMouseX = (mouseX - canvas.width / 2)
                        var translatedMouseY = (mouseY - canvas.height / 2)
                        d.selectedNodeAddress = -1
                        for (var networkAddress in d.nodeItems) {
                            var nodeItem = d.nodeItems[networkAddress]
    //                        print("nodeItem at:", root.scale * nodeItem.x, root.scale * nodeItem.y)
                            if (Math.abs(nodeItem.x * root.scale - translatedMouseX) < (root.scale * root.nodeSize / 2)
                                    && Math.abs(nodeItem.y * root.scale - translatedMouseY) < (root.scale * root.nodeSize / 2)) {
                                d.selectedNodeAddress = nodeItem.node.networkAddress;
                                print("selecting", nodeItem.node.networkAddress)
                                for (var j = 0; j < nodeItem.node.routes.length; j++) {
                                    var route = nodeItem.node.routes[j]
                                    print("route:", route.destinationAddress, "via", route.nextHopAddress)
                                }
                            }
                        }

                        canvas.requestPaint();
                    }

                    onWheel: (wheel) => {
                        if (wheel.modifiers & Qt.ControlModifier) {
                            root.scale = Math.min(root.maxScale, Math.max(root.minScale, root.scale + 1.0 * wheel.angleDelta.y / 1000))
                            root.reload()
                        } else {
                            wheel.accepted = false
                        }
                    }
                }
            }

        }
    }


    BigTile {
        id: infoTile
        visible: d.selectedNodeAddress >= 0
        property point selectedNodeItemPos: d.selectedNodeItem ? Qt.point(d.selectedNodeItem.x + flickable.contentWidth / 2 - flickable.contentX, d.selectedNodeItem.y + flickable.contentHeight / 2 - flickable.contentY) : Qt.point(0,0)
        onSelectedNodeItemPosChanged: print("selected point:", selectedNodeItemPos, flickable.contentX)
        x: selectedNodeItemPos.x < flickable.width / 2 ? flickable.width - width - Style.smallMargins : Style.smallMargins
        y: selectedNodeItemPos.y < flickable.height / 2 ? flickable.height - height- Style.smallMargins : Style.smallMargins
        Behavior on x { NumberAnimation { duration: Style.fastAnimationDuration; easing.type: Easing.InOutQuad } }
        Behavior on y { NumberAnimation { duration: Style.fastAnimationDuration; easing.type: Easing.InOutQuad } }

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
                    if (!d.selectedNode) {
                        return "";
                    }

                    var signalStrength = 100.0 * d.selectedNode.lqi / 255
                    if (!d.selectedNode.reachable)
                        return "qrc:/icons/connections/nm-signal-00.svg"
                    if (signalStrength <= 25)
                        return "qrc:/icons/connections/nm-signal-25.svg"
                    if (signalStrength <= 50)
                        return "qrc:/icons/connections/nm-signal-50.svg"
                    if (signalStrength <= 75)
                        return "qrc:/icons/connections/nm-signal-75.svg"
                    if (signalStrength <= 100)
                        return "qrc:/icons/connections/nm-signal-100.svg"
                }
            }
        }

        contentItem: ColumnLayout {
            width: infoTile.width
            SelectionTabs {
                id: infoSelectionTabs
                Layout.fillWidth: true
                color: Style.tileOverlayColor
                selectionColor: Qt.tint(Style.tileOverlayColor, Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.1))
                model: ListModel {
                    ListElement {
                        text: qsTr("Device")
                    }
                    ListElement {
                        text: qsTr("Links")
                    }
                    ListElement {
                        text: qsTr("Routes")
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                visible: infoSelectionTabs.currentIndex == 0
                columns: 2
                columnSpacing: Style.smallMargins

                Label {
                    text: qsTr("Address:")
                    font: Style.smallFont
                    Layout.fillWidth: true
                }
                Label {
                    text: d.selectedNode ? "0x" + d.selectedNode.networkAddress.toString(16) : ""
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Model:")
                    font: Style.smallFont
                    Layout.fillWidth: true
                }
                Label {
                    text: d.selectedNode ? d.selectedNode.model : ""
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: qsTr("Manufacturer:")
                    font: Style.smallFont
                    Layout.fillWidth: true
                }
                Label {
                    text: d.selectedNode ? d.selectedNode.manufacturer : ""
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: qsTr("Last seen:")
                    font: Style.smallFont
                    Layout.fillWidth: true
                }
                Label {
                    text: d.selectedNode ? d.selectedNode.lastSeen.toLocaleString(Qt.locale(), Locale.ShortFormat) : ""
                    font: Style.smallFont
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                visible: infoSelectionTabs.currentIndex == 1
                RowLayout {
                    Label {
                        text: qsTr("Neighbor")
                        font: Style.smallFont
                        Layout.fillWidth: true
                    }
                    ColorIcon {
                        size: Style.smallIconSize
                        name: "connections/nm-signal-50"
                    }
                    ColorIcon {
                        size: Style.smallIconSize
                        name: "zigbee/zigbee-coordinator"
                    }
                    Item {
                        Layout.preferredWidth: Style.smallIconSize + Style.smallMargins
                        Layout.fillHeight: true
                        ColorIcon {
                            anchors.centerIn: parent
                            size: Style.smallIconSize
                            name: "arrow-down"
                        }
                    }

                    ColorIcon {
                        size: Style.smallIconSize
                        name: "add"
                    }
                }
                ThinDivider {
                    color: Style.foregroundColor
                }

                ListView {
                    id: neighborTableListView
                    Layout.fillWidth: true
//                    spacing: app.margins
                    implicitHeight: Math.min(root.height / 4, count * Style.smallIconSize)
                    clip: true
                    model: d.selectedNode ? d.selectedNode.neighbors.length : 0

                    delegate: RowLayout {
                        id: neighborTableDelegate
                        width: neighborTableListView.width
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
                            color: neighborTableDelegate.neighborNode ? Style.foregroundColor : Style.red
                        }
                        Label {
                            text: (neighborTableDelegate.neighbor.lqi * 100 / 255).toFixed(0) + "%"
                            font: Style.smallFont
                            horizontalAlignment: Text.AlignRight
                        }
                        ColorIcon {
                            size: Style.smallIconSize
                            name: {
                                switch (neighborTableDelegate.neighbor.relationship) {
                                case ZigbeeNode.ZigbeeNodeRelationshipChild:
                                    return "zigbee/zigbee-child"
                                case ZigbeeNode.ZigbeeNodeRelationshipParent:
                                    return "zigbee/zigbee-parent"
                                case ZigbeeNode.ZigbeeNodeRelationshipSibling:
                                    return "zigbee/zigbee-sibling"
                                case ZigbeeNode.ZigbeeNodeRelationshipPreviousChild:
                                    return "zigbee/zigbee-previous-child"
                                }
                                return ""
                            }
                        }

                        Label {
                            Layout.preferredWidth: Style.smallIconSize + Style.smallMargins
                            font: Style.smallFont
                            text: neighborTableDelegate.neighbor.depth
                            horizontalAlignment: Text.AlignRight
                        }
                        Item {
                            Layout.preferredWidth: Style.smallIconSize
                            Layout.preferredHeight: Style.smallIconSize

                            Led {
                                anchors.fill: parent
                                anchors.margins: Style.smallIconSize / 4
                                state: neighborTableDelegate.neighbor.permitJoining ? "on" : "off"
                            }
                        }

                    }
                }

            }
            ColumnLayout {
                visible: infoSelectionTabs.currentIndex == 2
                RowLayout {
                    Label {
                        id: toLabel
                        text: qsTr("To")
                        font: Style.smallFont
                        Layout.fillWidth: true
                    }
                    Label {
                        id: viaLabel
                        text: qsTr("Via")
                        font: Style.smallFont
                        Layout.fillWidth: true
                    }
                    ColorIcon {
                        size: Style.smallIconSize
                        name: "transfer-progress"
                    }
                }
                ThinDivider {
                    color: Style.foregroundColor
                }
                ListView {
                    id: routesListView
                    Layout.fillWidth: true
                    implicitHeight: Math.min(root.height / 4, count * Style.smallIconSize)
                    clip: true
                    model: d.selectedNode ? d.selectedNode.routes.length : 0

                    delegate: RowLayout {
                        id: routesTableDelegate
                        width: routesListView.width
                        property ZigbeeNodeRoute route: d.selectedNode.routes[index]
                        property ZigbeeNode destinationNode: root.network.nodes.getNodeByNetworkAddress(route.destinationAddress)
                        property Thing destinationNodeThing: {
                            for (var i = 0; i < engine.thingManager.things.count; i++) {
                                var thing = engine.thingManager.things.get(i)
                                var param = thing.paramByName("ieeeAddress")
                                if (param && param.value == destinationNode.ieeeAddress) {
                                    return thing
                                }
                            }
                            return null
                        }
                        property ZigbeeNode nextHopNode: root.network.nodes.getNodeByNetworkAddress(route.nextHopAddress)
                        property Thing nextHopNodeThing: {
                            if (!nextHopNode) {
                                return null
                            }

                            for (var i = 0; i < engine.thingManager.things.count; i++) {
                                var thing = engine.thingManager.things.get(i)
                                var param = thing.paramByName("ieeeAddress")
                                if (param && param.value === nextHopNode.ieeeAddress) {
                                    return thing
                                }
                            }
                            return null
                        }

                        Label {
                            Layout.preferredWidth: toLabel.width
                            elide: Text.ElideRight
                            font: Style.smallFont
                            text: routesTableDelegate.route.destinationAddress === 0
                                  ? Configuration.systemName
                                  : routesTableDelegate.destinationNodeThing
                                    ? routesTableDelegate.destinationNodeThing.name
                                    : routesTableDelegate.destinationNode
                                      ? routesTableDelegate.destinationNode.model
                                      : "0x" + routesTableDelegate.route.destinationAddress.toString(16)
                        }
                        Label {
                            Layout.preferredWidth: viaLabel.width
                            elide: Text.ElideRight
                            font: Style.smallFont
                            text: routesTableDelegate.route.nextHopAddress === 0
                                  ? Configuration.systemName
                                  : routesTableDelegate.nextHopNodeThing
                                    ? routesTableDelegate.nextHopNodeThing.name
                                    : routesTableDelegate.nextHopNode
                                      ? routesTableDelegate.nextHopNode.model
                                      : "0x" + routesTableDelegate.route.nextHopAddress.toString(16)
                        }
                        ColorIcon {
                            name: {
                                switch (routesTableDelegate.route.status) {
                                case ZigbeeNode.ZigbeeNodeRouteStatusActive:
                                    return "tick"
                                case ZigbeeNode.ZigbeeNodeRouteStatusDiscoveryFailed:
                                    return "dialog-error-symbolic"
                                case ZigbeeNode.ZigbeeNodeRouteStatusDiscoveryUnderway:
                                    return "find"
                                case ZigbeeNode.ZigbeeNodeRouteStatusInactive:
                                    return "dialog-warning-symbolic"
                                case ZigbeeNode.ZigbeeNodeRouteStatusValidationUnderway:
                                    return "system-update"
                                }
                            }
                            size: Style.smallIconSize
                            color: routesTableDelegate.route.memoryConstrained ? Style.orange : Style.foregroundColor
                        }
                    }
                }
            }
        }
    }

    Component {
        id: zigbeeHelpDialog

        NymeaDialog {
            id: dialog
            title: qsTr("ZigBee topology help")

            Flickable {
                implicitHeight: helpColumn.implicitHeight
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: helpColumn.implicitHeight
                clip: true

                ColumnLayout {
                    id: helpColumn
                    width: parent.width

                    ListSectionHeader {
                        text: qsTr("Links")
                    }


                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            size: Style.iconSize
                            name: "zigbee/zigbee-coordinator"
                        }

                        Label {
                            text: qsTr("Node relationship")
                        }
                    }

                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "zigbee/zigbee-sibling"
                        }

                        Label {
                            text: qsTr("Sibling")
                        }
                    }
                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "zigbee/zigbee-parent"
                        }

                        Label {
                            text: qsTr("Parent")
                        }
                    }
                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "zigbee/zigbee-child"
                        }

                        Label {
                            text: qsTr("Child")
                        }
                    }

                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "zigbee/zigbee-previous-child"
                        }

                        Label {
                            text: qsTr("Previous child")
                        }
                    }

                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "qrc:/icons/arrow-down.svg"
                        }

                        Label {
                            text: qsTr("Depth in network")
                        }
                    }
                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "add"
                        }

                        Label {
                            text: qsTr("Permit join")
                        }
                    }

                    ListSectionHeader {
                        text: qsTr("Routes")
                    }

                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "transfer-progress"
                        }

                        Label {
                            text: qsTr("Route status")
                        }
                    }

                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "tick"
                        }

                        Label {
                            text: qsTr("Route active")
                        }
                    }
                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "dialog-warning-symbolic"
                        }

                        Label {
                            text: qsTr("Route inactive")
                        }
                    }
                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "dialog-error-symbolic"
                        }

                        Label {
                            text: qsTr("Route failed")
                        }
                    }
                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "find"
                        }

                        Label {
                            text: qsTr("Discovery in progress")
                        }
                    }
                    RowLayout {
                        spacing: Style.margins
                        ColorIcon {
                            Layout.preferredHeight: Style.iconSize
                            Layout.preferredWidth: Style.iconSize
                            name: "system-update"
                        }

                        Label {
                            text: qsTr("Validation in progress")
                        }
                    }
                }
            }
        }
    }
}
