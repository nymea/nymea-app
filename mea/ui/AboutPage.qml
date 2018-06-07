import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("About %1").arg(app.appName)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: aboutColumn.implicitHeight

        ColumnLayout {
            id: aboutColumn
            width: parent.width

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: app.margins
                spacing: app.margins

                Image {
                    Layout.preferredHeight: app.iconSize * 2
                    Layout.preferredWidth: height
                    fillMode: Image.PreserveAspectFit
                    source: "../guh-logo.svg"
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2

                    Label {
                        text: qsTr("App version:")
                    }
                    Label {
                        text: appVersion
                    }
                    Label {
                        text: qsTr("Qt version:")
                    }
                    Label {
                        text: qtVersion
                    }
                }
            }

            ThinDivider {}

            Label {
                Layout.fillWidth: true
                Layout.topMargin: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                font.bold: true
                text: "Copyright (C) 2018 guh GmbH"
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                text: qsTr("nymea is a registered trademark of guh GmbH.")
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                text: qsTr("Licensed under the terms of the GNU general public license, version 2. Please visit the GitHub page for source code and build instructions.")
            }

            ColumnLayout {
                Layout.fillWidth: true

                ItemDelegate {
                    Layout.fillWidth: true

                    contentItem: RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Visit the nymea website")
                        }
                        Image {
                            source: "images/next.svg"
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: height
                        }
                    }

                    onClicked: {
                        Qt.openUrlExternally("https://nymea.io")
                    }
                }

                ItemDelegate {
                    Layout.fillWidth: true

                    contentItem: RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Visit GitHub page")
                        }
                        Image {
                            source: "images/next.svg"
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: height
                        }
                    }
                    onClicked: {
                        Qt.openUrlExternally("https://github.com/guh/mea")
                    }
                }

                ItemDelegate {
                    Layout.fillWidth: true

                    contentItem: RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("View license text")
                        }
                        Image {
                            source: "images/next.svg"
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: height
                        }
                    }

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
                    source: "images/Built_with_Qt_RGB_logo_vertical.svg"
                    sourceSize.width: app.iconSize * 2
                    sourceSize.height: app.iconSize * 2
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Qt is a registered trademark of The Qt Company Ltd. and its subsidiaries.")
                    wrapMode: Text.WordWrap
                }
            }
            ItemDelegate {
                Layout.fillWidth: true

                contentItem: RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Visit the Qt website")
                    }
                    Image {
                        source: "images/next.svg"
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: height
                    }
                }

                onClicked: {
                    Qt.openUrlExternally("https://www.qt.io")
                }
            }
        }
    }


    Component {
        id: licenseTextComponent
        Page {
            header: GuhHeader {
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
