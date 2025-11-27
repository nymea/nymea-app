import QtQuick 2.9
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Nymea 1.0

// This code is copied from ConsolinnoSetUpButton (to avoid using controls from the overlay
// in the nymea-app) as a secondary button is needed in SetupWizard.
Button {
    id: root

    property color backgroundColor
    readonly property color fontColor: {
        if(Configuration.branding === "consolinno") {
            if(root.backgroundColor.length > 0) {
                return Style.buttonTextColor
            }

            return Style.buttonTextColorNoBg
        }

        return Style.consolinnoExtraDark
    }

    Layout.fillWidth: true

    contentItem: Label {
        text: root.text
        anchors.fill: parent
        color: fontColor
        font.pixelSize: 13
        font.letterSpacing: 2
        font.capitalization: Font.AllUppercase
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        visible: root.backgroundColor.length > 0
        color: root.backgroundColor
    }
}
