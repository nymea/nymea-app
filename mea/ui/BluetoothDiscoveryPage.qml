import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "components"
import Mea 1.0


Page {
    id: root
    header: GuhHeader {
        text: qsTr("Bluetooth discovery")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("images/refresh.svg")
            onClicked: Engine.bluetoothDiscovery.start()
        }
    }

    Component.onCompleted: Engine.bluetoothDiscovery.start()

    ColumnLayout {
        anchors.fill: parent
        spacing: app.margins

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: Engine.bluetoothDiscovery.discovering
        }

        ThinDivider { }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: Engine.bluetoothDiscovery.deviceInfos
            clip: true

            delegate: ItemDelegate {
                width: parent.width
                height: app.delegateHeight

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        ColorIcon {
                            id: image
                            name: Qt.resolvedUrl("images/bluetooth.svg")
                            anchors.fill: parent
                            anchors.margins: app.margins / 2
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        anchors.margins: app.margins
                        Label {
                            text: model.name
                        }
                        Label {
                            text: model.address
                            font.pixelSize: app.smallFont
                        }
                    }
                }

                onClicked: {
                    print("Start bluetooth connection to", model.name, " --> ", model.address)
                    Engine.bluetoothDiscovery.stop()
                    pageStack.push(Qt.resolvedUrl("BluetoothLoadingPage.qml"), { name: model.name, address: model.address } )
                }
            }
        }
    }
}
