import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root

    readonly property bool haveHosts: hostsProxy.count > 0

    Component.onCompleted: {
        print("Ready to connect")
        pageStack.push(discoveryPage, StackView.Immediate)
    }


    function connectToHost(url, noAnimations) {
        var page = pageStack.push(Qt.resolvedUrl("ConnectingPage.qml"), noAnimations ? StackView.Immediate : StackView.PushTransition)
        page.cancel.connect(function() {
            engine.connection.disconnect()
            pageStack.pop(root, StackView.Immediate);
            pageStack.push(discoveryPage)
        })
        engine.connection.connect(url)
    }

    function connectToHost2(host, noAnimations) {
        var page = pageStack.push(Qt.resolvedUrl("ConnectingPage.qml"), noAnimations ? StackView.Immediate : StackView.PushTransition)
        page.cancel.connect(function() {
            engine.connection.disconnect()
            pageStack.pop(root, StackView.Immediate);
            pageStack.push(discoveryPage)
        })
        print("Connecting to host", host)
        engine.connection.connect(host)
    }

    NymeaHostsFilterModel {
        id: hostsProxy
        discovery: _discovery
        showUnreachableBearers: false
        nymeaConnection: engine.connection
        showUnreachableHosts: false
    }

    Component {
        id: discoveryPage

        Page {
            objectName: "discoveryPage"
            header: FancyHeader {
                title: qsTr("Connect %1").arg(app.systemName)
                model: ListModel {
                    ListElement { iconSource: "../images/network-vpn.svg"; text: qsTr("Manual connection"); page: "ManualConnectPage.qml" }
                    ListElement { iconSource: "../images/bluetooth.svg"; text: qsTr("Wireless setup"); page: "wifisetup/BluetoothDiscoveryPage.qml"; }
                    ListElement { iconSource: "../images/private-browsing.svg"; text: qsTr("Demo mode"); page: "" }
                    ListElement { iconSource: "../images/stock_application.svg"; text: qsTr("App settings"); page: "../appsettings/AppSettingsPage.qml" }
                }
                onClicked: {
                    if (index === 2) {
                        var host = discovery.nymeaHosts.createWanHost("Demo server", "nymea://nymea.nymea.io:2222")
                        engine.connection.connect(host)
                    } else {
                        pageStack.push(model.get(index).page, {nymeaDiscovery: discovery});
                    }
                }
            }

            Timer {
                id: splashHideTimeout
                interval: 3000
                repeat: false
                running: true
                onTriggered: {
                    PlatformHelper.hideSplashScreen()
                    startupTimer.start()
                }
            }

            Timer {
                id: startupTimer
                interval: 10000
                repeat: false
                running: false
            }


            ColumnLayout {
                anchors.fill: parent
                spacing: app.margins

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.topMargin: app.margins
                    spacing: app.margins

                    Label {
                        Layout.fillWidth: true
                        text: root.haveHosts ? qsTr("Oh, look!") : startupTimer.running ? qsTr("Just a moment...") : qsTr("Uh oh")
                        //color: "black"
                        font.pixelSize: app.largeFont
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.haveHosts ?
                                  qsTr("There are %1 %2:cores in your network! Which one would you like to use?").arg(hostsProxy.count).arg(app.systemName)
                                : startupTimer.running ? qsTr("We haven't found a %1:core in your network yet.").arg(app.systemName)
                                                       : qsTr("There doesn't seem to be a %1:core installed in your network. Please make sure your %1:core system is correctly set up and connected.").arg(app.systemName)
                        wrapMode: Text.WordWrap
                    }
                }

                ThinDivider { }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: hostsProxy
                    clip: true

                    delegate: NymeaListItemDelegate {
                        id: nymeaHostDelegate
                        width: parent.width
                        height: app.delegateHeight
                        objectName: "discoveryDelegate" + index
                        property var nymeaHost: hostsProxy.get(index)
                        property string defaultConnectionIndex: {
                            var bestIndex = -1
                            var bestPriority = 0;
                            for (var i = 0; i < nymeaHost.connections.count; i++) {
                                var connection = nymeaHost.connections.get(i);
                                if (bestIndex === -1 || connection.priority > bestPriority) {
                                    bestIndex = i;
                                    bestPriority = connection.priority;
                                }
                            }
                            return bestIndex;
                        }

                        iconName: {
                            switch (nymeaHost.connections.get(defaultConnectionIndex).bearerType) {
                            case Connection.BearerTypeLan:
                            case Connection.BearerTypeWan:
                                if (engine.connection.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                    return "../images/network-wired.svg"
                                }
                                return "../images/network-wifi.svg";
                            case Connection.BearerTypeBluetooth:
                                return "../images/bluetooth.svg";
                            case Connection.BearerTypeCloud:
                                return "../images/cloud.svg"
                            case Connection.BearerTypeLoopback:
                                return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                            }
                            return ""
                        }

                        text: model.name
                        subText: nymeaHost.connections.get(defaultConnectionIndex).url
                        wrapTexts: false
                        prominentSubText: false
                        progressive: false
                        property bool isSecure: nymeaHost.connections.get(defaultConnectionIndex).secure
                        property bool isTrusted: engine.connection.isTrusted(nymeaHostDelegate.nymeaHost.connections.get(defaultConnectionIndex).url)
                        property bool isOnline: nymeaHost.connections.get(defaultConnectionIndex).bearerType !== Connection.BearerTypeWan ? nymeaHost.connections.get(defaultConnectionIndex).online : true
                        tertiaryIconName: isSecure ? "../images/network-secure.svg" : ""
                        tertiaryIconColor: isTrusted ? app.accentColor : Material.foreground
                        secondaryIconName: !isOnline ? "../images/cloud-error.svg" : ""
                        secondaryIconColor: "red"

                        onClicked: {
                            root.connectToHost2(nymeaHostDelegate.nymeaHost)
                        }

                        contextOptions: [
                            {
                                text: qsTr("Info"),
                                icon: Qt.resolvedUrl("../images/info.svg"),
                                callback: function() {
                                    var nymeaHost = hostsProxy.get(index);
                                    var popup = infoDialog.createObject(app,{nymeaHost: nymeaHost})
                                    popup.open()
                                }
                            }
                        ]
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: app.margins
                        visible: !root.haveHosts

                        Label {
                            text: qsTr("Searching for %1:core systems...").arg(app.systemName)
                        }

                        BusyIndicator {
                            running: visible
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                ThinDivider {}

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    wrapMode: Text.WordWrap
                    visible: discovery.nymeaHosts.count === 0
                    text: qsTr("Do you have a %1:core but it's not connected to your network yet? Use the wireless setup to connect it!").arg(app.systemName)
                }
                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: discovery.nymeaHosts.count === 0
                    text: qsTr("Start wireless setup")
                    onClicked: pageStack.push(Qt.resolvedUrl("wifisetup/BluetoothDiscoveryPage.qml"), {nymeaDiscovery: discovery})
                }
                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("Cloud login")
                    visible: !AWSClient.isLoggedIn
                    onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/CloudLoginPage.qml"))
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.bottomMargin: app.margins
                    visible: discovery.nymeaHosts.count === 0
                    text: qsTr("Demo mode (online)")
                    onClicked: {
                        var host = discovery.nymeaHosts.createWanHost("Demo server", "nymea://nymea.nymea.io:2222")
                        engine.connection.connect(host)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.bottomMargin: app.margins
                    visible: root.haveHosts
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Not the ones you're looking for? We're looking for more!")
                        wrapMode: Text.WordWrap
                    }

                    BusyIndicator { }
                }
            }
        }
    }

    Component {
        id: infoDialog
        Dialog {
            id: dialog
            width: Math.min(parent.width, contentGrid.implicitWidth)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            title: qsTr("Box information")

            standardButtons: Dialog.Ok

            property var nymeaHost: null

            header: Item {
                implicitHeight: headerRow.height + app.margins * 2
                implicitWidth: parent.width
                RowLayout {
                    id: headerRow
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize * 2
                        Layout.preferredWidth: height
                        name: "../images/info.svg"
                        color: app.accentColor
                    }

                    Label {
                        id: titleLabel
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: dialog.title
                        color: app.accentColor
                        font.pixelSize: app.largeFont
                    }
                }
            }

            GridLayout {
                id: contentGrid
                anchors.fill: parent
                rowSpacing: app.margins
                columns: 2
                Label {
                    text: "Name:"
                }
                Label {
                    text: dialog.nymeaHost.name
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: "UUID:"
                }
                Label {
                    text: dialog.nymeaHost.uuid
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Label {
                    text: "Version:"
                }
                Label {
                    text: dialog.nymeaHost.version
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                ThinDivider { Layout.columnSpan: 2 }
                Label {
                    Layout.columnSpan: 2
                    text: qsTr("Available connections")
                }

                Flickable {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    contentHeight: contentColumn.implicitHeight
                    clip: true
                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        Repeater {
                            model: dialog.nymeaHost.connections
                            delegate: NymeaListItemDelegate {
                                Layout.fillWidth: true
                                wrapTexts: false
                                progressive: false
                                text: model.name
                                subText: model.url
                                prominentSubText: false
                                iconName: {
                                    switch (model.bearerType) {
                                    case Connection.BearerTypeLan:
                                    case Connection.BearerTypeWan:
                                        if (engine.connection.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                            return "../images/network-wired.svg"
                                        }
                                        return "../images/network-wifi.svg";
                                    case Connection.BearerTypeBluetooth:
                                        return "../images/bluetooth.svg";
                                    case Connection.BearerTypeCloud:
                                        return "../images/cloud.svg"
                                    }
                                    return ""
                                }

                                tertiaryIconName: model.secure ? "../images/network-secure.svg" : ""
                                tertiaryIconColor: isTrusted ? app.accentColor : "gray"
                                readonly property bool isTrusted: engine.connection.isTrusted(url)
                                secondaryIconName: !model.online ? "../images/cloud-error.svg" : ""
                                secondaryIconColor: "red"

                                onClicked: {
                                    dialog.close()
                                    engine.connection.connect(dialog.nymeaHost, dialog.nymeaHost.connections.get(index))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
