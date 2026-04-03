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
import NymeaApp.Utils

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

    busy: engine.transfersManager.busy || d.pendingCommandId !== -1
    busyText: d.pendingCommandId !== -1
              ? qsTr("Creating backup...")
              : engine.transfersManager.statusText.length > 0 ? engine.transfersManager.statusText : qsTr("Transferring backup...")

    property string pendingDownloadId: ""
    property string pendingFileName: ""
    property url pendingRestoreSourceUrl: ""
    property string pendingRestoreFileName: ""
    property bool restoringUploadedBackup: false
    property string statusMessage: ""

    QtObject {
        id: d
        property int pendingCommandId: -1
    }

    function openErrorDialog(message) {
        var component = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
        if (component.status !== Component.Ready)
            return

        var dialog = component.createObject(root)
        dialog.text = message
        dialog.open()
    }

    function clearPendingDownload() {
        pendingDownloadId = ""
        pendingFileName = ""
        saveBackupDialog.selectedFileName = ""
    }

    function clearPendingRestoreUpload() {
        pendingRestoreSourceUrl = ""
        pendingRestoreFileName = ""
    }

    function prepareBackupDownload(downloadId, fileName, errorMessage) {
        if (!downloadId || downloadId.length === 0) {
            root.openErrorDialog(errorMessage)
            return
        }

        root.pendingDownloadId = downloadId
        root.pendingFileName = fileName
        saveBackupDialog.selectedFileName = fileName
        saveBackupDialog.selectedFile = saveBackupDialog.currentFolder + "/" + fileName
        saveBackupDialog.open()
    }

    function transferProgressText() {
        if (!engine.transfersManager.busy || engine.transfersManager.totalBytes <= 0) {
            return ""
        }

        return qsTr("%1 of %2").arg(NymeaUtils.formatFileSize(engine.transfersManager.bytesTransferred))
                              .arg(NymeaUtils.formatFileSize(engine.transfersManager.totalBytes))
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: engine.transfersManager.busy
        text: engine.transfersManager.statusText
    }

    ProgressBar {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        visible: engine.transfersManager.busy
        from: 0
        to: 1
        value: engine.transfersManager.progress
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        visible: engine.transfersManager.busy && text.length > 0
        text: root.transferProgressText()
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
            subText: Qt.formatDateTime(model.timestamp, "dd.MM.yyyy hh:mm:ss") + " | " + NymeaUtils.formatFileSize(model.size)
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
        enabled: !engine.transfersManager.busy && d.pendingCommandId === -1
        text: qsTr("Create backup")
        icon.source: "qrc:/icons/backup.svg"
        onClicked: {
            statusMessage = ""
            d.pendingCommandId = engine.nymeaConfiguration.createBackup()
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        enabled: !engine.transfersManager.busy && d.pendingCommandId === -1
        text: qsTr("Create and download backup")
        icon.source: "qrc:/icons/download.svg"
        onClicked: {
            statusMessage = ""
            clearPendingDownload()
            d.pendingCommandId = engine.nymeaConfiguration.createAndDownloadBackup()
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        enabled: !engine.transfersManager.busy && d.pendingCommandId === -1
        text: qsTr("Upload and restore backup")
        icon.source: "qrc:/icons/upload.svg"
        onClicked: {
            statusMessage = ""
            clearPendingRestoreUpload()
            selectRestoreBackupDialog.open()
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
            if (!folder || folder.length === 0)
                folder = StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

            return folder
        }

        onCurrentFolderChanged: {
            if (selectedFileName.length > 0) {
                selectedFile = currentFolder + "/" + selectedFileName
            }
        }

        onSelectedFileChanged: {
            if (!selectedFile || selectedFile.toString().length === 0)
                return

            var fileName = selectedFile.toString().split("/").pop()
            if (fileName.length > 0)
                selectedFileName = fileName

        }

        onAccepted: {
            if (!root.pendingDownloadId || root.pendingDownloadId.length === 0)
                return

            statusMessage = ""
            engine.transfersManager.downloadFile(root.pendingDownloadId, selectedFile)
        }

        onRejected: root.clearPendingDownload()
    }

    FileDialog {
        id: selectRestoreBackupDialog
        title: qsTr("Select backup file")
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Backup archives (*.tar.gz)")]

        currentFolder: {
            var folder = StandardPaths.writableLocation(StandardPaths.DownloadLocation)
            if (!folder || folder.length === 0) {
                folder = StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
            }
            return folder
        }

        onAccepted: {
            if (!selectedFile || selectedFile.toString().length === 0) {
                return
            }

            root.pendingRestoreSourceUrl = selectedFile
            root.pendingRestoreFileName = selectedFile.toString().split("/").pop()

            var dialog = uploadRestoreBackupDialogComponent.createObject(root, { fileName: root.pendingRestoreFileName })
            dialog.open()
        }

        onRejected: root.clearPendingRestoreUpload()
    }

    Connections {
        target: engine.nymeaConfiguration

        function onCreateBackupFinished(commandId, configurationError) {
            if (commandId !== d.pendingCommandId) {
                return
            }

            d.pendingCommandId = -1

            if (configurationError !== "ConfigurationErrorNoError") {
                root.openErrorDialog(qsTr("Failed to create the backup: %1").arg(configurationError))
                return
            }

            root.statusMessage = qsTr("Backup created successfully.")
        }

        function onCreateAndDownloadBackupFinished(commandId, configurationError, downloadId, fileName, size) {
            if (commandId !== d.pendingCommandId) {
                return
            }

            d.pendingCommandId = -1

            if (configurationError !== "ConfigurationErrorNoError") {
                root.openErrorDialog(qsTr("Failed to prepare the backup download: %1").arg(configurationError))
                return
            }

            root.prepareBackupDownload(downloadId, fileName, qsTr("The server did not provide a download for the requested backup."))
        }

        function onDownloadBackupFileFinished(commandId, configurationError, downloadId, fileName, size) {
            if (configurationError !== "ConfigurationErrorNoError") {
                root.openErrorDialog(qsTr("Failed to prepare the backup file download: %1").arg(configurationError))
                return
            }

            root.prepareBackupDownload(downloadId, fileName, qsTr("The server did not provide a download for the selected backup file."))
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

        function onUploadFinished(downloadId, fileName, size) {
            if (!root.restoringUploadedBackup) {
                return
            }

            root.restoringUploadedBackup = false
            root.clearPendingRestoreUpload()
            root.statusMessage = qsTr("Backup uploaded. The server is restoring it and will reboot once finished.")
        }

        function onUploadFailed(fileName, errorString) {
            if (!root.restoringUploadedBackup) {
                return
            }

            root.restoringUploadedBackup = false
            root.clearPendingRestoreUpload()
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
            property var autoBackupIntervalValues: [24, 48, 168, 720, -1]
            property var autoBackupIntervalLabels: [
                qsTr("1 Day"),
                qsTr("2 Days"),
                qsTr("Weekly"),
                qsTr("Once a month"),
                qsTr("Custom")
            ]

            function customAutoBackupIntervalIndex() {
                return autoBackupIntervalValues.length - 1
            }

            function syncFromConfiguration() {
                if (saving || backupDestinationDirectoryTextField.activeFocus || backupMaxCountTextField.activeFocus || customAutoBackupIntervalTextField.activeFocus) {
                    return
                }

                backupDestinationDirectoryTextField.text = engine.nymeaConfiguration.backupDestinationDirectory
                backupMaxCountTextField.text = String(engine.nymeaConfiguration.backupMaxCount)
                autoBackupEnabledSwitch.checked = engine.nymeaConfiguration.autoBackupEnabled

                var interval = engine.nymeaConfiguration.autoBackupInterval
                var intervalIndex = autoBackupIntervalValues.indexOf(interval)
                if (intervalIndex >= 0) {
                    autoBackupIntervalComboBox.currentIndex = intervalIndex
                    customAutoBackupIntervalTextField.text = ""
                } else {
                    autoBackupIntervalComboBox.currentIndex = customAutoBackupIntervalIndex()
                    customAutoBackupIntervalTextField.text = String(interval)
                }
            }

            function currentBackupMaxCount() {
                var value = parseInt(backupMaxCountTextField.text)
                if (isNaN(value)) {
                    return 0
                }

                return value
            }

            function autoBackupIntervalIsCustom() {
                return autoBackupIntervalComboBox.currentIndex === customAutoBackupIntervalIndex()
            }

            function currentAutoBackupInterval() {
                if (!autoBackupIntervalIsCustom()) {
                    return autoBackupIntervalValues[autoBackupIntervalComboBox.currentIndex]
                }

                var value = parseInt(customAutoBackupIntervalTextField.text)
                if (isNaN(value)) {
                    return 0
                }

                return value
            }

            function backupSettingsDirty() {
                return backupDestinationDirectoryTextField.text.trim() !== engine.nymeaConfiguration.backupDestinationDirectory
                        || currentBackupMaxCount() !== engine.nymeaConfiguration.backupMaxCount
                        || autoBackupEnabledSwitch.checked !== engine.nymeaConfiguration.autoBackupEnabled
                        || currentAutoBackupInterval() !== engine.nymeaConfiguration.autoBackupInterval
            }

            Component.onCompleted: syncFromConfiguration()

            SettingsPageSectionHeader {
                text: qsTr("Backup configuration")
            }

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                wrapMode: Text.WordWrap
                text: qsTr("Backup destination directory on the server")
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
                text: qsTr("Number of backups to keep (Select 0 to keep all backups)")
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

            SwitchDelegate {
                id: autoBackupEnabledSwitch
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("Automatic backups")
            }

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                visible: autoBackupEnabledSwitch.checked
                wrapMode: Text.WordWrap
                text: qsTr("Automatic backup interval")
            }

            ComboBox {
                id: autoBackupIntervalComboBox
                Layout.fillWidth: true
                Layout.margins: Style.margins
                visible: autoBackupEnabledSwitch.checked
                model: backupSettingsPage.autoBackupIntervalLabels
            }

            // Label {
            //     Layout.fillWidth: true
            //     Layout.margins: Style.margins
            //     visible: autoBackupEnabledSwitch.checked && backupSettingsPage.autoBackupIntervalIsCustom()
            //     wrapMode: Text.WordWrap
            //     text: qsTr("Custom interval in hours")
            // }

            TextField {
                id: customAutoBackupIntervalTextField
                Layout.fillWidth: true
                Layout.margins: Style.margins
                visible: autoBackupEnabledSwitch.checked && backupSettingsPage.autoBackupIntervalIsCustom()
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {
                    bottom: 1
                    top: 2147483647
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
                text: qsTr("Apply backup settings")
                icon.source: "qrc:/icons/save.svg"

                enabled: !saving
                         && backupDestinationDirectoryTextField.text.trim().length > 0
                         && backupMaxCountTextField.acceptableInput
                         && (!backupSettingsPage.autoBackupIntervalIsCustom() || customAutoBackupIntervalTextField.acceptableInput)
                         && backupSettingsPage.backupSettingsDirty()

                onClicked: {
                    statusMessage = ""
                    saving = true
                    engine.nymeaConfiguration.setBackupConfiguration(backupDestinationDirectoryTextField.text.trim(),
                                                                     backupSettingsPage.currentBackupMaxCount(),
                                                                     autoBackupEnabledSwitch.checked,
                                                                     backupSettingsPage.currentAutoBackupInterval())
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

                function onAutoBackupEnabledChanged() {
                    backupSettingsPage.syncFromConfiguration()
                }

                function onAutoBackupIntervalChanged() {
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
            objectName: "backupFileDetailsPage"

            property BackupFile backupFile
            property bool deleting: false
            property bool restoring: false

            busy: deleting || restoring
            busyText: deleting ? qsTr("Deleting backup file...") : qsTr("Restoring backup file...")

            header: NymeaHeader {
                text: qsTr("Backup file")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                wrapMode: Text.WordWrap
                visible: engine.transfersManager.busy
                text: engine.transfersManager.statusText
            }

            ProgressBar {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                visible: engine.transfersManager.busy
                from: 0
                to: 1
                value: engine.transfersManager.progress
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                wrapMode: Text.WordWrap
                visible: engine.transfersManager.busy && text.length > 0
                text: root.transferProgressText()
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Name")
                subText: backupFile.fileName
                progressive: false
                prominentSubText: true
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Size")
                subText: NymeaUtils.formatFileSize(backupFile.size)
                progressive: false
                prominentSubText: true
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Server version")
                subText: backupFile.serverVersion
                progressive: false
                prominentSubText: true
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Created")
                icon.source: "qrc:/icons/backup.svg"
                subText: Qt.formatDateTime(backupFile.timestamp, "dd.MM.yyyy hh:mm:ss")
                progressive: false
                prominentSubText: true
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("Download")
                icon.source: "qrc:/icons/download.svg"
                enabled: !engine.transfersManager.busy && !backupFileDetailsPage.deleting && !backupFileDetailsPage.restoring
                onClicked: {
                    root.statusMessage = ""
                    root.clearPendingDownload()
                    engine.nymeaConfiguration.downloadBackupFile(backupFile.fileName)
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("Delete backup")
                icon.source: "qrc:/icons/delete.svg"
                enabled: !engine.transfersManager.busy && !backupFileDetailsPage.deleting && !backupFileDetailsPage.restoring
                onClicked: {
                    var dialog = deleteBackupDialogComponent.createObject(root, { backupFile: backupFile })
                    dialog.open()
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("Restore backup")
                icon.source: "qrc:/icons/refresh.svg"
                enabled: !engine.transfersManager.busy && !backupFileDetailsPage.deleting && !backupFileDetailsPage.restoring
                onClicked: {
                    var dialog = restoreBackupDialogComponent.createObject(root, { backupFile: backupFile })
                    dialog.open()
                }
            }

            Connections {
                target: engine.nymeaConfiguration

                function onDeleteBackupFileFinished(commandId, configurationError, fileName) {
                    if (!backupFileDetailsPage.deleting) {
                        return
                    }

                    backupFileDetailsPage.deleting = false

                    if (configurationError !== "ConfigurationErrorNoError") {
                        root.openErrorDialog(qsTr("Failed to delete the backup file: %1").arg(configurationError))
                        return
                    }

                    root.statusMessage = qsTr("Backup file deleted.")
                    pageStack.pop()
                }

                function onRestoreBackupFileFinished(commandId, configurationError, fileName) {
                    if (!backupFileDetailsPage.restoring) {
                        return
                    }

                    backupFileDetailsPage.restoring = false

                    if (configurationError !== "ConfigurationErrorNoError") {
                        root.openErrorDialog(qsTr("Failed to restore the backup file: %1").arg(configurationError))
                        return
                    }

                    root.statusMessage = qsTr("Backup restore started. The server will reboot once finished.")
                    pageStack.pop()
                }
            }
        }
    }

    Component {
        id: deleteBackupDialogComponent

        NymeaDialog {
            title: qsTr("Delete backup file?")
            text: qsTr("Do you really want to delete the backup file \n%1?").arg(backupFile ? backupFile.fileName : "")
            standardButtons: Dialog.Yes | Dialog.No

            property BackupFile backupFile

            onAccepted: {
                if (!backupFile)
                    return

                var page = pageStack.currentItem
                if (page && page.objectName === "backupFileDetailsPage") {
                    page.deleting = true
                }
                engine.nymeaConfiguration.deleteBackupFile(backupFile.fileName)
            }
        }
    }

    Component {
        id: restoreBackupDialogComponent

        NymeaDialog {
            title: qsTr("Restore backup file?")
            text: qsTr("Do you really want to restore the backup file %1? All current settings will be removed and the server will reboot once finished.").arg(backupFile ? backupFile.fileName : "")
            standardButtons: Dialog.Yes | Dialog.No

            property BackupFile backupFile

            onAccepted: {
                if (!backupFile)
                    return

                var page = pageStack.currentItem
                if (page && page.objectName === "backupFileDetailsPage") {
                    page.restoring = true
                }

                engine.nymeaConfiguration.restoreBackupFile(backupFile.fileName)
            }
        }
    }

    Component {
        id: uploadRestoreBackupDialogComponent

        NymeaDialog {
            title: qsTr("Upload and restore backup?")
            text: qsTr("Do you really want to upload and restore the backup file %1? All current settings will be removed and the server will reboot once finished.").arg(fileName)
            standardButtons: Dialog.Yes | Dialog.No

            property string fileName: ""

            onAccepted: {
                if (!root.pendingRestoreSourceUrl || root.pendingRestoreSourceUrl.toString().length === 0) {
                    return
                }

                root.statusMessage = ""
                root.restoringUploadedBackup = true
                engine.nymeaConfiguration.uploadAndRestoreBackup(root.pendingRestoreSourceUrl)
            }

            onRejected: root.clearPendingRestoreUpload()
        }
    }
}
