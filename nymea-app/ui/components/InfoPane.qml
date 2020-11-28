import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.2

Item {
    id: root
    implicitHeight: d.shownHeight
    visible: d.shownHeight > 0

    property alias text: textLabel.text
    property alias imageSource: icon.name
    property alias buttonText: button.text

    property alias color: background.color
    property alias textColor: textLabel.color

    property bool rotatingIcon: false

    property bool shown: false

    function show() {
        shown = true;
    }
    function hide() {
        shown = false;
    }

    signal paneClicked();
    signal buttonClicked();

    QtObject {
        id: d
        property int shownHeight: shown ? contentRow.implicitHeight : 0
        Behavior on shownHeight { NumberAnimation { easing.type: Easing.InOutQuad; duration: 150 } }
    }

    Pane {
        anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
        Material.elevation: 2
        padding: 0
        height: contentRow.implicitHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.paneClicked()
        }

        Rectangle {
            id: background
            color: app.accentColor
            anchors.fill: parent

            RowLayout {
                id: contentRow
                anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins }
                Label {
                    id: textLabel
                    color: "white"
                    font.pixelSize: app.smallFont
                    Layout.fillWidth: true
                    Layout.margins: app.margins * .4
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.WordWrap
                }
                ColorIcon {
                    id: icon
                    height: app.smallIconSize
                    width: height
                    color: "white"
                    visible: name.length > 0

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 2000
                        loops: Animation.Infinite
                        running: root.rotatingIcon
                        onStopped: icon.rotation = 0;
                    }
                }

                Button {
                    id: button
                    visible: text.length > 0
                    onClicked: root.buttonClicked()
                }
            }
        }
    }
}


