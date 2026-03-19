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

    header: NymeaHeader {
        text: qsTr("Backup settings")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("qrc:/icons/settings.svg")
            onClicked: pageStack.push(backupSettingsComponent)
        }
    }

    busy: engine.transfersManager.busy
    busyText: engine.transfersManager.statusText.length > 0 ? engine.transfersManager.statusText : qsTr("Transferring backup...")

    property string pendingDownloadId: ""
    property string pendingFileName: ""
    property string statusMessage: ""

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
        saveBackupDialog.selectedFileName = ""
    }

    SettingsPageSectionHeader {
        text: qsTr("Backup files")
    }

    Repeater {
        id: backupFilesRepeater
        model: engine.nymeaConfiguration.backupFiles
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            iconName: "qrc:/icons/browser/BrowserIconFile.svg"
            text: model.fileName
            subText: Qt.formatDateTime(model.timestamp, "dd.MM.yyyy hh:mm:ss")
            onClicked: pageStack.push(backupFileDetailsComponent, { backupFile: engine.nymeaConfiguration.backupFiles.get(index) })
        }
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
        defaultSuffix: "tar.gz"
        nameFilters: [qsTr("Backup archives (*.tar.gz)")]
        property string selectedFileName: ""

        currentFolder: {
            var folder = StandardPaths.writableLocation(StandardPaths.DownloadLocation)
            if (!folder || folder.length === 0) {
                folder = StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
            }
            return folder
        }

        onCurrentFolderChanged: {
            if (selectedFileName.length > 0) {
                selectedFile = currentFolder + "/" + selectedFileName
            }
        }

        onSelectedFileChanged: {
            if (!selectedFile || selectedFile.toString().length === 0) {
                return
            }

            var fileName = selectedFile.toString().split("/").pop()
            if (fileName.length > 0) {
                selectedFileName = fileName
            }
        }

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
            saveBackupDialog.selectedFileName = fileName
            saveBackupDialog.selectedFile = saveBackupDialog.currentFolder + "/" + fileName
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

    Component {
        id:  backupSettingsComponent

        SettingsPageBase {
            id: backupSettingsPage
            title: qsTr("Backup settings")
            busy: saving
            busyText: qsTr("Saving backup settings...")

            property bool saving: false
            property string statusMessage: ""

            function syncFromConfiguration() {
                if (saving || backupDestinationDirectoryTextField.activeFocus || backupMaxCountTextField.activeFocus) {
                    return
                }

                backupDestinationDirectoryTextField.text = engine.nymeaConfiguration.backupDestinationDirectory
                backupMaxCountTextField.text = String(engine.nymeaConfiguration.backupMaxCount)
            }

            function currentBackupMaxCount() {
                var value = parseInt(backupMaxCountTextField.text)
                if (isNaN(value)) {
                    return 0
                }

                return value
            }

            function backupSettingsDirty() {
                return backupDestinationDirectoryTextField.text.trim() !== engine.nymeaConfiguration.backupDestinationDirectory
                        || currentBackupMaxCount() !== engine.nymeaConfiguration.backupMaxCount
            }

            Component.onCompleted: syncFromConfiguration()

            SettingsPageSectionHeader {
                text: qsTr("Backup configuration")
            }

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                wrapMode: Text.WordWrap
                text: qsTr("Backup destination directory")
            }

            TextField {
                id: backupDestinationDirectoryTextField
                Layout.fillWidth: true
                Layout.margins: Style.margins
                placeholderText: qsTr("Destination directory")
            }

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                wrapMode: Text.WordWrap
                text: qsTr("Number of backups to keep")
            }

            TextField {
                id: backupMaxCountTextField
                Layout.fillWidth: true
                Layout.margins: Style.margins
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {
                    bottom: 0
                    top: 2147483647
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                wrapMode: Text.WordWrap
                text: qsTr("0 means no max count. All backups will be kept.")
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
                enabled: !saving
                         && backupDestinationDirectoryTextField.text.trim().length > 0
                         && backupMaxCountTextField.acceptableInput
                         && backupSettingsPage.backupSettingsDirty()
                text: qsTr("Apply backup settings")
                onClicked: {
                    statusMessage = ""
                    saving = true
                    engine.nymeaConfiguration.setBackupConfiguration(backupDestinationDirectoryTextField.text.trim(),
                                                                     backupSettingsPage.currentBackupMaxCount())
                }
            }

            Connections {
                target: engine.nymeaConfiguration

                function onBackupDestinationDirectoryChanged() {
                    backupSettingsPage.syncFromConfiguration()
                }

                function onBackupMaxCountChanged() {
                    backupSettingsPage.syncFromConfiguration()
                }

                function onSetBackupConfigurationFinished(commandId, configurationError) {
                    backupSettingsPage.saving = false

                    if (configurationError !== "ConfigurationErrorNoError") {
                        root.openErrorDialog(qsTr("Failed to update the backup settings: %1").arg(configurationError))
                        return
                    }

                    backupSettingsPage.statusMessage = qsTr("Backup settings updated successfully.")
                    backupSettingsPage.syncFromConfiguration()
                }
            }
        }
    }

    Component {
        id:  backupFileDetailsComponent

        SettingsPageBase {
            id: backupFileDetailsPage

            property BackupFile backupFile

            header: NymeaHeader {
                text: qsTr("Backup file")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Name")
                subText: backupFile.fileName
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Size")
                subText: backupFile.size
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Server version")
                subText: backupFile.serverVersion
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Created")
                subText: Qt.formatDateTime(backupFile.timestamp, "dd.MM.yyyy hh:mm:ss")
                progressive: false
                prominentSubText: false
            }
        }
    }
}
