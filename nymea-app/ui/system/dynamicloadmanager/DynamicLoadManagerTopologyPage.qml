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
import Nymea.DynamicLoadManager

import "qrc:/ui/components"

Page {
    id: root

    readonly property int nodeWidth: 160
    readonly property int nodeHeight: 84
    readonly property int hGap: Style.bigMargins
    readonly property int vGap: Style.hugeMargins
    readonly property int pad: Style.bigMargins

    readonly property real minZoom: 0.5
    readonly property real maxZoom: 2.0
    property real zoom: 1

    // Recomputed whenever the configuration tree changes (live ConfigurationChanged).
    readonly property var layout: computeLayout(dlm.configuration)
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

    function errorText(error) {
        switch (error) {
        case DynamicLoadManagerManager.DynamicLoadManagerErrorRevisionConflict:
            return qsTr("The configuration was changed by someone else in the meantime. Please reload and try again.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorInvalidParameter:
            return qsTr("The request contained an invalid parameter.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorValidationFailed:
            return qsTr("The configuration could not be validated.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorPersistenceFailed:
            return qsTr("The configuration could not be saved.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorNodeNotFound:
            return qsTr("The referenced node could not be found.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorInvalidOperation:
            return qsTr("The requested operation is not valid in the current state.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorNotImplemented:
            return qsTr("The requested operation is not implemented.")
        default:
            return qsTr("An unexpected error happened. (Error code: %1)").arg(error)
        }
    }

    function showError(error, issues) {
        if (error === DynamicLoadManagerManager.DynamicLoadManagerErrorNoError)
            return

        var text = root.errorText(error)
        if (issues && issues.length > 0) {
            var lines = []
            for (var i = 0; i < issues.length; i++) {
                var issue = issues[i]
                lines.push(issue.message !== undefined ? issue.message : JSON.stringify(issue))
            }
            text += "\n\n" + lines.join("\n")
        }

        var popup = errorDialog.createObject(app, {text: text})
        popup.open()
    }

    function openAddDialog(parentId) {
        var dialog = addNodeDialog.createObject(app, { "manager": dlm, "parentNodeId": parentId })
        dialog.open()
    }

    function openNodeActions(node) {
        var dialog = nodeActionsDialog.createObject(app, { "node": node })
        dialog.open()
    }

    function openRemoveConfirm(node) {
        var dialog = removeConfirmDialog.createObject(app, { "node": node })
        dialog.open()
    }

    header: NymeaHeader {
        text: qsTr("Load topology")
        onBackPressed: pageStack.pop()
    }

    DynamicLoadManagerManager {
        id: dlm
        engine: _engine
    }

    Connections {
        target: dlm
        function onAddNodeReply(commandId, error, issues) { root.showError(error, issues) }
        function onRemoveNodeReply(commandId, error, issues) { root.showError(error, issues) }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
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
                        meterThingId: modelData.meterThingId
                        Behavior on x { NumberAnimation { duration: Style.animationDuration } }
                        Behavior on y { NumberAnimation { duration: Style.animationDuration } }
                        onClicked: root.openNodeActions(modelData)
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

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - Style.bigMargins * 2
        spacing: Style.margins
        visible: root.layout.nodes.length === 0

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: qsTr("No topology configured yet. Start by adding the root fuse.")
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Add root fuse")
            onClicked: root.openAddDialog("")
        }
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }

    Component {
        id: addNodeDialog
        AddNodeDialog { }
    }

    Component {
        id: nodeActionsDialog
        NymeaDialog {
            id: actionsDlg
            property var node: ({})
            title: node.displayName ? node.displayName : qsTr("Node")
            standardButtons: Dialog.NoButton

            Button {
                Layout.fillWidth: true
                visible: actionsDlg.node.nodeType === "fuse"
                text: qsTr("Add child node")
                onClicked: {
                    root.openAddDialog(actionsDlg.node.id)
                    actionsDlg.close()
                }
            }
            Button {
                Layout.fillWidth: true
                text: qsTr("Remove node")
                onClicked: {
                    root.openRemoveConfirm(actionsDlg.node)
                    actionsDlg.close()
                }
            }
            Button {
                Layout.fillWidth: true
                flat: true
                text: qsTr("Cancel")
                onClicked: actionsDlg.close()
            }
        }
    }

    Component {
        id: removeConfirmDialog
        NymeaDialog {
            id: removeDlg
            property var node: ({})
            headerIcon: "qrc:/icons/dialog-warning-symbolic.svg"
            standardButtons: Dialog.Yes | Dialog.No
            title: qsTr("Remove node")
            text: qsTr("Are you sure you want to remove \"%1\" and all its children?")
                .arg(removeDlg.node.displayName ? removeDlg.node.displayName : "")
            onAccepted: dlm.removeNode(removeDlg.node.id)
        }
    }
}
