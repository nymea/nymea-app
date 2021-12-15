import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

AutoSizeMenu {
    id: root

    property Thing thing: null

    property bool showDetails: true
    property bool showLogs: true

    Component.onCompleted: {
        if (Configuration.magicEnabled) {
            root.addItem(menuEntryComponent.createObject(root, {text: qsTr("Magic"), iconSource: "../images/magic.svg", functionName: "openThingMagicPage"}))
        }

        if (root.showDetails) {
            root.addItem(menuEntryComponent.createObject(root, {text: qsTr("Details"), iconSource: "../images/info.svg", functionName: "openGenericThingPage"}))
        }
//            root.addItem(menuEntryComponent.createObject(root, {text: qsTr("Settings"), iconSource: "../images/configure.svg", functionName: "openThingSettingsPage"}))
        if (root.showLogs) {
            root.addItem(menuEntryComponent.createObject(root, {text: qsTr("Logs"), iconSource: "../images/logs.svg", functionName: "openThingLogPage"}))
        }

        root.addItem(menuEntryComponent.createObject(root,
            {
                text: Qt.binding(function() { return favoritesProxy.count === 0 ? qsTr("Mark as favorite") : qsTr("Remove from favorites")}),
                iconSource: Qt.binding(function() { return favoritesProxy.count === 0 ? "../images/starred.svg" : "../images/non-starred.svg"}),
                functionName: "toggleFavorite"
            }))

        root.addItem(menuEntryComponent.createObject(root,
            {
                text: qsTr("Grouping"),
                iconSource: "../images/groups.svg",
                functionName: "addToGroup"
            }))

        print("*** creating menu")
        print("NFC", NfcHelper.isAvailable)
        if (NfcHelper.isAvailable) {
            root.addItem(menuEntryComponent.createObject(root,
                {
                    text: qsTr("Write NFC tag"),
                    iconSource: "../images/nfc.svg",
                    functionName: "writeNfcTag"

                }));
        }
    }

    function openThingMagicPage() {
        pageStack.push(Qt.resolvedUrl("../magic/ThingRulesPage.qml"), {thing: root.thing})
    }
    function openGenericThingPage() {
        pageStack.push(Qt.resolvedUrl("../devicepages/GenericDevicePage.qml"), {thing: root.thing})
    }
    function toggleFavorite() {
        if (favoritesProxy.count === 0) {
            engine.tagsManager.tagThing(root.thing.id, "favorites", 100000)
        } else {
            engine.tagsManager.untagThing(root.thing.id, "favorites")
        }
    }
    function addToGroup() {
        var dialog = addToGroupDialog.createObject(root.parent)
        dialog.open();
    }

    function openThingSettingsPage() {
        pageStack.push(Qt.resolvedUrl("../thingconfiguration/ConfigureThingPage.qml"), {thing: root.thing})
    }

    function openThingLogPage() {
        pageStack.push(Qt.resolvedUrl("../devicepages/DeviceLogPage.qml"), {thing: root.thing });
    }

    function writeNfcTag() {
        pageStack.push(Qt.resolvedUrl("../magic/WriteNfcTagPage.qml"), {thing: root.thing})
    }

    TagsProxyModel {
        id: favoritesProxy
        tags: engine.tagsManager.tags
        filterThingId: root.thing.id
        filterTagId: "favorites"
    }

    Component {
        id: menuEntryComponent
        IconMenuItem {
            width: parent.width
            property string functionName: ""
            onTriggered: root[functionName]()
        }
    }

    Component {
        id: addToGroupDialog
        MeaDialog {
            title: qsTr("Groups for %1").arg(root.thing.name)
            headerIcon: "../images/groups.svg"
            // NOTE: If CloseOnPressOutside is active (default) it will break the QtVirtualKeyboard
            // https://bugreports.qt.io/browse/QTBUG-56918
            closePolicy: Popup.CloseOnEscape

            RowLayout {
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                spacing: app.margins
                TextField {
                    id: newGroupdTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("New group")
                }
                Button {
                    text: qsTr("OK")
                    enabled: newGroupdTextField.displayText.length > 0 && !groupTags.containsId("group-" + newGroupdTextField.displayText)
                    onClicked: {
                        engine.tagsManager.tagThing(root.thing.id, "group-" + newGroupdTextField.text, 1000)
                        newGroupdTextField.text = ""
                    }
                }
            }


            ListView {
                Layout.fillWidth: true
                height: 200
                clip: true
                ScrollIndicator.vertical: ScrollIndicator {}

                model: TagListModel {
                    id: groupTags
                    tagsProxy: TagsProxyModel {
                        tags: engine.tagsManager.tags
                        filterTagId: "group-.*"
                    }
                }

                delegate: CheckDelegate {
                    width: parent.width
                    text: model.tagId.substring(6)
                    checked: innerProxy.count > 0
                    onClicked: {
                        if (innerProxy.count == 0) {
                            engine.tagsManager.tagThing(root.thing.id, model.tagId, 1000)
                        } else {
                            engine.tagsManager.untagThing(root.thing.id, model.tagId, model.value)
                        }
                    }
                    ThingsProxy {
                        id: innerProxy
                        engine: _engine
                        filterTagId: model.tagId
                        filterThingId: root.thing.id
                    }
                }
            }
        }
    }
}
