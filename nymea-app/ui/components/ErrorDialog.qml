import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

MeaDialog {
    id: root

    title: qsTr("Oh snap!")
    headerIcon: "../images/dialog-error-symbolic.svg"

    property string errorCode: ""

    text: qsTr("An unexpected error happened. We're sorry for that.") +
          (errorCode.length > 0 ? "\n\n" + qsTr("Error code: %1").arg(errorCode) : "")

}
