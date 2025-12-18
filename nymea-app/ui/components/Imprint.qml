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


Item {
    id: root
    implicitHeight: aboutColumn.implicitHeight

    property alias title: titleLabel.text
    property url githubLink

    property bool showOpensourceLicenses: true

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
                Layout.preferredHeight: Style.hugeIconSize
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
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
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
                delegate: NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    iconName: "qrc:/icons/stock_website.svg"
                    text: model.text
                    subText: model.subText
                    prominentSubText: false
                    wrapTexts: false
                    onClicked: { Qt.openUrlExternally(model.url) }
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                iconName: "qrc:/icons/stock_website.svg"
                text: qsTr("chargebyte GmbH")
                subText: "https://chargebyte.com"
                prominentSubText: false
                wrapTexts: false
                onClicked: { Qt.openUrlExternally("https://chargebyte.com") }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                iconName: "qrc:/icons/stock_website.svg"
                text: qsTr("Visit the nymea project website")
                subText: "https://nymea.io"
                prominentSubText: false
                wrapTexts: false
                onClicked: { Qt.openUrlExternally("https://nymea.io") }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                iconName: "qrc:/icons/stock_website.svg"
                text: qsTr("Visit GitHub page")
                subText: root.githubLink
                prominentSubText: false
                wrapTexts: false
                onClicked: { Qt.openUrlExternally(root.githubLink) }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("View privacy policy")
                iconName: "qrc:/icons/stock_website.svg"
                subText: Configuration.privacyPolicyUrl
                prominentSubText: false
                wrapTexts: false
                onClicked: Qt.openUrlExternally(Configuration.privacyPolicyUrl)
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Software license")
                iconName: "qrc:/icons/stock_website.svg"
                subText: "The nymea sofware license"
                prominentSubText: false
                wrapTexts: false
                onClicked: { Qt.openUrlExternally("https://www.gnu.org/licenses/gpl-3.0-standalone.html") }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Open Source Licenses")
                iconName: "qrc:/icons/logs.svg"
                subText: "List of all open source components used in this app."
                prominentSubText: false
                wrapTexts: false
                visible: root.showOpensourceLicenses
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

            Flickable {
                anchors.fill: parent
                contentHeight: licensesColumnLayout.implicitHeight + app.margins
                clip: true

                ColumnLayout {
                    id: licensesColumnLayout
                    anchors { left: parent.left; top: parent.top; right: parent.right }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtCore"
                        description: qsTr("Qt core module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtbase"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtGui"
                        description: qsTr("Qt gui module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtbase"
                        platforms: "*"
                    }


                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtNetwork"
                        description: qsTr("Qt network module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtbase"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtQML"
                        description: qsTr("Qt QML module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtdeclarative"
                        platforms: "*"
                    }


                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtQuick"
                        description: qsTr("Qt Quick module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtdeclarative"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtQuickControls"
                        description: qsTr("Qt Quick Controls module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtdeclarative"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtQuickDialogs"
                        description: qsTr("Qt Quick Dialogs module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtdeclarative"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtQuickLayouts"
                        description: qsTr("Qt Quick Layouts module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtdeclarative"
                        platforms: "*"
                    }


                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "Qt5CoreComapitbility"
                        description: qsTr("Qt 5 compatibility module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "Qt Image Formats"
                        description: qsTr("Qt image formats module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtSvg"
                        description: qsTr("Qt SVG module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtsvg"
                        platforms: "*"
                    }


                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtCharts"
                        description: qsTr("Qt charts module")
                        license: "GPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtWebsockets"
                        description: qsTr("Qt websockets module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtwebsockets"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtBluetooth"
                        description: qsTr("Qt bluetooth module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtconnectivity"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtNfc"
                        description: qsTr("Qt NFC module")
                        license: "LGPLv3"
                        version: qtBuildVersion
                        url: "https://github.com/qt/qtconnectivity"
                        platforms: "*"
                    }


                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "nymea-remoteproxy"
                        description: qsTr("Client library for remote connections")
                        license: "LGPLv3"
                        version: "1.14.0"
                        url: "https://github.com/nymea/nymea-remoteproxy"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "QtZeroConf"
                        description: qsTr("QtZeroConf library by Jonathan Bagg")
                        license: "LGPLv3"
                        version: ""
                        url: "https://github.com/jbagg/QtZeroConf"
                        platforms: "android,ios,linux,osx"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "FirebaseSDK";
                        description: qsTr("Firebase iOS SDK")
                        license: "Apache 2.0"
                        version: "18.1.0"
                        url: "https://github.com/firebase/firebase-ios-sdk"
                        platforms: "ios"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "FirebaseSDK";
                        description: qsTr("Firebase Android SDK")
                        license: "Apache 2.0"
                        version: "18.1.0"
                        url: "https://github.com/firebase/firebase-android-sdk"
                        platforms: "android"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "OpenSSL"
                        description: qsTr("OpenSSL libraries by Eric Young")
                        license: "OpenSSL"
                        version: sslLibraryVersion
                        platforms: "android,windows,linux"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "Suru icons"
                        description: qsTr("Suru icons by Ubuntu")
                        license: "CC-BY-SA-3.0"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "Ubuntu font"
                        description: qsTr("Ubuntu font by Ubuntu")
                        license: "CC-BY-SA-3.0"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "Oswald font"
                        description: qsTr("Oswald font by The Oswald Project")
                        license: "OFL"
                        platforms: "*"
                    }

                    LicenseInformationItem {
                        Layout.fillWidth: true
                        component: "Material Icons"
                        description: qsTr("Google fonts and material icons")
                        license: "Apache 2.0"
                        url: "https://fonts.google.com/icons"
                        platforms: "*"
                    }


                    // Repeater {
                    //     model: root.additionalLicenses

                    //     delegate: NymeaSwipeDelegate {
                    //         Layout.fillWidth: true
                    //         text: model.component
                    //         subText: model.description
                    //         prominentSubText: false
                    //         visible: model.platforms === "*" ||  model.platforms.indexOf(Qt.platform.os) >= 0
                    //         onClicked: {
                    //             pageStack.push(licenseTextComponent, {license: model.license})
                    //         }
                    //     }
                    // }
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
