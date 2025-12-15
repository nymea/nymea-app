import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root

    property EnergyManager energyManager: null

    property ThingsProxy consumers: ThingsProxy {
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
    }

    property var colors: null

    property int tickCount: 5

    property int labelsWidth: 40


    QtObject {
        id: d
        property int topMargin: Style.margins
        property int bottomMargin: Style.margins
        property int leftMargin: Style.margins
        property int rightMargin: Style.margins
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.smallMargins
        Label {
            text: qsTr("Consumers")
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            id: valueAxis
            Layout.fillWidth: true
            Layout.fillHeight: true

            property double max: Math.ceil(root.energyManager.currentPowerConsumption / 100) * 100
            Repeater {
                model: root.tickCount
                delegate: RowLayout {
                    width: parent.width - d.leftMargin - d.rightMargin
                    y: index * ((parent.height - d.topMargin - d.bottomMargin - Style.iconSize - Style.margins) / (root.tickCount - 1)) - height / 2 + d.topMargin
                    x: d.leftMargin
                    Label {
                        property double value: (valueAxis.max - index * (valueAxis.max / (root.tickCount - 1)))
                        text: (value >= 1000 ? (value / 1000).toFixed(2) : value.toFixed(1)) + (value >= 1000 ? "kW" : "W")
                        font: Style.extraSmallFont
                        Layout.preferredWidth: root.labelsWidth
                    }
                    Rectangle {
                        Layout.preferredHeight: 1
                        Layout.fillWidth: true
                        color: Style.tileOverlayColor
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.topMargin: d.topMargin
                anchors.leftMargin: root.labelsWidth + d.leftMargin
                anchors.bottomMargin: d.bottomMargin
                anchors.rightMargin: d.rightMargin

                Repeater {
                    model: consumers.count + 1

                    delegate: ColumnLayout {
                        id: consumerDelegate
                        Layout.fillHeight: true
                        Layout.preferredWidth: root.width / consumers.count
                        spacing: Style.margins
                        property Thing thing: consumers.get(index)
                        property State currentPowerState: thing ? thing.stateByName("currentPower") : null

                        property double consumption: {
                            var consumption = 0
                            if (thing) {
                                consumption = currentPowerState.value
                            } else {
                                consumption = energyManager.currentPowerConsumption
                                for (var i = 0; i < consumers.count; i++) {
                                    consumption -= consumers.get(i).stateByName("currentPower").value
                                }
                            }
                            return consumption;
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle {
                                id: bar
                                anchors {
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                    top: parent.top
                                }
                                gradient: Gradient {
                                    GradientStop { position: 1; color: Style.green }
                                    GradientStop { position: 0.5; color: Style.orange }
                                    GradientStop { position: 0; color: Style.red }
                                }
                                width: 20
                                visible: false
                            }

                            Item {
                                id: barMask
                                anchors.fill: bar
                                Rectangle {
                                    anchors {
                                        bottom: parent.bottom
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    width: 20
                                    Behavior on height { NumberAnimation { duration: Style.slowAnimationDuration; easing.type: Easing.InOutQuad } }
                                    height: Math.max(1, parent.height * consumerDelegate.consumption / valueAxis.max)
                                    //                                    visible: false
                                }
                            }


                            OpacityMask {
                                anchors.fill: bar
                                source: bar
                                maskSource: barMask
                            }

                            Label {
                                anchors.bottom: bar.bottom
                                anchors.left: bar.left
                                text: consumerDelegate.thing ? consumerDelegate.thing.name : qsTr("Unknown")
                                transform: Rotation {
                                    angle: -90
                                }
                            }

                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.iconSize

                            ColorIcon {
                                anchors.centerIn: parent
                                name: consumerDelegate.thing ? app.interfacesToIcon(consumerDelegate.thing.thingClass.interfaces) : "energy"
                                color: root.colors[index % root.colors.length]
                            }
                        }
                    }
                }
            }
        }
    }
}
