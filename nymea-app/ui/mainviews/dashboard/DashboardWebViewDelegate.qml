/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.2
import Nymea 1.0
import "../../components"
import "../../delegates"
//import QtWebView 1.1
import QtGraphicalEffects 1.1

DashboardDelegateBase {
    id: root
    property DashboardWebViewItem item: null
    configurable: true

    function configure() {
        root.openDialog(configDialogComponent)
    }

    contentItem: MouseArea {
        id: delegateRoot
        width: root.width
        height: root.height

        Component.onCompleted: {
            // This might fail if qml-module-qtwebview isn't around
            var webView = Qt.createQmlObject(webViewString, webViewContainer);
            print("created webView", webView)
        }
        property string webViewString:
            '
            import QtQuick 2.8;
            import QtWebView 1.1;
            import Nymea 1.0;

            WebView {
                id: webView
                anchors.fill: parent
anchors.bottomMargin: root.bottomClip + Style.smallMargins
anchors.topMargin: root.topClip + Style.smallMargins    
                anchors.margins: Style.smallMargins
                url: root.item.url
                enabled: root.item.interactive
                visible: !app.mainMenu.visible && !root.editMode && root.topClip < root.height && root.bottomClip < height
            }
            '

        Item {
            id: webViewContainer
            anchors.fill: parent
        }

        Rectangle {
            id: mask
            anchors.fill: parent
            anchors.margins: Style.smallMargins
            radius: Style.cornerRadius
        }

        OpacityMask {
            anchors.fill: parent
            anchors.margins: Style.smallMargins
            source: ShaderEffectSource {
                sourceItem: webViewContainer
                recursive: true
                hideSource: true
            }
            maskSource: mask
        }
    }

    Component {
        id: configDialogComponent
        MeaDialog {
            id: configDialog

            onAccepted: {
                root.item.url = urlTextField.text
                root.item.columnSpan = columnsTabs.currentValue
                root.item.rowSpan = rowsTabs.currentValue
                root.item.interactive = interactiveSwitch.checked
            }

            SettingsPageSectionHeader {
                Layout.fillWidth: true
                text: qsTr("Location")
            }

            TextField {
                id: urlTextField
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                placeholderText: qsTr("Enter a URL")
                text: root.item.url
            }

            SettingsPageSectionHeader {
                Layout.fillWidth: true
                text: qsTr("Size")
            }

            GridLayout {
                columns: width > 300 ? 2 : 1
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                columnSpacing: Style.smallMargins
                rowSpacing: Style.smallMargins
                Label {
                    text: qsTr("Columns")
                }
                SelectionTabs {
                    id: columnsTabs
                    Layout.fillWidth: true
                    model: [1, 2, 3, 4, 5, 6]
                    currentIndex: root.item.columnSpan - 1
                }
                Label {
                    text: qsTr("Rows")
                }
                SelectionTabs {
                    id: rowsTabs
                    Layout.fillWidth: true
                    model: [1, 2, 3, 4, 5, 6]
                    currentIndex: root.item.rowSpan - 1
                }
            }

            SettingsPageSectionHeader {
                Layout.fillWidth: true
                text: qsTr("Behavior")
                visible: ["android", "ios"].indexOf(Qt.platform.os) < 0
            }

            SwitchDelegate {
                id: interactiveSwitch
                Layout.fillWidth: true
                checked: root.item.interactive
                text: qsTr("Interactive")
                visible: ["android", "ios"].indexOf(Qt.platform.os) < 0
            }
        }
    }
}
