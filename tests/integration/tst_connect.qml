import QtQuick 2.8
import QtQuick.Controls 2.1
import QtTest 1.0
import Mea 1.0
import "qrc:/ui"

TestCase {
    id: root
    name: "MathTests"

    Mea {
        id: mea
        settings: Item {
            property string lastConnectedHost: ""
            property int viewMode: ApplicationWindow.Windowed
            property bool returnToHome: false
            property bool darkTheme: false
            property string graphStyle: "bars"
            property string style: "light"
        }
    }

    // TODO: take those from cmdline args
    property string serverIP: "10.10.10.40"


    // TODO: move this to a common import location
    // Keeps executing a given parameter-less function until it returns the given
    // expected result or the timemout is reached (in which case a test failure
    // is generated)
    function tryCompareFunction(func, expectedResult, timeout, message) {
        var timeSpent = 0
        if (timeout === undefined)
            timeout = 5000;
        var success = false
        var actualResult
        while (timeSpent < timeout && !success) {
            actualResult = func()
            success = qtest_compareInternal(actualResult, expectedResult)
            if (success === false) {
                wait(50)
                timeSpent += 50
            }
        }

        var act = qtest_results.stringify(actualResult)
        var exp = qtest_results.stringify(expectedResult)
        compare(act, exp, message || "function returned unexpected result")
    }

    function settleUi() {
        var pageStack = findChild(mea, "pageStack")
        tryCompare(pageStack, "busy", true)
        tryCompare(pageStack, "busy", false)
    }

    function initTestCase() {
        settleUi();
    }

    function typeString(txt) {
        for (var i = 0; i < txt.length; i++) {
            keyClick(txt[i])
        }
    }

    function test_discovery() {
//        var discovery = findChild(mea, "discovery");

//        tryCompareFunction(function() {
//            for (var i = 0; i < discovery.discoveryModel.count; i++) {
//                if (discovery.discoveryModel.get(i, DiscoveryModel.HostAddressRole) === serverIP) {
//                    return true;
//                }
//            }
//            return false;
//        }, true, 10000, "Failed to discover host " + serverIP + " in 10 seconds")

//        var discoveryPage = findChild(mea, "discoveryPage");
//        var delegate = null;
//        for (var i = 0; i < discovery.discoveryModel.count; i++) {
//            var tmp = findChild(discoveryPage, "discoveryDelegate" + i);
//            print("have delegate", discoveryPage, tmp, tmp.hostAddress)
//            if (tmp.hostAddress === serverIP) {
//                delegate = tmp;
//            }
//        }
//        verify(delegate !== null, "Could not find delegate for host " + serverIP)

//        mouseClick(delegate)

//        tryCompare(Engine.connection, "connected", true)
    }

    function test_manualConnection() {
        var manualConnectItem = findChild(mea, "manualConnectMenuItem");
        var headerMenuButton = findChild(mea, "headerMenuButton")

        var connMenu = findChild(mea, "connectionMenu")
        mouseClick(headerMenuButton)
        tryCompare(connMenu, "visible", true)
        mouseClick(manualConnectItem)

        settleUi();

        var manualConnectPage = findChild(mea, "manualConnectPage");

        var addressInput = findChild(manualConnectPage, "addressTextInput")
        mouseClick(addressInput)

        typeString(serverIP)
        keyClick(Qt.Key_Tab)
        typeString("2223")

        var connectButton = findChild(manualConnectPage, "connectButton");
        mouseClick(connectButton)

        tryCompare(Engine.connection, "connected", true)
    }
}

