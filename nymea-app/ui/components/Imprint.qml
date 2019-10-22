import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

Item {
    id: root
    implicitHeight: aboutColumn.implicitHeight

    property alias title: titleLabel.text
    property url githubLink
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
                Layout.preferredHeight: app.iconSize * 2
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
                            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                            var text = settings.showHiddenOptions
                                    ? qsTr("Developer options are now enabled. If you have found this by accident, it is most likely not of any use for you. It will just enable some nerdy developer gibberish in the app. Tap the icon another 10 times to disable it again.")
                                    : qsTr("Developer options are now disabled.")
                            var popup = dialog.createObject(app, {headerIcon: "../images/dialog-warning-symbolic.svg", title: qsTr("Howdy cowboy!"), text: text})
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
            text: "Copyright (C) 2019 nymea GmbH"
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("nymea is a registered trademark of nymea GmbH.")
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
            text: qsTr("Licensed under the terms of the GNU general public license, version 2. Please visit the GitHub page for source code and build instructions.")
        }

        ColumnLayout {
            Layout.fillWidth: true

            NymeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/stock_website.svg"
                text: qsTr("Visit the nymea website")
                subText: "https://nymea.io"
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally("https://nymea.io")
                }
            }

            NymeaListItemDelegate {
                Layout.fillWidth: true
                iconName: "../images/stock_website.svg"
                text: qsTr("Visit GitHub page")
                subText: root.githubLink
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally(root.githubLink)
                }
            }

            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("View privacy policy")
                iconName: "../images/stock_website.svg"
                subText: app.privacyPolicyUrl
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally(app.privacyPolicyUrl)
                }
            }

            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("View license text")
                iconName: "../images/logs.svg"
                subText: "GNU General Public License v2"
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    pageStack.push(licenseTextComponent)
                }
            }
        }


        ThinDivider { }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            Image {
                Layout.preferredHeight: app.iconSize * 2
                Layout.preferredWidth: height
                fillMode: Image.PreserveAspectFit
                source: "qrc:/ui/images/Built_with_Qt_RGB_logo_vertical.svg"
                sourceSize.width: app.iconSize * 2
                sourceSize.height: app.iconSize * 2
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Qt is a registered trademark of The Qt Company Ltd. and its subsidiaries.")
                wrapMode: Text.WordWrap
            }
        }
        NymeaListItemDelegate {
            Layout.fillWidth: true
            iconName: "../images/stock_website.svg"
            text: qsTr("Visit the Qt website")
            subText: "https://www.qt.io"
            prominentSubText: false
            wrapTexts: false
            onClicked: {
                Qt.openUrlExternally("https://www.qt.io")
            }
        }
    }


    Component {
        id: licenseTextComponent
        Page {
            header: NymeaHeader {
                text: qsTr("License text")
                onBackPressed: pageStack.pop()
            }
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
                        xhr.open("GET", "../../LICENSE");
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                text = xhr.responseText.replace(/(^\ *)/gm, "").replace(/(\n\n)/gm,"\t").replace(/(\n)/gm, " ").replace(/(\t)/gm, "\n\n");
                            }
                        };
                        xhr.send();
                    }
                }
            }
        }
    }
}

