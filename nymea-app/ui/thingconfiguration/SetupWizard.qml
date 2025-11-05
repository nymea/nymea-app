/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    property ThingClass thingClass: thing ? thing.thingClass : null

    // Optional: If set, it will be reconfigred, otherwise a new one will be created
    property Thing thing: null

    signal aborted();
    signal done();

    QtObject {
        id: d
        property var vendorId: null
        property ThingDescriptor thingDescriptor: null
        property var discoveryParams: []
        property string thingName: ""
        property int pairRequestId: 0
        property var pairingTransactionId: null
        property int addRequestId: 0
        property string name: ""
        property var params: []

        function pairThing() {
            print("setupMethod", root.thingClass.setupMethod)

            switch (root.thingClass.setupMethod) {
            case 0:
                if (root.thing) {
                    if (d.thingDescriptor) {
                        engine.thingManager.reconfigureDiscoveredThing(d.thingDescriptor.id, params);
                    } else {
                        engine.thingManager.reconfigureThing(root.thing.id, params);
                    }
                } else {
                    if (d.thingDescriptor) {
                        engine.thingManager.addDiscoveredThing(root.thingClass.id, d.thingDescriptor.id, d.name, params);
                    } else {
                        engine.thingManager.addThing(root.thingClass.id, d.name, params);
                    }
                }
                break;
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
                if (root.thing) {
                    if (d.thingDescriptor) {
                        engine.thingManager.pairDiscoveredThing(d.thingDescriptor.id, params, d.name);
                    } else {
                        engine.thingManager.rePairThing(root.thing.id, params, d.name);
                    }
                    return;
                } else {
                    if (d.thingDescriptor) {
                        engine.thingManager.pairDiscoveredThing(d.thingDescriptor.id, params, d.name);
                    } else {
                        engine.thingManager.pairThing(root.thingClass.id, params, d.name);
                    }
                }

                break;
            }

            busyOverlay.shown = true;

        }
    }

    Component.onCompleted: {
        print("Starting setup wizard. Create Methods:", root.thingClass.createMethods, "Setup method:", root.thingClass.setupMethod)
        if (root.thingClass.createMethods.indexOf("CreateMethodDiscovery") !== -1) {
            print("CreateMethodDiscovery")
            if (thingClass["discoveryParamTypes"].count > 0) {
                print("Discovery params:", thingClass.discoveryParamTypes.count)
                internalPageStack.push(discoveryParamsPage)
            } else {
                print("Starting discovery...")
                internalPageStack.push(discoveryPage, {thingClass: thingClass})
                discovery.discoverThings(thingClass.id)
            }
        } else if (root.thingClass.createMethods.indexOf("CreateMethodUser") !== -1) {
            print("CreateMethodUser")
            // Setting up a new thing
            if (!root.thing) {
                print("New thing setup")
                internalPageStack.push(paramsPage)

                // Reconfigure
            } else if (root.thing) {
                print("Existing thing")
                // There are params. Open params page in any case
                if (root.thingClass.paramTypes.count > 0) {
                    print("Params:", root.thingClass.paramTypes.count)
                    internalPageStack.push(paramsPage)

                    // No params... go straight to reconfigure/repair
                } else {
                    print("no params")
                    switch (root.thingClass.setupMethod) {
                    case 0:
                        print("reconfiguring...")
                        // This totally does not make sense... Maybe we should hide the reconfigure button if there are no params?
                        engine.thingManager.reconfigureThing(root.thing.id, [])
                        busyOverlay.shown = true;
                        break;
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                        print("re-pairing", root.thing.id)
                        engine.thingManager.rePairThing(root.thing.id, []);
                        break;
                    default:
                        console.warn("Unhandled setup method!")
                    }
                }
            }
        }
    }

    Connections {
        target: engine.thingManager
        onPairThingReply: {
            busyOverlay.shown = false
            if (thingError !== Thing.ThingErrorNoError) {
                busyOverlay.shown = false;
                internalPageStack.push(resultsPage, {thingError: thingError, message: displayMessage});
                return;

            }

            d.pairingTransactionId = pairingTransactionId;

            switch (setupMethod) {
            case "SetupMethodPushButton":
            case "SetupMethodDisplayPin":
            case "SetupMethodEnterPin":
            case "SetupMethodUserAndPassword":
                internalPageStack.push(pairingPageComponent, {text: displayMessage, setupMethod: setupMethod})
                break;
            case "SetupMethodOAuth":
                internalPageStack.push(oAuthPageComponent, {oAuthUrl: oAuthUrl})
                break;
            default:
                print("Setup method reply not handled:", setupMethod);
            }
        }
        onConfirmPairingReply: {
            busyOverlay.shown = false
            internalPageStack.push(resultsPage, {thingError: thingError, thingId: thingId, message: displayMessage})
        }
        onAddThingReply: {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {thingError: thingError, thingId: thingId, message: displayMessage})
        }
        onReconfigureThingReply: {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {thingError: thingError, thingId: root.thing.id, message: displayMessage})
        }
    }

    ThingDiscovery {
        id: discovery
        engine: _engine
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
    }
    property QtObject pageStack: QtObject {
        function pop(item) {
            if (internalPageStack.depth > 1) {
                internalPageStack.pop(item)
            } else {
                root.aborted()
            }
        }
    }

    Component {
        id: discoveryParamsPage
        SettingsPageBase {
            id: discoveryParamsView
            title: qsTr("Discover %1").arg(root.thingClass.displayName)

            SettingsPageSectionHeader {
                text: qsTr("Discovery options")
            }

            Repeater {
                id: paramRepeater
                model: root.thingClass ? root.thingClass.discoveryParamTypes : null
                delegate: ParamDelegate {
                    Layout.fillWidth: true
                    paramType: root.thingClass.discoveryParamTypes.get(index)
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: "Next"
                onClicked: {
                    var paramTypes = root.thingClass.discoveryParamTypes;
                    d.discoveryParams = [];
                    for (var i = 0; i < paramTypes.count; i++) {
                        var param = {};
                        param["paramTypeId"] = paramTypes.get(i).id;
                        param["value"] = paramRepeater.itemAt(i).value
                        d.discoveryParams.push(param);
                    }
                    discovery.discoverThings(root.thingClass.id, d.discoveryParams)
                    internalPageStack.push(discoveryPage, {thingClass: root.thingClass})
                }
            }
        }
    }

    Component {
        id: discoveryPage

        SettingsPageBase {
            id: discoveryView

            header: NymeaHeader {
                text: qsTr("Discover %1").arg(root.thingClass.displayName)
                backButtonVisible: true
                onBackPressed: pageStack.pop()

                HeaderButton {
                    imageSource: "qrc:/icons/configure.svg"
                    visible: root.thingClass.createMethods.indexOf("CreateMethodUser") >= 0
                    text: qsTr("Add thing manually")
                    onClicked: internalPageStack.push(paramsPage)
                }
            }

            property ThingClass thingClass: null

            SettingsPageSectionHeader {
                text: qsTr("Nymea found the following things")
                visible: !discovery.busy && discoveryProxy.count > 0
            }

            Repeater {
                model: ThingDiscoveryProxy {
                    id: discoveryProxy
                    thingDiscovery: discovery
                    showAlreadyAdded: root.thing !== null
                    showNew: root.thing === null
                    filterThingId: root.thing ? root.thing.id : ""
                }
                delegate: NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: model.name
                    subText: model.description
                    iconName: app.interfacesToIcon(discoveryView.thingClass.interfaces)
                    onClicked: {
                        d.thingDescriptor = discoveryProxy.get(index);
                        d.thingName = model.name;
                        internalPageStack.push(paramsPage)
                    }
                }
            }

            busy: discovery.busy
            busyText: qsTr("Searching for things...")

            ColumnLayout {
                visible: !discovery.busy && discoveryProxy.count === 0
                spacing: app.margins
                Layout.preferredHeight: discoveryView.height - discoveryView.header.height - retryButton.height - app.margins * 3
                Label {
                    text: qsTr("Too bad...")
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    text: qsTr("No things of this kind could be found...")
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    horizontalAlignment: Text.AlignHCenter
                    text: discovery.displayMessage.length === 0 ?
                              qsTr("Make sure your things are set up and connected, try searching again or go back and pick a different kind of thing.")
                            : discovery.displayMessage
                    wrapMode: Text.WordWrap
                }

            }
            Button {
                id: retryButton
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Search again")
                onClicked: discovery.discoverThings(root.thingClass.id, d.discoveryParams)
                visible: !discovery.busy
            }
        }
    }

    Component {
        id: paramsPage

        SettingsPageBase {
            id: paramsView
            title: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Set up %1").arg(root.thingClass.displayName)

            SettingsPageSectionHeader {
                text: qsTr("Name the thing:")
                visible: root.thing ? false : true
            }

            TextField {
                id: nameTextField
                visible: root.thing ? false : true
                text: (d.thingName ? d.thingName : root.thingClass.displayName)
                      + (root.thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/) ? " (" + PlatformHelper.machineHostname + ")" : "")
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
            }

            SettingsPageSectionHeader {
                text: qsTr("Thing parameters")
                visible: paramRepeater.count > 0
            }

            Component.onCompleted: {
                if (root.thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/)) {
                    console.warn("checking Notification permission!")
                    if (PlatformPermissions.notificationsPermission != PlatformPermissions.PermissionStatusGranted) {
                        console.warn("Notification permission missing!")
                        PlatformPermissions.requestPermission(PlatformPermissions.PermissionNotifications)
                    }
                }
            }

            Repeater {
                id: paramRepeater
                model: engine.jsonRpcClient.ensureServerVersion("1.12") || d.thingDescriptor == null ?  root.thingClass.paramTypes : null
                delegate: ParamDelegate {
                    //                            Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    enabled: !model.readOnly
                    paramType: root.thingClass.paramTypes.get(index)
                    value: {
                        // Discovery, use params from discovered descriptor
                        if (d.thingDescriptor && d.thingDescriptor.params.getParam(paramType.id)) {
                            return d.thingDescriptor.params.getParam(paramType.id).value
                        }

                        // Special hook for push notifications as we need to provide the token etc implicitly
                        print("Setting up params for thing class:", root.thingClass.id, root.thingClass.name)
                        if (root.thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/)) {
                            if (paramType.id.toString().match(/\{?3cb8e30e-2ec5-4b4b-8c8c-03eaf7876839\}?/)) {
                                return PushNotifications.service;
                            }
                            if (paramType.id.toString().match(/\{?12ec06b2-44e7-486a-9169-31c684b91c8f\}?/)) {
                                return PushNotifications.token;
                            }
                            if (paramType.id.toString().match(/\{?d76da367-64e3-4b7d-aa84-c96b3acfb65e\}?/)) {
                                return PushNotifications.clientId + "+" + Configuration.appId;
                            }
                        }

                        // Manual setup, use default value from thing class
                        return root.thingClass.paramTypes.get(index).defaultValue
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins

                text: "OK"
                onClicked: {
                    var params = []
                    for (var i = 0; i < paramRepeater.count; i++) {
                        var param = {}
                        var paramType = paramRepeater.itemAt(i).paramType
                        if (!paramType.readOnly) {
                            param.paramTypeId = paramType.id
                            param.value = paramRepeater.itemAt(i).value
                            print("adding param", param.paramTypeId, param.value)
                            params.push(param)
                        }
                    }

                    d.params = params
                    d.name = nameTextField.text
                    d.pairThing();
                }
            }
        }
    }

    Component {
        id: pairingPageComponent
        SettingsPageBase {
            id: pairingPage
            title: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Set up %1").arg(root.thingClass.displayName)
            property alias text: textLabel.text

            property string setupMethod

            SettingsPageSectionHeader {
                text: qsTr("Login required")
            }

            Label {
                id: textLabel
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
            }

            TextField {
                id: usernameTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                placeholderText: qsTr("Username")
                visible: pairingPage.setupMethod === "SetupMethodUserAndPassword"
            }

            ConsolinnoPasswordTextField {
                id: pinTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                visible: pairingPage.setupMethod === "SetupMethodDisplayPin" || pairingPage.setupMethod === "SetupMethodEnterPin" || pairingPage.setupMethod === "SetupMethodUserAndPassword"
                signup: false
            }


            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: "OK"
                onClicked: {
                    engine.thingManager.confirmPairing(d.pairingTransactionId, pinTextField.password, usernameTextField.displayText);
                    busyOverlay.shown = true;
                }
            }
        }
    }

    Component {
        id: oAuthPageComponent
        Page {
            id: oAuthPage
            property string oAuthUrl
            header: NymeaHeader {
                text: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Set up %1").arg(root.thingClass.displayName)
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                spacing: app.margins * 2

                Label {
                    Layout.fillWidth: true
                    text: qsTr("OAuth is not supported on this platform. Please use this app on a different device to set up this thing.")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("In order to use OAuth on this platform, make sure qml-module-qtwebview is installed.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Item {
                id: webViewContainer
                anchors.fill: parent

                Component.onCompleted: {
                    // This might fail if qml-module-qtwebview isn't around
                    var webView = Qt.createQmlObject(webViewString, webViewContainer);
                    print("created webView", webView)
                }

                property string webViewString:
                    '
                    import QtQuick 2.8;
                    import QtWebView 1.1;
                    import QtQuick.Controls 2.2
                    import Nymea 1.0;

                    Rectangle {
                        anchors.fill: parent
                        color: Style.backgroundColor

                        BusyIndicator {
                            id: busyIndicator
                            anchors.centerIn: parent
                            running: oAuthWebView.loading
                        }

                        WebView {
                            id: oAuthWebView
                            anchors.fill: parent
                            url: oAuthPage.oAuthUrl

                            function finishProcess(url) {
                                print("Confirm pairing")
                                engine.thingManager.confirmPairing(d.pairingTransactionId, url)
                                busyIndicator.running = true
                                oAuthWebView.visible = false
                            }

                            onUrlChanged: {
                                print("OAUTH URL changed", url)
                                if (url.toString().indexOf("https://127.0.0.1") == 0) {
                                    print("Redirect URL detected!")
                                    finishProcess(url)
                                } else if (url.toString().indexOf("device-complete") >= 0) {
                                    // Unfortunatly device code authentication does not support redirect URLs like tado,
                                    // yet this hack does work for this case when the authentication has been completed.
                                    // The alternative would be a finished button below the webview.
                                    print("Device code finish URL detected!")
                                    finishProcess(url)
                                }
                            }
                        }
                    }
                    '
            }
        }
    }

    Component {
        id: resultsPage

        Page {
            id: resultsView
            header: NymeaHeader {
                text: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Set up %1").arg(root.thingClass.displayName)
                onBackPressed: pageStack.pop()
            }

            property string thingId
            property int thingError
            property string message

            readonly property bool success: thingError === Thing.ThingErrorNoError

            readonly property Thing thing: root.thing ? root.thing : engine.thingManager.things.getThing(thingId)

            ColumnLayout {
                width: Math.min(500, parent.width - app.margins * 2)
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultsView.success ? root.thing ? qsTr("Thing reconfigured!") : qsTr("Thing added!") : qsTr("Uh oh")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.success ? qsTr("All done. You can now start using %1.").arg(resultsView.thing.name) : qsTr("Something went wrong setting up this thing...");
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.message
                }


                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    visible: !resultsView.success
                    text: "Retry"
                    onClicked: {
                        internalPageStack.pop({immediate: true});
                        internalPageStack.pop({immediate: true});
                        d.pairThing();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        root.done();
                    }
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
