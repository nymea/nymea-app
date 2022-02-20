import QtQuick 2.9
import Nymea 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

Dialog {
    id: dialog
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    title: qsTr("Box information")

    standardButtons: Dialog.Ok

    property var nymeaHost: null

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
                name: "../images/info.svg"
                color: Style.accentColor
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: dialog.title
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
                    delegate: NymeaSwipeDelegate {
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
                                if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                    return "../images/connections/network-wired.svg"
                                }
                                return "../images/connections/network-wifi.svg";
                            case Connection.BearerTypeBluetooth:
                                return "../images/connections/bluetooth.svg";
                            case Connection.BearerTypeCloud:
                                return "../images/connections/cloud.svg"
                            case Connection.BearerTypeLoopback:
                                return "../images/connections/network-wired.svg"
                            }
                            return ""
                        }

                        tertiaryIconName: model.secure ? "../images/connections/network-secure.svg" : ""
                        secondaryIconName: !model.online ? "../images/connections/cloud-error.svg" : ""
                        secondaryIconColor: "red"

                        onClicked: {
                            dialog.close()
                            engine.jsonRpcClient.connectToHost(dialog.nymeaHost, dialog.nymeaHost.connections.get(index))
                        }
                    }
                }
            }
        }
    }
}
