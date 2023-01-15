/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2022, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

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
                      ? Qt.resolvedUrl("../images/system-update.svg")
                      : Qt.resolvedUrl("../images/view-" + (model.installedVersion.length > 0 ? "expand" : "collapse") + ".svg")
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
            imageSource: "/ui/images/dialog-error-symbolic.svg"
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





