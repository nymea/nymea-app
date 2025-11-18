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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: packageDetailsPage

    title: qsTr("Package information")
    property Package pkg: null

    GridLayout {
        Layout.fillWidth: true
        columns: app.landscape ? 2 : 1
        RowLayout {
            Layout.margins: app.margins
            spacing: app.margins
            ColorIcon {
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: Style.iconSize * 2
                name: "qrc:/icons/plugin.svg"
                color: Style.accentColor
            }
            Label {
                Layout.fillWidth: true
                text: pkg.displayName
                font.pixelSize: app.largeFont
                elide: Text.ElideRight
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            text: packageDetailsPage.pkg.summary
            wrapMode: Text.WordWrap
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Installed version:")
            subText: packageDetailsPage.pkg.installedVersion.length > 0 ? packageDetailsPage.pkg.installedVersion : qsTr("Not installed")
            progressive: false
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            text: qsTr("Candidate version:")
            subText: packageDetailsPage.pkg.candidateVersion
            visible: packageDetailsPage.pkg.updateAvailable || packageDetailsPage.pkg.installedVersion.length === 0
            progressive: false
        }
        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            visible: packageDetailsPage.pkg.updateAvailable || packageDetailsPage.pkg.installedVersion.length === 0
            text: packageDetailsPage.pkg.updateAvailable ? qsTr("Update") : qsTr("Install")
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                var text = qsTr("This will start a system update. Note that the update might take several minutes and your %1 might not be functioning properly or restart during this time.").arg(Configuration.systemName)
                + "\n\n"
                + qsTr("\nDo you want to proceed?")
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "qrc:/icons/system-update.svg",
                                                    title: qsTr("Start update"),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    engine.systemController.updatePackages(packageDetailsPage.pkg.id)
                })

            }
        }
        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Remove")
            visible: packageDetailsPage.pkg.canRemove
            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                var text = qsTr("This will start a system update. Note that the update might take several minutes and your %1 system might not be functioning properly during this time and restart during the process.\nDo you want to proceed?").arg(Configuration.systemName)
                var popup = dialog.createObject(app,
                                                {
                                                    headerIcon: "qrc:/icons/system-update.svg",
                                                    title: qsTr("Remove package"),
                                                    text: text,
                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                });
                popup.open();
                popup.accepted.connect(function() {
                    engine.systemController.removePackages(packageDetailsPage.pkg.id)
                })
            }
        }

    }
    UpdateRunningOverlay {
    }
}
