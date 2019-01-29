import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    id: swipeGroup

    property ListView listView: parent
    QtObject {
        id: d
        property var delegates: swipeGroup.listView.contentItem.children
        property var delegateCache: []

        onDelegatesChanged: {
            for (var i = 0; i < d.delegates.length; i++) {
                var thisItem = d.delegates[i];
                if (!thisItem.hasOwnProperty("swipe")) {
                    continue;
                }
                if (d.delegateCache.indexOf(thisItem) < 0) {
                    d.delegateCache.push(thisItem);

                    print("cache is now", d.delegateCache.length)

                    thisItem.Component.destruction.connect(function() {
                        print("item destroyed", thisItem)
                        var idx = d.delegateCache.indexOf(thisItem)
                        d.delegateCache.splice(idx, 1)
                        print("cache is now", d.delegateCache.length)
                    })

                    thisItem.swipe.opened.connect(function() {
                        for (var j = 0; j < d.delegates.length; j++) {
                            var otherItem = d.delegates[j];
                            if (thisItem === otherItem) {
                                continue;
                            }
                            if (!otherItem.hasOwnProperty("swipe")) {
                                continue;
                            }
                            otherItem.swipe.close();
                        }
                    })
                }
            }
        }
    }
}
