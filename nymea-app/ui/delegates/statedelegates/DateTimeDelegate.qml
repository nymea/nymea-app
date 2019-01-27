import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

Label {
    property var value
    text: Qt.formatDateTime(new Date(value * 1000), Qt.DefaultLocaleShortDate)
    horizontalAlignment: Text.AlignRight
}
