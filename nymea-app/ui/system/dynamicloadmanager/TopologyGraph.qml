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

import Nymea

import "qrc:/ui/components"

// Shared topology renderer used both in the read-only main view and the
// editable settings page. Set `editable` to true to make nodes tappable
// (emitting nodeClicked); leave it false for a pure visualization.
Item {
    id: root

    // The DynamicLoadManagerManager providing configuration and live status.
    property var manager: null
    property bool editable: false
    property bool animationsEnabled: false

    // Exposed so a MainViewBase host can track/scroll the inner flickable.
    property alias contentY: flickable.contentY
    property int contentTopMargin: 0
    property int contentBottomMargin: 0

    signal nodeClicked(var node)

    readonly property int nodeWidth: 160
    readonly property int nodeHeight: 84
    readonly property int hGap: Style.bigMargins
    readonly property int vGap: Style.hugeMargins * 3
    readonly property int pad: Style.bigMargins

    readonly property real minZoom: 0.5
    readonly property real maxZoom: 2.0
    property real zoom: 1

    readonly property real nominalVoltage: manager && manager.configuration && manager.configuration.nominalVoltage !== undefined
                                           ? manager.configuration.nominalVoltage : 230

    // Recomputed whenever the configuration tree changes (live ConfigurationChanged).
    readonly property var layout: computeLayout(manager ? manager.configuration : null)
    onLayoutChanged: Qt.callLater(centerView)

    function computeLayout(config) {
        var result = { "nodes": [], "edges": [], "width": 0, "height": 0 }
        if (!config || !config.root)
            return result

        var nodes = []
        var leaf = { "x": root.pad }
        var maxX = 0
        var maxDepth = 0

        function visit(node, depth, parentId) {
            var children = (node.children !== undefined && node.children !== null) ? node.children : []
            var entry = {
                "id": node.id !== undefined ? node.id : "",
                "nodeType": node.type !== undefined ? node.type : "fuse",
                "displayName": node.displayName !== undefined ? node.displayName : "",
                "limit": (node.fixedLimit && node.fixedLimit.l1 !== undefined) ? node.fixedLimit.l1 : -1,
                "fixedLimit": node.fixedLimit !== undefined ? node.fixedLimit : null,
                "meterThingId": node.meterThingId !== undefined ? node.meterThingId : "",
                "thingId": node.thingId !== undefined ? node.thingId : "",
                "phaseMapping": node.phaseMapping !== undefined ? node.phaseMapping : null,
                "parentId": parentId,
                "y": root.pad + depth * (root.nodeHeight + root.vGap)
            }

            var x
            if (children.length === 0) {
                x = leaf.x
                leaf.x += root.nodeWidth + root.hGap
            } else {
                var first = 0
                var last = 0
                for (var i = 0; i < children.length; i++) {
                    var c = visit(children[i], depth + 1, entry.id)
                    if (i === 0) first = c.x
                    if (i === children.length - 1) last = c.x
                }
                x = (first + last) / 2
            }
            entry.x = x
            maxX = Math.max(maxX, x)
            maxDepth = Math.max(maxDepth, depth)
            nodes.push(entry)
            return entry
        }

        visit(config.root, 0, "")

        var byId = {}
        for (var i = 0; i < nodes.length; i++)
            byId[nodes[i].id] = nodes[i]

        var edges = []
        for (var j = 0; j < nodes.length; j++) {
            var n = nodes[j]
            if (n.parentId !== "" && byId[n.parentId] !== undefined) {
                var p = byId[n.parentId]
                edges.push({
                    "x1": p.x + root.nodeWidth / 2,
                    "y1": p.y + root.nodeHeight,
                    "x2": n.x + root.nodeWidth / 2,
                    "y2": n.y,
                    "nodeId": n.id,
                    "limit": n.limit > 0 ? n.limit : p.limit
                })
            }
        }

        result.nodes = nodes
        result.edges = edges
        result.width = maxX + root.nodeWidth + root.pad
        result.height = root.pad + maxDepth * (root.nodeHeight + root.vGap) + root.nodeHeight + root.pad
        return result
    }

    function centerView() {
        if (flickable.contentWidth > flickable.width)
            flickable.contentX = (flickable.contentWidth - flickable.width) / 2
        if (flickable.contentHeight > flickable.height)
            flickable.contentY = 0
    }

    // Scales the animated grid flow drawn on the tree edges. Each edge carries
    // the load measured at its child node; the node's fuse limit is the maximum
    // used to scale both the line width and the dash velocity.
    QtObject {
        id: d
        readonly property real minFlowWidth: 6
        readonly property real maxFlowWidth: 12
        readonly property real flowBackgroundExtraWidth: 4
        readonly property int minDashDuration: 500
        readonly property int maxDashDuration: 4000
        readonly property int dashLength: 20
        readonly property int dashGap: 20
        readonly property real visibleFlowThreshold: 0.1

        function flowRatio(load, limit) {
            var max = limit > 0 ? limit : 1
            return Math.max(0, Math.min(max, load)) / max
        }
        function flowWidth(load, limit) {
            return minFlowWidth + (maxFlowWidth - minFlowWidth) * Math.sqrt(flowRatio(load, limit))
        }
        function flowBackgroundWidth(load, limit) {
            return flowWidth(load, limit) + flowBackgroundExtraWidth
        }
        // Higher load -> shorter dash cycle -> faster apparent flow.
        function flowDuration(load, limit) {
            return maxDashDuration - (maxDashDuration - minDashDuration) * Math.sqrt(flowRatio(load, limit))
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.topMargin: root.contentTopMargin
        anchors.bottomMargin: root.contentBottomMargin
        clip: true
        contentWidth: contentWrapper.width
        contentHeight: contentWrapper.height

        Item {
            id: contentWrapper
            width: Math.max(treeItem.width * root.zoom, flickable.width)
            height: Math.max(treeItem.height * root.zoom, flickable.height)

            Item {
                id: treeItem
                width: root.layout.width
                height: root.layout.height
                scale: root.zoom
                transformOrigin: Item.TopLeft
                x: Math.max(0, (contentWrapper.width - width * root.zoom) / 2)
                y: Math.max(0, (contentWrapper.height - height * root.zoom) / 2)

                Repeater {
                    model: root.layout.edges
                    delegate: FlowCurve {
                        anchors.fill: parent
                        verticalEase: true
                        routeVisible: true
                        animationsEnabled: root.animationsEnabled
                        flowColor: Style.red
                        startPoint: Qt.point(modelData.x1, modelData.y1)
                        endPoint: Qt.point(modelData.x2, modelData.y2)

                        readonly property var loadTriplet: {
                            var nodes = root.manager && root.manager.status && root.manager.status.nodes ? root.manager.status.nodes : null
                            return nodes && nodes[modelData.nodeId] ? nodes[modelData.nodeId].measuredLoad : null
                        }
                        readonly property real flow: loadTriplet
                            ? Math.max(loadTriplet.l1 || 0, loadTriplet.l2 || 0, loadTriplet.l3 || 0) : 0

                        flowVisible: flow > d.visibleFlowThreshold
                        lineWidth: d.flowWidth(flow, modelData.limit)
                        backgroundLineWidth: d.flowBackgroundWidth(flow, modelData.limit)
                        animationDuration: d.flowDuration(flow, modelData.limit)
                        dashLength: d.dashLength
                        dashGap: d.dashGap
                    }
                }

                Repeater {
                    model: root.layout.nodes
                    delegate: TopologyNode {
                        width: root.nodeWidth
                        height: root.nodeHeight
                        x: modelData.x
                        y: modelData.y
                        nodeType: modelData.nodeType
                        displayName: modelData.displayName
                        limit: modelData.limit
                        nominalVoltage: root.nominalVoltage
                        nodeId: modelData.id
                        // Re-evaluated on every live status update (statusChanged).
                        measuredLoad: {
                            var nodes = root.manager && root.manager.status && root.manager.status.nodes ? root.manager.status.nodes : null
                            return nodes && nodes[modelData.id] ? nodes[modelData.id].measuredLoad : null
                        }
                        Behavior on x { NumberAnimation { duration: Style.animationDuration } }
                        Behavior on y { NumberAnimation { duration: Style.animationDuration } }
                        onClicked: if (root.editable) root.nodeClicked(modelData)
                    }
                }
            }

            WheelHandler {
                acceptedModifiers: Qt.ControlModifier
                onWheel: (event) => {
                    root.zoom = Math.max(root.minZoom, Math.min(root.maxZoom, root.zoom + event.angleDelta.y / 1000))
                }
            }

            PinchHandler {
                target: null
                property real startZoom: 1
                onActiveChanged: if (active) startZoom = root.zoom
                onActiveScaleChanged: if (active)
                    root.zoom = Math.max(root.minZoom, Math.min(root.maxZoom, startZoom * activeScale))
            }
        }
    }
}
