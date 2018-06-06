import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("About %1").arg(app.systemName)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: app.margins

        Image {
            Layout.preferredHeight: app.iconSize * 4
            Layout.fillWidth: true
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            source: "../guh-logo.svg"
        }

        ThinDivider {}

        GridLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
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

        ThinDivider { }

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
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
