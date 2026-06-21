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

    function openConfigureNode(node) {
        pageStack.push(Qt.resolvedUrl("ConfigureNodePage.qml"), { "manager": dlm, "node": node })
    }

    function openNodeHistory(node) {
        pageStack.push(Qt.resolvedUrl("NodeHistoryPage.qml"), { "manager": dlm, "node": node })
    }

    function openRemoveConfirm(node) {
        var dialog = removeConfirmDialog.createObject(app, { "node": node })
        dialog.open()
    }

    header: NymeaHeader {
        text: qsTr("Load topology")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/help.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("TopologyHelpPage.qml"))
        }
    }

    DynamicLoadManagerManager {
        id: dlm
        engine: _engine
    }

    Connections {
        target: dlm
        function onAddNodeReply(commandId, error, issues) { root.showError(error, issues) }
        function onUpdateNodeReply(commandId, error, issues) { root.showError(error, issues) }
        function onRemoveNodeReply(commandId, error, issues) { root.showError(error, issues) }
    }

    TopologyGraph {
        id: graph
        anchors.fill: parent
        manager: dlm
        editable: true
        animationsEnabled: root.visible
        onNodeClicked: (node) => root.openNodeActions(node)
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - Style.bigMargins * 2
        spacing: Style.margins
        visible: graph.layout.nodes.length === 0

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
                text: qsTr("Configure")
                onClicked: {
                    root.openConfigureNode(actionsDlg.node)
                    actionsDlg.close()
                }
            }
            Button {
                Layout.fillWidth: true
                text: qsTr("History")
                onClicked: {
                    root.openNodeHistory(actionsDlg.node)
                    actionsDlg.close()
                }
            }
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
