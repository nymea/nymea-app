// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import Nymea

import "../components"

SettingsPageBase {
    id: root
    title: qsTr("Backup settings")
    busy: engine.transfersManager.busy
    busyText: engine.transfersManager.statusText.length > 0 ? engine.transfersManager.statusText : qsTr("Transferring backup...")

    property string pendingDownloadId: ""
    property string pendingFileName: ""
    property string statusMessage: ""

    function defaultDownloadFolder() {
        var folder = StandardPaths.writableLocation(StandardPaths.DownloadLocation)
        if (!folder || folder.length === 0) {
            folder = StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        }
        return folder
    }

    function openErrorDialog(message) {
        var component = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
        if (component.status !== Component.Ready) {
            return
        }

        var dialog = component.createObject(root)
        dialog.text = message
        dialog.open()
    }

    function clearPendingDownload() {
        pendingDownloadId = ""
        pendingFileName = ""
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        text: qsTr("Backup directory: %1").arg(engine.nymeaConfiguration.backupDestinationDirectory)
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        text: qsTr("Number of backups to keep: %1").arg(engine.nymeaConfiguration.backupMaxCount)
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: statusMessage.length > 0
        text: statusMessage
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        enabled: !engine.transfersManager.busy
        text: qsTr("Create backup")
        onClicked: {
            statusMessage = ""
            engine.nymeaConfiguration.createBackup()
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        enabled: !engine.transfersManager.busy
        text: qsTr("Create and download backup")
        onClicked: {
            statusMessage = ""
            clearPendingDownload()
            engine.nymeaConfiguration.createAndDownloadBackup()
        }
    }

    FileDialog {
        id: saveBackupDialog
        title: qsTr("Save backup")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("All files (*)")]
        currentFolder: root.defaultDownloadFolder()

        onAccepted: {
            if (!root.pendingDownloadId || root.pendingDownloadId.length === 0) {
                return
            }

            statusMessage = ""
            engine.transfersManager.downloadFile(root.pendingDownloadId, selectedFile)
        }

        onRejected: root.clearPendingDownload()
    }

    Connections {
        target: engine.nymeaConfiguration

        function onCreateBackupFinished(commandId, configurationError) {
            if (configurationError !== "ConfigurationErrorNoError") {
                root.openErrorDialog(qsTr("Failed to create the backup: %1").arg(configurationError))
                return
            }

            root.statusMessage = qsTr("Backup created successfully.")
        }

        function onCreateAndDownloadBackupFinished(commandId, configurationError, downloadId, fileName, size) {
            if (configurationError !== "ConfigurationErrorNoError") {
                root.openErrorDialog(qsTr("Failed to prepare the backup download: %1").arg(configurationError))
                return
            }

            if (!downloadId || downloadId.length === 0) {
                root.openErrorDialog(qsTr("The server did not provide a download for the requested backup."))
                return
            }

            root.pendingDownloadId = downloadId
            root.pendingFileName = fileName
            saveBackupDialog.currentFolder = root.defaultDownloadFolder()
            saveBackupDialog.selectedFile = root.defaultDownloadFolder() + "/" + fileName
            saveBackupDialog.open()
        }
    }

    Connections {
        target: engine.transfersManager

        function onDownloadFinished(downloadId, targetUrl) {
            root.statusMessage = qsTr("Backup saved to %1").arg(targetUrl.toString())
            root.clearPendingDownload()
        }

        function onDownloadFailed(downloadId, errorString) {
            root.clearPendingDownload()
        }

        function onErrorOccurred(errorString) {
            if (!errorString || errorString.length === 0) {
                return
            }

            root.openErrorDialog(errorString)
        }
    }
}
