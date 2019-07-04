import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property Device device: null
    property var filterTypeIds: []

    header: NymeaHeader {
        text: qsTr("History for %1").arg(root.device.name)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/filters.svg"
            color: logsModelNg.filterEnabled ? app.accentColor : keyColor
            onClicked: logsModelNg.filterEnabled = !logsModelNg.filterEnabled
            visible: root.filterTypeIds.length === 0
        }
    }

    LogsModelNg {
        id: logsModelNg
        engine: _engine
        deviceId: root.device.id
        typeIds: root.filterTypeIds.length > 0
                 ? root.filterTypeIds
                 : filterEnabled
                   ? [filterDeviceModel.getData(filterComboBox.currentIndex, DeviceModel.RoleId)]
                   : []
        live: true

        property bool filterEnabled: false
    }

    DeviceModel {
        id: filterDeviceModel
        device: root.device
    }

    Pane {
        id: filterPane
        anchors { left: parent.left; top: parent.top; right: parent.right }
        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }

        height: logsModelNg.filterEnabled ? implicitHeight + app.margins * 2 : 0
        Material.elevation: 1

        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        contentItem: Rectangle {
            color: app.primaryColor
            clip: true
            RowLayout {
                anchors.fill: parent
                anchors.margins: app.margins
                spacing: app.margins
                Label {
                    text: qsTr("Filter by")
                }

                ComboBox {
                    id: filterComboBox
                    Layout.fillWidth: true
                    textRole: "displayName"
                    model: filterDeviceModel
                }
            }
        }
    }

    Loader {
        id: graphLoader
        anchors {
            left: parent.left
            top: filterPane.bottom
            right: parent.right
        }

        readonly property StateType stateType: root.device.deviceClass.stateTypes.getStateType(root.filterTypeIds[0])

        readonly property bool canShowGraph: {
            if (stateType === null) {
                return false
            }

            if (stateType.unit === Types.UnitUnixTime) {
                return false;
            }

            switch (stateType.type) {
            case "Int":
            case "Double":
                return true;
            case "Bool":
                return engine.jsonRpcClient.ensureServerVersion("1.10")
            }
            print("not showing graph for", root.stateType.type)
            return false;
        }

        Component.onCompleted: {
            if (root.filterTypeIds.length === 0) {
                return;
            }
            if (!canShowGraph) {
                return;
            }

            var source;
            if (engine.jsonRpcClient.ensureServerVersion("1.10")) {
                source = Qt.resolvedUrl("../customviews/GenericTypeGraph.qml");
            } else {
                source = Qt.resolvedUrl("../customviews/GenericTypeGraphPre110.qml");
            }
            setSource(source, {device: root.device, stateType: stateType})
        }
    }


    ListView {
        anchors { left: parent.left; top: graphLoader.bottom; right: parent.right; bottom: parent.bottom }
        clip: true
        model: logsModelNg
        ScrollBar.vertical: ScrollBar {}

        BusyIndicator {
            anchors.centerIn: parent
            visible: logsModelNg.busy
        }

        delegate: ItemDelegate {
            id: entryDelegate
            width: parent.width

            property StateType stateType: model.source === LogEntry.LoggingSourceStates ? root.device.deviceClass.stateTypes.getStateType(model.typeId) : null
            property EventType eventType: model.source === LogEntry.LoggingSourceEvents || model.source === LogEntry.LoggingSourceStates ? root.device.deviceClass.eventTypes.getEventType(model.typeId) : null
            property ActionType actionType: model.source === LogEntry.LoggingSourceActions ? root.device.deviceClass.actionTypes.getActionType(model.typeId) : null

            contentItem: RowLayout {
                ColorIcon {
                    Layout.preferredWidth: app.iconSize
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    color: {
                        switch (model.source) {
                        case LogEntry.LoggingSourceStates:
                        case LogEntry.LoggingSourceSystem:
                        case LogEntry.LoggingSourceActions:
                        case LogEntry.LoggingSourceEvents:
                            return app.accentColor
                        case LogEntry.LoggingSourceRules:
                            if (model.loggingEventType === LogEntry.LoggingEventTypeActiveChange) {
                                return model.value === true ? "green" : keyColor
                            }
                            return app.accentColor
                        }
                    }
                    name: {
                        switch (model.source) {
                        case LogEntry.LoggingSourceStates:
                            return "../images/state.svg"
                        case LogEntry.LoggingSourceSystem:
                            return "../images/system-shutdown.svg"
                        case LogEntry.LoggingSourceActions:
                            return "../images/action.svg"
                        case LogEntry.LoggingSourceEvents:
                            return "../images/event.svg"
                        case LogEntry.LoggingSourceRules:
                            return "../images/magic.svg"
                        }
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Label {
                            text: {
                                switch (model.source) {
                                case LogEntry.LoggingSourceStates:
//                                    return entryDelegate.stateType.displayName
                                case LogEntry.LoggingSourceEvents:
                                    return entryDelegate.eventType.displayName
                                case LogEntry.LoggingSourceActions:
                                    return entryDelegate.actionType.displayName
                                }
                            }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Label {
                            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy hh:mm:ss")
                            elide: Text.ElideRight
                            font.pixelSize: app.smallFont
                            enabled: false
                        }
                    }

                    RowLayout {
                        Loader {
                            id: valueLoader
                            Layout.fillWidth: true
                            sourceComponent: {
                                switch (model.source) {
                                case LogEntry.LoggingSourceStates:
                                    switch (entryDelegate.stateType.type.toLowerCase()) {
                                    case "bool":
                                        return boolComponent;
                                    case "color":
                                        return colorComponent
                                    default:
                                        if (entryDelegate.stateType.unit == Types.UnitUnixTime) {
                                            return dateTimeComponent
                                        }

                                        return labelComponent

                                    }
                                case LogEntry.LoggingSourceActions:

                                    break;
                                case LogEntry.LoggingSourceEvents:

                                    break;
                                }

                                return labelComponent
                            }
                            Binding { target: valueLoader.item; property: "value"; value: model.value }
                            Binding {
                                target: entryDelegate.stateType && valueLoader.item.hasOwnProperty("unitString") ? valueLoader.item : null;
                                property: "unitString"
                                value: entryDelegate.stateType ? entryDelegate.stateType.unitString : ""
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: labelComponent
        Label {
            property var value
            property string unitString
            text: value + " " + unitString
            font.pixelSize: app.smallFont
            elide: Text.ElideRight
        }
    }

    Component {
        id: dateTimeComponent
        Label {
            property var value
            text: Qt.formatDateTime(new Date(value * 1000), Qt.DefaultLocaleShortDate)
        }
    }

    Component {
        id: boolComponent
        Item {
            id: boolLed
            property var value
            Led {
                implicitHeight: app.smallFont
                state: boolLed.value === "true" ? "on" : "off"
            }
        }
    }

    Component {
        id: colorComponent
        Item {
            property var value
            implicitHeight: app.smallFont
            Rectangle {
                height: parent.height
                width: height * 2
                color: parent.value
                //                radius: width / 2
                border.color: app.foregroundColor
                border.width: 1
            }
        }
    }
}
