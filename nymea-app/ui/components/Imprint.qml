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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

Item {
    id: root
    implicitHeight: aboutColumn.implicitHeight

    property alias title: titleLabel.text
    property url githubLink
    property var additionalLicenses: null

    default property alias content: contentGrid.data

    ColumnLayout {
        id: aboutColumn
        anchors { left: parent.left; right: parent.right; top: parent.top }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            Image {
                id: logo
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: height
                fillMode: Image.PreserveAspectFit
                source: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)

                MouseArea {
                    anchors.fill: parent
                    property int clickCounter: 0
                    onClicked: {
                        clickCounter++;
                        if (clickCounter >= 10) {
                            settings.showHiddenOptions = !settings.showHiddenOptions
                            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                            var text = settings.showHiddenOptions
                                    ? qsTr("Developer options are now enabled. If you have found this by accident, it is most likely not of any use for you. It will just enable some nerdy developer gibberish in the app. Tap the icon another 10 times to disable it again.")
                                    : qsTr("Developer options are now disabled.")
                            var popup = dialog.createObject(app, {headerIcon: "qrc:/icons/dialog-warning-symbolic.svg", title: qsTr("Howdy cowboy!"), text: text})
                            popup.open();
                            clickCounter = 0;
                        }
                    }
                }
            }

            Label {
                id: titleLabel
                font.pixelSize: app.largeFont
            }
        }

        ThinDivider {}

        GridLayout {
            id: contentGrid
            Layout.fillWidth: true
            columns: Math.max(1, root.width / 300)
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.topMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            font.bold: true
            text: "Copyright (C) %1 chargebyte austria GmbH".arg(new Date().getFullYear())
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("nymea is a registered trademark of chargebyte austria GmbH.")
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
            text: qsTr("Licensed under the terms of the GNU General Public License, version 3. Please visit the GitHub page for source code and build instructions.")
        }

        ColumnLayout {
            Layout.fillWidth: true

            Repeater {
                visible: Configuration.additionalImrintLinks !== null && Configuration.additionalImrintLinks.count > 0
                model: Configuration.additionalImrintLinks
                delegate:NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    iconName: "qrc:/icons/stock_website.svg"
                    text: model.text
                    subText: model.subText
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: {
                        Qt.openUrlExternally(model.url)
                    }
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                iconName: "qrc:/icons/stock_website.svg"
                text: qsTr("Chargebyte")
                subText: "https://chargebyte.com"
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally("https://chargebyte.com")
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                iconName: "qrc:/icons/stock_website.svg"
                text: qsTr("Visit the nymea website")
                subText: "https://nymea.io"
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally("https://nymea.io")
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                iconName: "qrc:/icons/stock_website.svg"
                text: qsTr("Visit GitHub page")
                subText: root.githubLink
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally(root.githubLink)
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("View privacy policy")
                iconName: "qrc:/icons/stock_website.svg"
                subText: Configuration.privacyPolicyUrl
                prominentSubText: false
                wrapTexts: false
                onClicked:
                    Qt.openUrlExternally(Configuration.privacyPolicyUrl)
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Software license")
                iconName: "qrc:/icons/stock_website.svg"
                subText: "The nymea sofware license"
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally("https://nymea.io/license")
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Additional software licenses")
                iconName: "qrc:/icons/logs.svg"
                subText: "Additional used software licenses"
                prominentSubText: false
                wrapTexts: false
                visible: root.additionalLicenses && root.additionalLicenses.count > 0
                onClicked: {
                    pageStack.push(licensesPageComponent)
                }
            }
        }
    }


    Component {
        id: licensesPageComponent
        Page {
            id: licensesPage
            header: NymeaHeader {
                text: qsTr("Additional software licenses")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Repeater {
                    model: root.additionalLicenses

                    delegate: NymeaSwipeDelegate {
                        Layout.fillWidth: true
                        text: model.component
                        subText: model.infoText
                        prominentSubText: false
                        visible: model.platforms === "*" ||  model.platforms.indexOf(Qt.platform.os) >= 0
                        onClicked: {
                            pageStack.push(licenseTextComponent, {license: model.license})
                        }
                    }
                }
            }
        }
    }

    Component {
        id: licenseTextComponent
        Page {
            id: licenseTextPage
            header: NymeaHeader {
                text: parent.license
                onBackPressed: pageStack.pop()
            }

            property string license

            Flickable {
                anchors.fill: parent
                contentHeight: licenseText.implicitHeight
                clip: true
                ScrollBar.vertical: ScrollBar {}
                TextArea {
                    id: licenseText
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    anchors { left: parent.left; right: parent.right; margins: app.margins }
                    readOnly: true
                    Component.onCompleted: {
                        var xhr = new XMLHttpRequest;
                        xhr.open("GET", "../../LICENSE." + licenseTextPage.license);
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                text = xhr.responseText
                            }
                        };
                        xhr.send();
                    }
                }
            }
        }
    }
}

