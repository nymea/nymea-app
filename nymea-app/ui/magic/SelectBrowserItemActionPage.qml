import QtQuick 2.4
import QtQuick.Controls 2.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property Device device: null
    property string itemId: ""

    signal selected(string selectedItemId)

    header: NymeaHeader {
        onBackPressed: pageStack.pop()
        text: qsTr("Select item")
    }

    Component.onCompleted: {
        listView.model = engine.deviceManager.browseDevice(root.device.id, root.itemId)
    }

    ListView {
        id: listView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        delegate: BrowserItemDelegate {
            width: parent.width
            device: root.device
            secondaryIconName: "" // We don't support BrowserItemActions in rules yet

            onClicked: {
                if (model.browsable) {
                    var page = pageStack.push(Qt.resolvedUrl("SelectBrowserItemActionPage.qml"), {device: root.device, itemId: model.id});
                    page.selected.connect(function(selectedItemId) {
                        pageStack.pop();
                        root.selected(selectedItemId);
                    })
                } else if (model.executable) {
                    pageStack.pop();
                    print("selected:", model.id)
                    root.selected(model.id);
                }
            }
        }
    }
}
