import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "qrc:/ui/connection"

Dialog {
    id: root
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    title: qsTr("System information")

    standardButtons: Dialog.NoButton

    property Engine nymeaEngine: null
    property var nymeaHost: null

    signal connectionSelected(Connection connection)

    header: Item {
        implicitHeight: headerRow.height + Style.margins * 2
        implicitWidth: parent.width
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.margins }
            spacing: Style.margins
            ColorIcon {
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: height
                name: "qrc:/icons/info.svg"
                color: Style.accentColor
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                color: Style.accentColor
                font.pixelSize: app.largeFont
            }
        }
    }

    GridLayout {
        id: contentGrid
        anchors.fill: parent
        rowSpacing: Style.margins
        columns: 2
        Label {
            text: "Name:"
        }
        Label {
            text: root.nymeaHost.name
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Label {
            text: "UUID:"
        }
        Label {
            text: root.nymeaHost.uuid
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Label {
            text: "Version:"
        }
        Label {
            text: root.nymeaHost.version
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
                    model: root.nymeaHost.connections
                    delegate: NymeaSwipeDelegate {
                        Layout.fillWidth: true
                        wrapTexts: false
                        progressive: false
                        text: model.url
                        subText: model.name
                        prominentSubText: false
                        iconName: {
                            switch (model.bearerType) {
                            case Connection.BearerTypeLan:
                            case Connection.BearerTypeWan:
                                if (nymeaEngine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                    return "qrc:/icons/connections/network-wired.svg"
                                }
                                return "qrc:/icons/connections/network-wifi.svg";
                            case Connection.BearerTypeBluetooth:
                                return "qrc:/icons/connections/bluetooth.svg";
                            case Connection.BearerTypeCloud:
                                return "qrc:/icons/connections/cloud.svg"
                            case Connection.BearerTypeLoopback:
                                return "qrc:/icons/connections/network-wired.svg"
                            }
                            return ""
                        }

                        tertiaryIconName: model.secure ? "qrc:/icons/connections/network-secure.svg" : ""
                        secondaryIconName: !model.online ? "qrc:/icons/connections/cloud-error.svg" : ""
                        secondaryIconColor: "red"
                        canDelete: root.nymeaEngine.jsonRpcClient.currentConnection !== nymeaHost.connections.get(index)
                        onDeleteClicked: {
                            root.nymeaHost.connections.removeConnection(root.nymeaHost.connections.get(index))
                            nymeaDiscovery.cacheHost(nymeaHost)
                        }

                        onClicked: {
                            print("selecting", root.nymeaHost.connections.get(index))
                            root.connectionSelected(root.nymeaHost.connections.get(index))
                            root.close()
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.columnSpan: 2
            Button {
                text: qsTr("Add")
                onClicked: {
                    var popup = addManualConnectionComponent.createObject(root.parent)
                    popup.open();
                    popup.accepted.connect(function() {
                        root.nymeaHost.connections.addConnection(popup.rpcUrl, Connection.BearerTypeWan, popup.sslEnabled, "Manual connection", true)
                    })
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Close")
                onClicked: {
                    root.close()
                }
            }
        }

    }

    Component {
        id: addManualConnectionComponent
        NymeaDialog {
            id: addManualConnectionDialog
            standardButtons: Dialog.Ok | Dialog.Cancel
            property alias rpcUrl: manualEntry.rpcUrl
            property alias sslEnabled: manualEntry.sslEnabled
            ManualConnectionEntry {
                id: manualEntry
            }
        }
    }
}
