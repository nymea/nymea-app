import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Developer options")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

            Label {
                Layout.fillWidth: true
                text: qsTr("Cloud environment")
            }

            ComboBox {
                currentIndex: model.indexOf(app.settings.cloudEnvironment)
                model: AWSClient.availableConfigs
                onActivated: {
                    app.settings.cloudEnvironment = model[index];
                }
            }
        }

        CheckDelegate {
            text: qsTr("Enable app logging")
            enabled: AppLogController.canWriteLogs
            checked: AppLogController.enabled
            onCheckedChanged: AppLogController.enabled = checked;
            Layout.fillWidth: true
        }

        MeaListItemDelegate {
            Layout.fillWidth: true
            text: qsTr("View log")
            onClicked: pageStack.push(appLogComponent)
            enabled: AppLogController.enabled
        }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins

            Label {
                Layout.fillWidth: true
                text: qsTr("Experience mode")
            }

            ComboBox {
                currentIndex: model.indexOf(styleController.currentExperience)
                model: styleController.allExperiences
                onActivated: {
                    styleController.currentExperience = model[index]
                }
            }
        }
    }

    Component {
        id: appLogComponent
        Page {
            header: GuhHeader {
                text: qsTr("App log")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ScrollView {
                anchors.fill: parent

                TextArea {
                    id: logArea
                    wrapMode: Text.WordWrap
                    readOnly: true
                    font.pixelSize: app.smallFont

                    Component.onCompleted: {
                        text = AppLogController.content
                    }
                    Connections {
                        target: AppLogController
                        onContentAdded: {
                            logArea.append(newContent)
                        }
                    }
                }
            }
        }
    }
}
