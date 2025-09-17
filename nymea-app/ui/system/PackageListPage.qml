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
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

import "../components"

SettingsPageBase {
    id: packageListPage
    title: qsTr("All packages")

    property Packages packages: engine.systemController.packages
    property alias filter: filterTextField.text
    property alias showFilter: filterRow.visible

    ColumnLayout {
        id: filterRow
        Layout.fillWidth: true
        RowLayout {
            Layout.margins: Style.margins
            spacing: Style.margins
            ColorIcon {
                name: "find"
            }
            TextField {
                id: filterTextField
                Layout.fillWidth: true
            }
            ColorIcon {
                name: "close"
                visible: filterTextField.text.length > 0
                MouseArea {
                    anchors.fill: parent
                    onClicked: filterTextField.text = ""
                }
            }
        }
    }

    ListView {
        id: listView
        Layout.fillWidth: true
        Layout.preferredHeight: packageListPage.height - y
        clip: true

        ScrollBar.vertical: ScrollBar {}

        model: PackagesFilterModel {
            id: filterModel
            packages: packageListPage.packages
            nameFilter: filterTextField.displayText
        }

        delegate: NymeaSwipeDelegate {
            width: parent.width
            text: model.displayName
            subText: model.candidateVersion
            prominentSubText: false
            iconName: model.updateAvailable
                      ? Qt.resolvedUrl("qrc:/icons/system-update.svg")
                      : Qt.resolvedUrl("qrc:/icons/view-" + (model.installedVersion.length > 0 ? "expand" : "collapse") + ".svg")
            iconColor: model.updateAvailable
                       ? "green"
                       : model.installedVersion.length > 0 ? "blue" : Style.iconColor
            onClicked: {
                pageStack.push(Qt.resolvedUrl("PackageDetailsPage.qml"), {pkg: filterModel.get(index)})
            }
        }

        EmptyViewPlaceholder {
            anchors.centerIn: parent
            width: parent.width - Style.margins * 2
            visible: filterModel.count == 0
            title: qsTr("No package found")
            text: qsTr("We're sorry. We couldn't find any package matching the search term %1.").arg(packageListPage.filter)
            imageSource: "qrc:/icons/dialog-error-symbolic.svg"
            buttonVisible: false
        }

        UpdateRunningOverlay {
        }
    }

    Component {
        id: errorDialogComponent

        ErrorDialog {
            id: errorDialog
        }
    }
}





