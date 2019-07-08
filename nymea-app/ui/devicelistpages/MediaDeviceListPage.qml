import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import QtGraphicalEffects 1.0
import "../components"

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Media")
        onBackPressed: pageStack.pop()
    }

    ListView {
        anchors.fill: parent
        model: root.devicesProxy

        delegate: ItemDelegate {
            id: itemDelegate
            width: parent.width

            property bool inline: width > 500

            property Device device: devicesProxy.get(index);
            property DeviceClass deviceClass: device.deviceClass

            readonly property StateType playbackStateType: deviceClass.stateTypes.findByName("playbackStatus")
            readonly property State playbackState: playbackStateType ? device.states.getState(playbackStateType.id) : null

            bottomPadding: index === ListView.view.count - 1 ? topPadding : 0
            contentItem: Pane {
                id: contentItem
                Material.elevation: 2
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0

                contentItem: ItemDelegate {
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    contentItem: ColumnLayout {
                        spacing: 0
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.mediumFont + app.margins
                            color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .05)
                            RowLayout {
                                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; margins: app.margins }
                                Label {
                                    Layout.fillWidth: true
                                    text: model.name
                                    elide: Text.ElideRight
                                }
                                ColorIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    name: "../images/battery/battery-020.svg"
                                    visible: itemDelegate.deviceClass.interfaces.indexOf("battery") >= 0 && itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("batteryCritical").id).value === true
                                }
                                ColorIcon {
                                    Layout.preferredHeight: app.iconSize * .5
                                    Layout.preferredWidth: height
                                    name: "../images/dialog-warning-symbolic.svg"
                                    visible: itemDelegate.deviceClass.interfaces.indexOf("connectable") >= 0 && itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("connected").id).value === false
                                    color: "red"
                                }
                            }

                        }
                        RowLayout {
                            ColumnLayout {
                                id: leftColummn
                                Layout.margins: app.margins
                                Label {
                                    Layout.fillWidth: true
                                    text: itemDelegate.playbackState.value === "Stopped" ?
                                              qsTr("No playback")
                                            : itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("title").id).value
                                    horizontalAlignment: Text.AlignHCenter
//                                    font.pixelSize: app.largeFont
                                    elide: Text.ElideRight
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("artist").id).value
                                    font.pixelSize: app.smallFont
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: itemDelegate.device.states.getState(itemDelegate.deviceClass.stateTypes.findByName("collection").id).value
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: app.smallFont
                                    elide: Text.ElideRight
                                }
                                MediaControls {
                                    visible: itemDelegate.deviceClass.interfaces.indexOf("mediacontroller") >= 0
                                    device: itemDelegate.device
                                }
                            }
                            Item {
                                Layout.preferredHeight: leftColummn.height + app.margins * 2
                                Layout.preferredWidth: height * .7

                                Item {
                                    id: artworkContainer
                                    anchors.fill: parent
                                    Image {
                                        id: artworkImage
                                        width: artworkImage.sourceSize.width * height / artworkImage.sourceSize.height
                                        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
                                        readonly property StateType artworkStateType: device ? device.deviceClass.stateTypes.findByName("artwork") : null
                                        readonly property State artworkState: artworkStateType ? device.states.getState(artworkStateType.id) : null
                                        source: artworkState ? artworkState.value : ""
                                    }
                                }

                                Rectangle {
                                    id: maskRect
                                    anchors.centerIn: parent
                                    height: parent.width
                                    width: parent.height
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "transparent" }
                                        GradientStop { position: 1; color: "red" }
                                    }
                                }

                                ShaderEffect {
                                    anchors.fill: parent
                                    property variant source: ShaderEffectSource {
                                        sourceItem: artworkContainer
                                        hideSource: true
                                    }
                                    property variant mask: ShaderEffectSource {
                                        sourceItem: maskRect
                                        hideSource: true
                                    }

                                    fragmentShader: "
                                        varying highp vec2 qt_TexCoord0;
                                        uniform sampler2D source;
                                        uniform sampler2D mask;
                                        void main(void)
                                        {
                                            highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                                            highp float alpha = texture2D(mask, vec2(qt_TexCoord0.y, qt_TexCoord0.x)).a;
                                            sourceColor *= alpha;
                                            gl_FragColor = sourceColor;
                                        }
                                        "
                                }
                            }
                        }
                    }
                    onClicked: {
                        enterPage(index, false)
                    }
                }
            }
        }
    }
}
