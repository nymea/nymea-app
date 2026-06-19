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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Nymea
import Nymea.DynamicLoadManager

import "qrc:/ui/components"
import "qrc:/ui/system/dynamicloadmanager"

MainViewBase {
    id: root

    readonly property int nodeWidth: 160
    readonly property int nodeHeight: 84
    readonly property int hGap: Style.bigMargins
    readonly property int vGap: Style.hugeMargins
    readonly property int pad: Style.bigMargins

    readonly property real minZoom: 0.5
    readonly property real maxZoom: 2.0
    property real zoom: 1

    readonly property var layout: computeLayout(dynamicLoadManager.configuration)
    contentY: flickable.contentY + topMargin

    headerButtons: [
        {
            iconSource: "qrc:/icons/configure.svg",
            color: Style.iconColor,
            visible: true,
            trigger: function() {
                pageStack.push(Qt.resolvedUrl("../system/DynamicLoadManagerSettingsPage.qml"));
            }
        }
    ]

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
                "meterThingId": node.meterThingId !== undefined ? node.meterThingId : "",
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
                    var child = visit(children[i], depth + 1, entry.id)
                    if (i === 0)
                        first = child.x
                    if (i === children.length - 1)
                        last = child.x
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
                    "y2": n.y
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

    DynamicLoadManagerManager {
        id: dynamicLoadManager
        engine: _engine
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.bottomMargin: root.bottomMargin
        clip: true
        contentWidth: contentWrapper.width
        contentHeight: contentWrapper.height
        visible: engine.jsonRpcClient.experiences.hasOwnProperty("DynamicLoadManager") && root.layout.nodes.length > 0

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
                        routeVisible: true
                        flowVisible: false
                        bendRatio: 0
                        flowColor: Style.accentColor
                        startPoint: Qt.point(modelData.x1, modelData.y1)
                        endPoint: Qt.point(modelData.x2, modelData.y2)
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
                        nominalVoltage: dynamicLoadManager.configuration && dynamicLoadManager.configuration.nominalVoltage !== undefined ? dynamicLoadManager.configuration.nominalVoltage : 230
                        nodeId: modelData.id
                        // Re-evaluated on every live status update (statusChanged).
                        measuredLoad: {
                            var nodes = dynamicLoadManager.status && dynamicLoadManager.status.nodes ? dynamicLoadManager.status.nodes : null
                            return nodes && nodes[modelData.id] ? nodes[modelData.id].measuredLoad : null
                        }
                        Behavior on x { NumberAnimation { duration: Style.animationDuration } }
                        Behavior on y { NumberAnimation { duration: Style.animationDuration } }
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

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: !engine.jsonRpcClient.experiences.hasOwnProperty("DynamicLoadManager")
        title: qsTr("Dynamic load management plugin not installed.")
        text: qsTr("To show the load topology, install the dynamic load management plugin.")
        imageSource: "qrc:/icons/energy.svg"
        buttonText: qsTr("Install plugin")
        buttonVisible: packagesFilterModel.count > 0
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../system/PackageListPage.qml"), {filter: "nymea-experience-plugin-dynamicloadmanager"})

        PackagesFilterModel {
            id: packagesFilterModel
            packages: engine.systemController.packages
            nameFilter: "nymea-experience-plugin-dynamicloadmanager"
        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        visible: engine.jsonRpcClient.experiences.hasOwnProperty("DynamicLoadManager") && root.layout.nodes.length === 0
        title: qsTr("No load topology configured.")
        text: qsTr("Configure fuses and chargers in the dynamic load management settings.")
        imageSource: "qrc:/icons/energy.svg"
        buttonText: qsTr("Open settings")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("../system/DynamicLoadManagerSettingsPage.qml"))
    }
}
