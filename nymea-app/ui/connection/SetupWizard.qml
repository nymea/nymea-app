import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("First setup")
        backButtonVisible: true
        onBackPressed: root.backPressed()
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("Welcome to %1!").arg(app.systemName)
        text: qsTr("This %1 system has not been set up yet. This wizard will guide you through a few simple steps to set it up.").arg(app.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        buttonText: qsTr("Next")
        onButtonClicked: {
            var page = pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
            page.backPressed.connect(function() {pageStack.pop();})
        }
    }
}
