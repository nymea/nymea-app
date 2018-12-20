import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Item {

    GridLayout {
        anchors.fill: parent
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1
        rowSpacing: app.margins
        columnSpacing: app.margins
        Layout.alignment: Qt.AlignCenter

        Item {
            Layout.preferredWidth: Math.max(app.iconSize * 4, parent.width / 5)
            Layout.preferredHeight: width
            Layout.topMargin: app.margins
            Layout.bottomMargin: app.landscape ? app.margins : 0
            Layout.alignment: Qt.AlignCenter
            Layout.rowSpan: app.landscape ? 4 : 1
            Layout.fillHeight: true


            ColorIcon {
                anchors.fill: parent
                anchors.margins: app.margins * 1.5
                name: root.powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg"
                color: root.powerState.value === true ? app.accentColor : keyColor
            }
        }



    }
}

