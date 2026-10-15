// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Nymea
import NymeaApp.Utils
import Nymea.Rfid

import "../components"

SettingsPageBase {
    id: root
    title: qsTr("RFID charging")

    property string initialUsername: ""

    property int pendingRemoveCommandId: -1
    property RfidTagInfo pendingRemovalTag: null
    property bool initialUserFilterApplied: initialUsername === ""

    function userLabel(userInfo) {
        if (!userInfo)
            return ""

        return userInfo.displayName !== "" ? userInfo.displayName + " (" + userInfo.username + ")" : userInfo.username
    }

    function profileMode(profile) {
        if (!profile || !profile.mode || profile.mode === "Eco")
            return "Eco"

        return "Quick"
    }

    function profileSummary(profile) {
        return profileMode(profile) === "Eco" ? qsTr("Eco") : qsTr("Quick")
    }

    function profileActions(profile, username) {
        var actions = profileMode(profile) === "Eco" ? [qsTr("Eco charging")] : [qsTr("Quick charging")]
        if (profileMode(profile) === "Quick") {
            if (profile.maxChargingCurrent !== undefined)
                actions.push(qsTr("Max charging current: %1 A").arg(profile.maxChargingCurrent))
            if (profile.desiredPhaseCount !== undefined)
                actions.push(qsTr("Phase count: %1").arg(profile.desiredPhaseCount))
        }

        var assignedVehicleId = profileAssignedVehicleId(profile)
        if (assignedVehicleId !== "") {
            var vehicleThing = _engine.thingManager.things.getThing(assignedVehicleId)
            var vehicleName = vehicleThing ? vehicleThing.name : assignedVehicleId
            if (userCanUseVehicle(username, vehicleThing))
                actions.push(qsTr("Vehicle: %1").arg(vehicleName))
            else
                actions.push(qsTr("Vehicle: %1 (unavailable)").arg(vehicleName))
        }
        return actions
    }

    function backendProfileMode(mode) {
        if (mode === "Eco")
            return "Eco"

        return "Manual"
    }

    function buildProfile(mode, maxChargingCurrentText, desiredPhaseCount, assignedVehicleId) {
        var profile = {"mode": backendProfileMode(mode)}
        if (mode !== "Eco") {
            if (maxChargingCurrentText !== "")
                profile.maxChargingCurrent = parseInt(maxChargingCurrentText)
            if (desiredPhaseCount > 0)
                profile.desiredPhaseCount = desiredPhaseCount
        }
        if (uuidString(assignedVehicleId) !== "")
            profile.assignedCarId = uuidString(assignedVehicleId)
        return profile
    }

    function showErrorDialog(text) {
        var popup = errorDialogComponent.createObject(app, {text: text})
        popup.open()
    }

    function showRfidError(error) {
        var text
        switch (error) {
        case RfidManager.RfidErrorDuplicateTag:
            text = qsTr("This RFID tag is already assigned.")
            break
        case RfidManager.RfidErrorInvalidProfile:
            text = qsTr("The selected charging profile is not valid.")
            break
        case RfidManager.RfidErrorUserNotFound:
            text = qsTr("The selected user no longer exists.")
            break
        case RfidManager.RfidErrorTagNotFound:
            text = qsTr("The selected RFID tag no longer exists.")
            break
        case RfidManager.RfidErrorInvalidParameter:
            text = qsTr("The RFID tag data is not valid.")
            break
        case RfidManager.RfidErrorEnrollmentActive:
            text = qsTr("This charger is already waiting for an RFID tag.")
            break
        case RfidManager.RfidErrorEnrollmentNotFound:
            text = qsTr("The RFID tag scan is no longer active.")
            break
        default:
            text = qsTr("The RFID tag request could not be completed. (Error code: %1)").arg(error)
            break
        }

        showErrorDialog(text)
    }

    function rebuildUserFilterModel() {
        var currentUsername = ""
        if (userFilterComboBox.currentIndex >= 0 && userFilterComboBox.currentIndex < userFilterModel.count)
            currentUsername = userFilterModel.get(userFilterComboBox.currentIndex).username

        var filterUsername = initialUserFilterApplied ? currentUsername : initialUsername

        userFilterModel.clear()
        userFilterModel.append({"text": qsTr("All users"), "username": ""})

        for (var i = 0; i < userManager.users.count; ++i) {
            var userInfo = userManager.users.get(i)
            if (!userInfo)
                continue

            userFilterModel.append({"text": root.userLabel(userInfo), "username": userInfo.username})
        }

        var nextIndex = 0
        for (var j = 0; j < userFilterModel.count; ++j) {
            if (userFilterModel.get(j).username === filterUsername) {
                nextIndex = j
                if (!initialUserFilterApplied)
                    initialUserFilterApplied = true
                break
            }
        }
        userFilterComboBox.currentIndex = nextIndex
    }

    function tagVisible(username) {
        if (userFilterComboBox.currentIndex < 0 || userFilterComboBox.currentIndex >= userFilterModel.count)
            return true

        var filterUsername = userFilterModel.get(userFilterComboBox.currentIndex).username
        return filterUsername === "" || filterUsername === username
    }

    function selectedUserLabel(username) {
        var userInfo = userManager.users.getUserInfo(username)
        return userInfo ? userLabel(userInfo) : username
    }

    function uuidString(value) {
        if (!value)
            return ""

        return value.toString()
    }

    function profileAssignedVehicleId(profile) {
        if (!profile || profile.assignedCarId === undefined || profile.assignedCarId === null)
            return ""

        return uuidString(profile.assignedCarId)
    }

    function chargerThingName(thingId) {
        var chargerThing = _engine.thingManager.things.getThing(thingId)
        return chargerThing ? chargerThing.name : ""
    }

    function userCanUseThing(username, thing) {
        if (!thing)
            return false

        var userInfo = userManager.users.getUserInfo(username)
        if (!userInfo)
            return false

        if ((userInfo.scopes & UserInfo.PermissionScopeControlThings) !== UserInfo.PermissionScopeControlThings)
            return false

        if ((userInfo.scopes & UserInfo.PermissionScopeAccessAllThings) === UserInfo.PermissionScopeAccessAllThings)
            return true

        return userInfo.thingAllowed(thing.id)
    }

    function userCanUseCharger(username, chargerThing) {
        return userCanUseThing(username, chargerThing)
    }

    function isElectricVehicle(thing) {
        return thing && thing.thingClass
                && (thing.thingClass.interfaces.indexOf("electricvehicle") >= 0
                    || thing.thingClass.interfaces.indexOf("electricvehiclehlc") >= 0)
    }

    function userCanUseVehicle(username, vehicleThing) {
        return isElectricVehicle(vehicleThing) && userCanUseThing(username, vehicleThing)
    }

    function vehicleSelectionIsValid(username, vehicleThingId) {
        if (uuidString(vehicleThingId) === "")
            return true

        return userCanUseVehicle(username, _engine.thingManager.things.getThing(vehicleThingId))
    }

    function populateVehicleSelectionModel(selectionModel, username, selectedVehicleThingId) {
        var selectedId = uuidString(selectedVehicleThingId)
        var selectedIndex = selectedId === "" ? 0 : -1

        selectionModel.clear()
        selectionModel.append({"text": qsTr("Not set"), "thingId": "", "available": true})

        for (var i = 0; i < electricVehicleThingsProxy.count; ++i) {
            var vehicleThing = electricVehicleThingsProxy.get(i)
            if (!userCanUseVehicle(username, vehicleThing))
                continue

            var vehicleId = uuidString(vehicleThing.id)
            selectionModel.append({"text": vehicleThing.name, "thingId": vehicleId, "available": true})
            if (vehicleId === selectedId)
                selectedIndex = selectionModel.count - 1
        }

        if (selectedId !== "" && selectedIndex < 0) {
            var unavailableThing = _engine.thingManager.things.getThing(selectedId)
            var unavailableName = unavailableThing ? unavailableThing.name : selectedId
            selectionModel.append({
                                      "text": qsTr("%1 (unavailable)").arg(unavailableName),
                                      "thingId": selectedId,
                                      "available": false
                                  })
            selectedIndex = selectionModel.count - 1
        }

        return selectedIndex
    }

    function usableChargerCount(username) {
        var count = 0
        for (var i = 0; i < rfidChargerThingsProxy.count; ++i) {
            if (userCanUseCharger(username, rfidChargerThingsProxy.get(i)))
                ++count
        }
        return count
    }

    function usableVehicleCount(username) {
        var count = 0
        for (var i = 0; i < electricVehicleThingsProxy.count; ++i) {
            if (userCanUseVehicle(username, electricVehicleThingsProxy.get(i)))
                ++count
        }
        return count
    }

    function usableChargerCountForProxy(username, thingsProxy) {
        if (!thingsProxy)
            return 0

        var count = 0
        for (var i = 0; i < thingsProxy.count; ++i) {
            if (userCanUseCharger(username, thingsProxy.get(i)))
                ++count
        }
        return count
    }

    function chargerAccessSubtitle(username) {
        return qsTr("Available to %1").arg(selectedUserLabel(username))
    }

    header: NymeaHeader {
        text: root.title
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("qrc:/icons/settings.svg")
            onClicked: pageStack.push(Qt.resolvedUrl("RfidManagerSettingsPage.qml"))
        }
    }

    UserManager {
        id: userManager
        engine: _engine
    }

    RfidManager {
        id: rfidManager
        engine: _engine
    }

    ThingsProxy {
        id: rfidChargerThingsProxy
        engine: _engine
        shownInterfaces: ["chargers"]
    }

    ThingsProxy {
        id: electricVehicleThingsProxy
        engine: _engine
        shownInterfaces: ["electricvehicle", "electricvehiclehlc"]
    }

    ListModel {
        id: userFilterModel
    }

    Component {
        id: errorDialogComponent
        ErrorDialog {}
    }

    Component {
        id: confirmDeleteDialogComponent

        NymeaDialog {
            property RfidTagInfo tagInfo: null

            headerIcon: "qrc:/icons/dialog-warning-symbolic.svg"
            title: qsTr("Remove RFID tag")
            text: qsTr("Are you sure you want to remove \"%1\" for %2?")
                .arg(tagInfo && tagInfo.displayName !== "" ? tagInfo.displayName : (tagInfo ? tagInfo.tagHash : ""))
                .arg(tagInfo ? tagInfo.username : "")
            standardButtons: Dialog.Yes | Dialog.No

            onAccepted: {
                if (!tagInfo)
                    return

                root.busy = true
                root.pendingRemovalTag = tagInfo
                root.pendingRemoveCommandId = rfidManager.removeTag(tagInfo.inventoryItemId)
            }
        }
    }

    Component.onCompleted: rebuildUserFilterModel()

    Connections {
        target: userManager.users
        function onCountChanged() {
            root.rebuildUserFilterModel()
        }
    }

    Connections {
        target: rfidManager

        function onRemoveTagReply(commandId, error) {
            if (commandId !== root.pendingRemoveCommandId)
                return

            root.busy = false
            root.pendingRemoveCommandId = -1
            root.pendingRemovalTag = null

            if (error !== RfidManager.RfidErrorNoError)
                root.showRfidError(error)
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Filter")
    }

    ComboBox {
        id: userFilterComboBox
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        model: userFilterModel
        textRole: "text"
        onActivated: root.initialUserFilterApplied = true
    }

    Button {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        text: qsTr("Add RFID tag")
        onClicked: pageStack.push(addTagWizardComponent)
    }

    SettingsPageSectionHeader {
        text: qsTr("RFID tags")
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        wrapMode: Text.WordWrap
        visible: rfidManager.tags.count === 0
        text: qsTr("No RFID tags configured.")
    }

    Repeater {
        model: rfidManager.tags

        delegate: BigTile {
            readonly property bool shown: root.tagVisible(model.username)
            readonly property string tagTitle: model.displayName !== "" ? model.displayName : model.tagHash
            readonly property string tagUsername: model.username
            readonly property var tagProfile: model.profile

            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            Layout.preferredHeight: shown ? implicitHeight : 0
            Layout.maximumHeight: shown ? implicitHeight : 0
            Layout.minimumHeight: 0
            visible: shown
            onClicked: pageStack.push(tagEditorComponent, {tagInfo: rfidManager.tags.get(index), createMode: false})

            contentItem: ColumnLayout {
                spacing: Style.margins

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.margins

                    ColorIcon {
                        Layout.preferredWidth: Style.iconSize
                        Layout.preferredHeight: Style.iconSize
                        name: "qrc:/icons/rfid.svg"
                        color: Style.accentColor
                    }

                    Label {
                        Layout.fillWidth: true
                        text: tagTitle
                        font: Style.bigFont
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                        color: Style.tileForegroundColor
                    }

                    Led {
                        Layout.preferredWidth: Style.smallIconSize
                        Layout.preferredHeight: Style.smallIconSize
                        state: model.enabled ? "green" : "off"
                    }
                }

                ThinDivider {
                    Layout.fillWidth: true
                    opacity: 0.1
                    color: Style.tileForegroundColor
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.preferredWidth: Math.max(80, implicitWidth)
                        text: qsTr("User")
                        font: Style.smallFont
                        color: Style.tileForegroundColor
                        opacity: 0.7
                    }

                    Label {
                        Layout.fillWidth: true
                        text: model.username
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: Style.tileForegroundColor
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.preferredWidth: Math.max(80, implicitWidth)
                        text: qsTr("Action")
                        font: Style.smallFont
                        color: Style.tileForegroundColor
                        opacity: 0.7
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Repeater {
                            model: root.profileActions(tagProfile, tagUsername)

                            delegate: Label {
                                Layout.fillWidth: true
                                text: modelData
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                color: Style.tileForegroundColor
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: addTagWizardComponent

        WizardPageBase {
            id: wizardRootPage
            title: qsTr("Add RFID tag")
            text: qsTr("Select the user this RFID tag belongs to.")
            showNextButton: false

            property string selectedOwnerUsername: ""
            property string selectedAddMethod: ""
            property var selectedChargerThingId: null
            property string scannedOrEnteredCode: ""
            property var scannedTagInformation: ({})
            property string newDisplayName: ""
            property bool newEnabled: true
            property bool newAllowStopCharging: true
            property var newProfile: ({"mode": "Eco"})
            property string selectedVehicleThingId: ""
            property string pendingEnrollmentId: ""
            property string pendingEnrollmentExpiresAt: ""

            readonly property string addMethodChargerScan: "chargerScan"
            readonly property string addMethodManual: "manual"
            readonly property string addMethodPhoneNfc: "phoneNfc"
            readonly property string chargerDetectionEventName: "tagDetected"

            function resetScannedCodeState() {
                scannedOrEnteredCode = ""
                scannedTagInformation = ({})
                selectedChargerThingId = null
            }

            function clearPendingEnrollment() {
                pendingEnrollmentId = ""
                pendingEnrollmentExpiresAt = ""
            }

            function cancelPendingEnrollment() {
                if (pendingEnrollmentId !== "")
                    rfidManager.cancelEnrollment(pendingEnrollmentId)
                clearPendingEnrollment()
            }

            onNext: pageStack.push(addTagMethodComponent)
            onBack: pageStack.pop()

            Component.onDestruction: {
                wizardRootPage.cancelPendingEnrollment()
                wizardRootPage.scannedOrEnteredCode = ""
            }

            content: ColumnLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: userManager.users

                    delegate: NymeaItemDelegate {
                        Layout.fillWidth: true
                        progressive: true
                        iconName: "qrc:/icons/account.svg"
                        text: root.userLabel(userManager.users.get(index))
                        subText: model.username
                        iconColor: wizardRootPage.selectedOwnerUsername === model.username ? Style.accentColor : Style.iconColor
                        tertiaryIconName: wizardRootPage.selectedOwnerUsername === model.username ? "qrc:/icons/tick.svg" : ""
                        onClicked: {
                            if (!root.vehicleSelectionIsValid(model.username, wizardRootPage.selectedVehicleThingId))
                                wizardRootPage.selectedVehicleThingId = ""
                            wizardRootPage.selectedOwnerUsername = model.username
                            pageStack.push(addTagMethodComponent)
                        }
                    }
                }
            }

            Component {
                id: addTagMethodComponent

                WizardPageBase {
                    title: qsTr("Add RFID tag")
                    text: qsTr("Choose how to read the RFID tag for %1.").arg(root.selectedUserLabel(wizardRootPage.selectedOwnerUsername))
                    showNextButton: false
                    onBack: pageStack.pop()

                    content: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 500
                        Layout.alignment: Qt.AlignHCenter

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            iconName: "qrc:/icons/things.svg"
                            text: qsTr("Scan on charger")
                            subText: qsTr("Select a charger and prepare it for the next RFID tag.")
                            onClicked: {
                                wizardRootPage.selectedAddMethod = wizardRootPage.addMethodChargerScan
                                wizardRootPage.resetScannedCodeState()
                                pageStack.push(chargerSelectionComponent)
                            }
                        }

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            iconName: "qrc:/icons/edit.svg"
                            text: qsTr("Enter manually")
                            subText: qsTr("Type the RFID code manually.")
                            onClicked: {
                                wizardRootPage.selectedAddMethod = wizardRootPage.addMethodManual
                                wizardRootPage.resetScannedCodeState()
                                pageStack.push(manualCodeEntryComponent)
                            }
                        }

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            visible: NfcHelper.tagUidScanningAvailable
                            progressive: true
                            iconName: "qrc:/icons/nfc.svg"
                            text: qsTr("Scan with phone NFC")
                            subText: qsTr("Hold the RFID tag near this phone.")
                            onClicked: {
                                wizardRootPage.selectedAddMethod = wizardRootPage.addMethodPhoneNfc
                                wizardRootPage.resetScannedCodeState()
                                pageStack.push(phoneNfcScanComponent)
                            }
                        }
                    }
                }
            }

            Component {
                id: chargerSelectionComponent

                WizardPageBase {
                    id: chargerSelectionPage
                    title: qsTr("Scan RFID tag")
                    text: qsTr("Select the charger that should scan the RFID tag.")
                    showNextButton: false
                    onBack: pageStack.pop()

                    property bool showAllChargers: false

                    content: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 500
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Style.margins

                        TextField {
                            id: chargerFilterTextField
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            placeholderText: qsTr("Find charger")
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            wrapMode: Text.WordWrap
                            text: qsTr("No charger with RFID scan support is currently available.")
                            visible: scanChargerThingsProxy.count === 0 && !_engine.thingManager.fetchingData
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: qsTr("No charger with RFID scan support is available for %1.").arg(root.selectedUserLabel(wizardRootPage.selectedOwnerUsername))
                            visible: scanChargerThingsProxy.count > 0
                                     && root.usableChargerCountForProxy(wizardRootPage.selectedOwnerUsername, scanChargerThingsProxy) === 0
                                     && !chargerSelectionPage.showAllChargers
                                     && !_engine.thingManager.fetchingData
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: scanChargerThingsProxy.count > 0
                                     && !_engine.thingManager.fetchingData
                            text: chargerSelectionPage.showAllChargers ? qsTr("Show user chargers") : qsTr("Show all chargers")
                            onClicked: chargerSelectionPage.showAllChargers = !chargerSelectionPage.showAllChargers
                        }

                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                            visible: _engine.thingManager.fetchingData
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.min(contentHeight, chargerSelectionPage.visibleContentHeight)
                            clip: true
                            model: ThingsProxy {
                                id: scanChargerThingsProxy
                                engine: _engine
                                shownInterfaces: ["chargers"]
                                requiredEventName: wizardRootPage.chargerDetectionEventName
                                nameFilter: chargerFilterTextField.text
                            }

                            ScrollBar.vertical: ScrollBar {}

                            delegate: NymeaItemDelegate {
                                width: parent.width
                                readonly property Thing chargerThing: scanChargerThingsProxy.get(index)
                                readonly property bool shown: chargerSelectionPage.showAllChargers
                                                              || root.userCanUseCharger(wizardRootPage.selectedOwnerUsername, chargerThing)

                                height: shown ? implicitHeight : 0
                                visible: shown
                                progressive: false
                                text: chargerThing ? chargerThing.name : model.name
                                subText: chargerSelectionPage.showAllChargers
                                         && !root.userCanUseCharger(wizardRootPage.selectedOwnerUsername, chargerThing)
                                         ? qsTr("Not available to %1").arg(root.selectedUserLabel(wizardRootPage.selectedOwnerUsername))
                                         : qsTr("Use this charger to scan the next tag")
                                iconName: chargerThing ? app.interfacesToIcon(chargerThing.thingClass.interfaces) : "qrc:/icons/things.svg"
                                onClicked: {
                                    if (!chargerThing)
                                        return

                                    wizardRootPage.selectedChargerThingId = chargerThing.id
                                    pageStack.push(addTagFinalizeComponent)
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: waitForTagComponent

                WizardPageBase {
                    id: waitForTagPage
                    title: qsTr("Scan RFID tag")
                    text: waitForTagPage.selectedChargerThing
                          ? qsTr("Present the RFID tag to %1 now.").arg(waitForTagPage.selectedChargerThing.name)
                          : qsTr("The selected charger is no longer available.")
                    showNextButton: false
                    showExtraButton: waitForTagPage.selectedChargerThing !== null
                    extraButtonText: qsTr("Cancel scan")

                    readonly property Thing selectedChargerThing: _engine.thingManager.things.getThing(wizardRootPage.selectedChargerThingId)
                    readonly property var scanSpriteSources: [
                        "qrc:/icons/rfid-reader-00.svg",
                        "qrc:/icons/rfid-reader-01.svg",
                        "qrc:/icons/rfid-reader-02.svg",
                        "qrc:/icons/rfid-reader-03.svg"
                    ]
                    property bool completed: false
                    property int scanSpriteFrame: 0
                    property int remainingSeconds: 0

                    function updateRemainingSeconds() {
                        if (wizardRootPage.pendingEnrollmentExpiresAt === "") {
                            waitForTagPage.remainingSeconds = 0
                            return
                        }
                        var expiresAt = new Date(wizardRootPage.pendingEnrollmentExpiresAt)
                        waitForTagPage.remainingSeconds = Math.max(0, Math.round((expiresAt.getTime() - Date.now()) / 1000))
                    }

                    function formattedRemainingTime() {
                        var minutes = Math.floor(waitForTagPage.remainingSeconds / 60)
                        var seconds = waitForTagPage.remainingSeconds % 60
                        return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds)
                    }

                    function cancelEnrollmentAndLeave() {
                        if (waitForTagPage.completed)
                            return

                        waitForTagPage.completed = true
                        wizardRootPage.cancelPendingEnrollment()
                        pageStack.pop()
                    }

                    onBack: cancelEnrollmentAndLeave()
                    onExtraButtonPressed: cancelEnrollmentAndLeave()

                    Component.onCompleted: waitForTagPage.updateRemainingSeconds()

                    Timer {
                        interval: Style.slowAnimationDuration
                        repeat: true
                        running: waitForTagPage.visible
                                 && waitForTagPage.selectedChargerThing !== null
                                 && !waitForTagPage.completed
                        onTriggered: waitForTagPage.scanSpriteFrame = (waitForTagPage.scanSpriteFrame + 1) % waitForTagPage.scanSpriteSources.length
                    }

                    Timer {
                        interval: 1000
                        repeat: true
                        running: waitForTagPage.visible
                                 && waitForTagPage.selectedChargerThing !== null
                                 && !waitForTagPage.completed
                        onTriggered: waitForTagPage.updateRemainingSeconds()
                    }

                    content: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 500
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: waitForTagPage.visibleContentHeight

                        Item { Layout.fillHeight: true }

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: Math.min(Style.hugeIconSize * 3, Math.max(Style.hugeIconSize, waitForTagPage.width - Style.bigMargins))
                            Layout.preferredHeight: Layout.preferredWidth
                            visible: waitForTagPage.selectedChargerThing !== null && !waitForTagPage.completed
                            source: waitForTagPage.scanSpriteSources[waitForTagPage.scanSpriteFrame]
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            visible: waitForTagPage.selectedChargerThing !== null
                            text: qsTr("The next RFID tag detected on %1 will be stored.")
                                  .arg(waitForTagPage.selectedChargerThing ? waitForTagPage.selectedChargerThing.name : "")
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            visible: waitForTagPage.selectedChargerThing !== null && !waitForTagPage.completed
                            font: Style.bigFont
                            text: qsTr("Time remaining: %1").arg(waitForTagPage.formattedRemainingTime())
                        }

                        Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            visible: waitForTagPage.selectedChargerThing === null
                            text: qsTr("Please go back and select another charger.")
                        }

                        Item { Layout.fillHeight: true }
                    }

                    Connections {
                        target: rfidManager

                        function onEnrollmentFinished(enrollmentId, thingId, error, tagInfo) {
                            if (waitForTagPage.completed || root.uuidString(enrollmentId) !== root.uuidString(wizardRootPage.pendingEnrollmentId))
                                return

                            waitForTagPage.completed = true
                            wizardRootPage.clearPendingEnrollment()

                            if (error === RfidManager.RfidErrorNoError) {
                                pageStack.pop(root)
                            } else {
                                root.showRfidError(error)
                                pageStack.pop()
                            }
                        }

                        function onEnrollmentTimedOut(enrollmentId, thingId) {
                            if (waitForTagPage.completed || root.uuidString(enrollmentId) !== root.uuidString(wizardRootPage.pendingEnrollmentId))
                                return

                            waitForTagPage.completed = true
                            wizardRootPage.clearPendingEnrollment()
                            root.showErrorDialog(qsTr("No RFID tag was detected before the scan expired."))
                            pageStack.pop()
                        }

                        function onEnrollmentCanceled(enrollmentId, thingId) {
                            if (root.uuidString(enrollmentId) !== root.uuidString(wizardRootPage.pendingEnrollmentId))
                                return

                            waitForTagPage.completed = true
                            wizardRootPage.clearPendingEnrollment()
                        }
                    }
                }
            }

            Component {
                id: manualCodeEntryComponent

                WizardPageBase {
                    id: manualCodePage
                    title: qsTr("Enter RFID tag")
                    text: qsTr("Enter the RFID code manually.")
                    nextButtonEnabled: codeTextField.text.trim() !== ""

                    onNext: {
                        wizardRootPage.scannedOrEnteredCode = codeTextField.text.trim()
                        pageStack.push(addTagFinalizeComponent)
                    }

                    onBack: pageStack.pop()

                    content: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.margins
                        Layout.rightMargin: Style.margins
                        Layout.alignment: Qt.AlignHCenter

                        TextField {
                            id: codeTextField
                            Layout.fillWidth: true
                            text: wizardRootPage.scannedOrEnteredCode
                            placeholderText: qsTr("RFID code")
                        }
                    }
                }
            }

            Component {
                id: phoneNfcScanComponent

                WizardPageBase {
                    id: phoneNfcScanPage
                    title: qsTr("Scan with phone NFC")
                    text: NfcHelper.scanning
                          ? qsTr("Hold the RFID tag near the phone.")
                          : qsTr("The NFC scan is not running.")
                    showNextButton: false

                    property string scanError: ""

                    function startScan() {
                        scanError = ""
                        var started = NfcHelper.startTagUidScan()
                        console.info("[RFID NFC] Scan requested; started=" + started
                                     + ", scanning=" + NfcHelper.scanning
                                     + ", available=" + NfcHelper.tagUidScanningAvailable)
                    }

                    onBack: {
                        NfcHelper.stopTagUidScan()
                        pageStack.pop()
                    }

                    Component.onCompleted: startScan()
                    Component.onDestruction: NfcHelper.stopTagUidScan()

                    content: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 500
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: phoneNfcScanPage.visibleContentHeight
                        spacing: Style.margins

                        Item { Layout.fillHeight: true }

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: Style.hugeIconSize * 2
                            Layout.preferredHeight: Layout.preferredWidth
                            source: "qrc:/icons/nfc.svg"
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                        }

                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                            visible: NfcHelper.scanning
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: phoneNfcScanPage.scanError !== ""
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            text: phoneNfcScanPage.scanError
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: !NfcHelper.scanning
                            text: qsTr("Scan again")
                            onClicked: phoneNfcScanPage.startScan()
                        }

                        Item { Layout.fillHeight: true }
                    }

                    Connections {
                        target: NfcHelper

                        function onTagDetected(tagInformation) {
                            console.info("[RFID NFC] Tag received by scan page: "
                                         + JSON.stringify(tagInformation))
                            wizardRootPage.scannedTagInformation = tagInformation
                            wizardRootPage.scannedOrEnteredCode = tagInformation.code
                            pageStack.push(addTagFinalizeComponent)
                            console.info("[RFID NFC] Finalize page pushed; code="
                                         + wizardRootPage.scannedOrEnteredCode)
                        }

                        function onScanFailed(message) {
                            console.warn("[RFID NFC] Scan failed: " + message)
                            phoneNfcScanPage.scanError = message
                        }
                    }
                }
            }

            Component {
                id: addTagFinalizeComponent

                WizardPageBase {
                    id: addTagFinalizePage
                    title: qsTr("Finish RFID tag")
                    text: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodChargerScan
                          ? qsTr("Name the RFID tag, configure its charging profile, then prepare the charger for the next tag.")
                          : wizardRootPage.selectedAddMethod === wizardRootPage.addMethodPhoneNfc
                            ? qsTr("Review the scanned RFID tag, name it, and configure its charging profile.")
                            : qsTr("Name the RFID tag and configure its charging profile.")
                    nextButtonText: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodChargerScan ? qsTr("Start scan") : qsTr("Create RFID tag")
                    nextButtonEnabled: addTagFinalizePage.pendingCommandId === -1
                                       && (wizardRootPage.selectedAddMethod === wizardRootPage.addMethodChargerScan
                                           || wizardRootPage.scannedOrEnteredCode !== "")
                                       && userManager.users.contains(wizardRootPage.selectedOwnerUsername)
                                       && addTagFinalizePage.vehicleModelRevision >= 0
                                       && root.vehicleSelectionIsValid(wizardRootPage.selectedOwnerUsername,
                                                                       wizardRootPage.selectedVehicleThingId)
                                       && (modeComboBox.selectedMode !== "Quick"
                                           || maxChargingCurrentField.text === ""
                                           || maxChargingCurrentField.acceptableInput)

                    property int pendingCommandId: -1
                    property string pendingCommandType: ""
                    property int vehicleModelRevision: 0

                    function rebuildVehicleModel() {
                        if (!vehicleComboBox)
                            return

                        vehicleComboBox.currentIndex = root.populateVehicleSelectionModel(
                                    vehicleSelectionModel,
                                    wizardRootPage.selectedOwnerUsername,
                                    wizardRootPage.selectedVehicleThingId)
                        ++vehicleModelRevision
                    }

                    function updateDraftProfile() {
                        if (!modeComboBox || !maxChargingCurrentField || !phaseCountComboBox)
                            return

                        wizardRootPage.newProfile = root.buildProfile(
                                    modeComboBox.selectedMode,
                                    maxChargingCurrentField.text.trim(),
                                    phaseCountComboBox.currentIndex >= 0 ? phaseCountModel.get(phaseCountComboBox.currentIndex).value : 0,
                                    wizardRootPage.selectedVehicleThingId)
                    }

                    Component.onCompleted: rebuildVehicleModel()

                    onNext: {
                        if (pendingCommandId !== -1)
                            return

                        if (!userManager.users.contains(wizardRootPage.selectedOwnerUsername)) {
                            root.showErrorDialog(qsTr("The selected user no longer exists."))
                            return
                        }

                        updateDraftProfile()
                        if (wizardRootPage.selectedAddMethod === wizardRootPage.addMethodChargerScan) {
                            pendingCommandType = "enrollment"
                            pendingCommandId = rfidManager.startEnrollment(
                                        wizardRootPage.selectedChargerThingId,
                                        wizardRootPage.selectedOwnerUsername,
                                        wizardRootPage.newDisplayName,
                                        wizardRootPage.newEnabled,
                                        wizardRootPage.newAllowStopCharging,
                                        wizardRootPage.newProfile)
                        } else {
                            pendingCommandType = "addTag"
                            pendingCommandId = rfidManager.addTag(
                                        wizardRootPage.selectedOwnerUsername,
                                        wizardRootPage.scannedOrEnteredCode,
                                        wizardRootPage.newDisplayName,
                                        wizardRootPage.newEnabled,
                                        wizardRootPage.newAllowStopCharging,
                                        wizardRootPage.newProfile)
                        }
                    }

                    onBack: pageStack.pop()

                    ListModel {
                        id: phaseCountModel
                        ListElement { text: qsTr("Not set"); value: 0 }
                        ListElement { text: "1"; value: 1 }
                        ListElement { text: "3"; value: 3 }
                    }

                    ListModel {
                        id: vehicleSelectionModel
                    }

                    content: ColumnLayout {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 500
                        Layout.alignment: Qt.AlignHCenter

                        SettingsPageSectionHeader {
                            text: qsTr("Owner")
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            wrapMode: Text.WordWrap
                            text: root.selectedUserLabel(wizardRootPage.selectedOwnerUsername)
                        }

                        SettingsPageSectionHeader {
                            text: qsTr("RFID tag")
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            wrapMode: Text.WordWrap
                            visible: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodChargerScan
                            text: qsTr("The charger will store the next RFID tag it detects.")
                        }

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodPhoneNfc
                            progressive: false
                            text: qsTr("UID")
                            subText: wizardRootPage.scannedTagInformation.uid || ""
                        }

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodPhoneNfc
                            progressive: false
                            text: qsTr("Tag type")
                            subText: wizardRootPage.scannedTagInformation.tagType || qsTr("Unknown")
                        }

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodPhoneNfc
                            progressive: false
                            text: qsTr("Access methods")
                            subText: wizardRootPage.scannedTagInformation.accessMethods
                                     ? wizardRootPage.scannedTagInformation.accessMethods.join(", ")
                                     : qsTr("Unknown")
                        }

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodPhoneNfc
                            progressive: false
                            text: qsTr("NDEF message")
                            subText: wizardRootPage.scannedTagInformation.hasNdefMessage ? qsTr("Available") : qsTr("Not available")
                        }

                        NymeaItemDelegate {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: wizardRootPage.selectedAddMethod === wizardRootPage.addMethodPhoneNfc
                                     && wizardRootPage.scannedTagInformation.maxCommandLength !== undefined
                            progressive: false
                            text: qsTr("Maximum command length")
                            subText: qsTr("%1 bytes").arg(wizardRootPage.scannedTagInformation.maxCommandLength || 0)
                        }

                        NymeaTextField {
                            id: displayNameTextField
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            placeholderText: qsTr("Display name")
                            text: wizardRootPage.newDisplayName
                            onTextEdited: wizardRootPage.newDisplayName = text
                        }

                        SwitchDelegate {
                            id: enabledSwitch
                            Layout.fillWidth: true
                            text: qsTr("Enabled")
                            checked: wizardRootPage.newEnabled
                            onToggled: wizardRootPage.newEnabled = checked
                        }

                        SwitchDelegate {
                            Layout.fillWidth: true
                            text: qsTr("Allow stopping charging")
                            checked: wizardRootPage.newAllowStopCharging
                            onToggled: wizardRootPage.newAllowStopCharging = checked
                        }

                        SettingsPageSectionHeader {
                            text: qsTr("Charging profile")
                        }

                        ComboBox {
                            id: modeComboBox
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            model: [
                                {"text": qsTr("Eco"), "value": "Eco"},
                                {"text": qsTr("Quick"), "value": "Quick"}
                            ]
                            textRole: "text"
                            property string selectedMode: currentIndex >= 0 ? model[currentIndex].value : "Eco"
                            Component.onCompleted: {
                                currentIndex = root.profileMode(wizardRootPage.newProfile) === "Quick" ? 1 : 0
                            }
                            onCurrentIndexChanged: addTagFinalizePage.updateDraftProfile()
                        }

                        TextField {
                            id: maxChargingCurrentField
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: modeComboBox.selectedMode === "Quick"
                            placeholderText: qsTr("Max charging current (A)")
                            text: wizardRootPage.newProfile && wizardRootPage.newProfile.maxChargingCurrent !== undefined ? wizardRootPage.newProfile.maxChargingCurrent : ""
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: IntValidator { bottom: 1; top: 128 }
                            onTextEdited: addTagFinalizePage.updateDraftProfile()
                        }

                        ComboBox {
                            id: phaseCountComboBox
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: modeComboBox.selectedMode === "Quick"
                            model: phaseCountModel
                            textRole: "text"

                            Component.onCompleted: {
                                var desiredPhaseCount = wizardRootPage.newProfile && wizardRootPage.newProfile.desiredPhaseCount !== undefined
                                        ? wizardRootPage.newProfile.desiredPhaseCount : 0
                                for (var i = 0; i < phaseCountModel.count; ++i) {
                                    if (phaseCountModel.get(i).value === desiredPhaseCount) {
                                        currentIndex = i
                                        return
                                    }
                                }
                                currentIndex = 0
                            }

                            onCurrentIndexChanged: addTagFinalizePage.updateDraftProfile()
                        }

                        SettingsPageSectionHeader {
                            text: qsTr("Vehicle")
                        }

                        ComboBox {
                            id: vehicleComboBox
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            model: vehicleSelectionModel
                            textRole: "text"
                            onActivated: (index) => {
                                wizardRootPage.selectedVehicleThingId = vehicleSelectionModel.get(index).thingId
                                addTagFinalizePage.updateDraftProfile()
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: root.usableVehicleCount(wizardRootPage.selectedOwnerUsername) === 0
                                     && !_engine.thingManager.fetchingData
                            text: qsTr("No electric vehicles are available for the selected user.")
                            wrapMode: Text.WordWrap
                        }

                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                            visible: _engine.thingManager.fetchingData
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            text: qsTr("Select the vehicle to assign when this RFID tag is used. Not set keeps the charger's current vehicle assignment.")
                            color: Style.unobtrusiveForegroundColor
                            font: Style.smallFont
                            wrapMode: Text.WordWrap
                        }

                        SettingsPageSectionHeader {
                            text: qsTr("EV chargers")
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            wrapMode: Text.WordWrap
                            visible: root.usableChargerCount(wizardRootPage.selectedOwnerUsername) === 0
                                     && !_engine.thingManager.fetchingData
                            text: qsTr("This RFID tag is not available on any EV charger for the selected user.")
                        }

                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                            visible: _engine.thingManager.fetchingData
                        }

                        Repeater {
                            model: rfidChargerThingsProxy

                            delegate: NymeaSwipeDelegate {
                                readonly property Thing chargerThing: rfidChargerThingsProxy.get(index)
                                readonly property bool shown: root.userCanUseCharger(wizardRootPage.selectedOwnerUsername, chargerThing)

                                Layout.fillWidth: true
                                Layout.leftMargin: Style.margins
                                Layout.rightMargin: Style.margins
                                Layout.preferredHeight: shown ? implicitHeight : 0
                                Layout.maximumHeight: shown ? implicitHeight : 0
                                Layout.minimumHeight: 0
                                visible: shown
                                progressive: false
                                text: chargerThing ? chargerThing.name : model.name
                                subText: root.chargerAccessSubtitle(wizardRootPage.selectedOwnerUsername)
                                iconName: chargerThing ? app.interfacesToIcon(chargerThing.thingClass.interfaces) : "qrc:/icons/things.svg"
                            }
                        }

                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                            visible: addTagFinalizePage.pendingCommandId !== -1
                        }
                    }

                    Connections {
                        target: rfidManager

                        function onAddTagReply(commandId, error) {
                            if (addTagFinalizePage.pendingCommandType !== "addTag" || commandId !== addTagFinalizePage.pendingCommandId)
                                return

                            addTagFinalizePage.pendingCommandId = -1
                            addTagFinalizePage.pendingCommandType = ""
                            if (error === RfidManager.RfidErrorNoError) {
                                pageStack.pop(root)
                            } else {
                                root.showRfidError(error)
                            }
                        }

                        function onStartEnrollmentReply(commandId, error, enrollmentId, expiresAt) {
                            if (addTagFinalizePage.pendingCommandType !== "enrollment" || commandId !== addTagFinalizePage.pendingCommandId)
                                return

                            addTagFinalizePage.pendingCommandId = -1
                            addTagFinalizePage.pendingCommandType = ""
                            if (error === RfidManager.RfidErrorNoError) {
                                wizardRootPage.pendingEnrollmentId = enrollmentId
                                wizardRootPage.pendingEnrollmentExpiresAt = expiresAt
                                pageStack.push(waitForTagComponent)
                            } else {
                                root.showRfidError(error)
                            }
                        }
                    }

                    Connections {
                        target: electricVehicleThingsProxy

                        function onCountChanged() {
                            addTagFinalizePage.rebuildVehicleModel()
                        }
                    }

                    Connections {
                        target: userManager.users

                        function onCountChanged() {
                            addTagFinalizePage.rebuildVehicleModel()
                        }

                        function onDataChanged() {
                            addTagFinalizePage.rebuildVehicleModel()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: tagEditorComponent

        SettingsPageBase {
            id: editorPage
            property bool createMode: false
            property RfidTagInfo tagInfo: null
            property int pendingCommandId: -1
            property int pendingRemoveCommandId: -1
            property string selectedOwnerUsername: ""
            property string selectedVehicleThingId: root.profileAssignedVehicleId(tagInfo ? tagInfo.profile : null)
            property int vehicleModelRevision: 0
            title: createMode ? qsTr("Add RFID tag") : qsTr("Edit RFID tag")

            function currentUserInfo() {
                return createMode && ownerComboBox.currentIndex >= 0 ? userManager.users.get(ownerComboBox.currentIndex) : userManager.users.getUserInfo(tagInfo ? tagInfo.username : "")
            }

            function currentPhaseValue() {
                return phaseCountComboBox.currentIndex >= 0 ? phaseCountModel.get(phaseCountComboBox.currentIndex).value : 0
            }

            function originalPhaseValue() {
                return tagInfo && tagInfo.profile.desiredPhaseCount !== undefined ? tagInfo.profile.desiredPhaseCount : 0
            }

            function originalMaxChargingCurrentText() {
                return tagInfo && tagInfo.profile.maxChargingCurrent !== undefined ? String(tagInfo.profile.maxChargingCurrent) : ""
            }

            function ownerUsername() {
                return createMode ? selectedOwnerUsername : (tagInfo ? tagInfo.username : "")
            }

            function originalVehicleThingId() {
                return root.profileAssignedVehicleId(tagInfo ? tagInfo.profile : null)
            }

            function rebuildVehicleModel() {
                if (!vehicleComboBox)
                    return

                vehicleComboBox.currentIndex = root.populateVehicleSelectionModel(
                            vehicleSelectionModel, ownerUsername(), selectedVehicleThingId)
                ++vehicleModelRevision
            }

            function canSubmit() {
                if (pendingCommandId !== -1 || pendingRemoveCommandId !== -1)
                    return false

                if (createMode) {
                    if (selectedOwnerUsername === "")
                        return false
                    if (codeTextField.text.trim() === "")
                        return false
                }

                if (modeComboBox.selectedMode === "Quick" && maxChargingCurrentField.text !== "" && !maxChargingCurrentField.acceptableInput)
                    return false

                if (vehicleModelRevision >= 0
                        && !root.vehicleSelectionIsValid(ownerUsername(), selectedVehicleThingId))
                    return false

                return createMode || hasUnsavedChanges()
            }

            function hasUnsavedChanges() {
                if (pendingCommandId !== -1 || pendingRemoveCommandId !== -1)
                    return false

                if (createMode) {
                    return selectedOwnerUsername !== ""
                            || codeTextField.text.trim() !== ""
                            || displayNameTextField.text !== ""
                            || enabledSwitch.checked !== true
                            || allowStopChargingSwitch.checked !== true
                            || modeComboBox.selectedMode !== "Eco"
                            || maxChargingCurrentField.text.trim() !== ""
                            || currentPhaseValue() !== 0
                            || selectedVehicleThingId !== ""
                }

                if (!tagInfo)
                    return false

                if (displayNameTextField.text !== tagInfo.displayName)
                    return true
                if (enabledSwitch.checked !== tagInfo.enabled)
                    return true
                if (allowStopChargingSwitch.checked !== tagInfo.allowStopCharging)
                    return true
                if (modeComboBox.selectedMode !== root.profileMode(tagInfo.profile))
                    return true
                if (modeComboBox.selectedMode === "Quick") {
                    if (maxChargingCurrentField.text.trim() !== originalMaxChargingCurrentText())
                        return true
                    if (currentPhaseValue() !== originalPhaseValue())
                        return true
                }
                if (selectedVehicleThingId !== originalVehicleThingId())
                    return true

                return false
            }

            function handleBack() {
                if (pendingCommandId !== -1 || pendingRemoveCommandId !== -1)
                    return

                if (!hasUnsavedChanges()) {
                    pageStack.pop()
                    return
                }

                var popup = discardTagChangesDialogComponent.createObject(editorPage)
                popup.open()
            }

            function saveIfValid() {
                if (createMode) {
                    if (!userManager.users.contains(selectedOwnerUsername)) {
                        root.showErrorDialog(qsTr("The selected user no longer exists."))
                        return
                    }
                }

                if (!canSubmit())
                    return

                submit()
            }

            function submit() {
                var profile = root.buildProfile(modeComboBox.selectedMode, maxChargingCurrentField.text.trim(),
                                                currentPhaseValue(), selectedVehicleThingId)
                busy = true

                if (createMode) {
                    pendingCommandId = rfidManager.addTag(
                        selectedOwnerUsername,
                        codeTextField.text.trim(),
                        displayNameTextField.text,
                        enabledSwitch.checked,
                        allowStopChargingSwitch.checked,
                        profile
                    )
                } else {
                    pendingCommandId = rfidManager.updateTag(
                        tagInfo.inventoryItemId,
                        displayNameTextField.text,
                        enabledSwitch.checked,
                        allowStopChargingSwitch.checked,
                        profile
                    )
                }
            }

            Component.onCompleted: rebuildVehicleModel()

            header: NymeaHeader {
                text: editorPage.title
                onBackPressed: editorPage.handleBack()

                HeaderButton {
                    imageSource: "qrc:/icons/delete.svg"
                    text: qsTr("Remove RFID tag")
                    visible: !editorPage.createMode && editorPage.tagInfo
                    onClicked: {
                        var popup = localConfirmDeleteDialogComponent.createObject(editorPage, {tagInfo: editorPage.tagInfo})
                        popup.open()
                    }
                }
            }

            footer: Rectangle {
                implicitHeight: saveButton.implicitHeight + Style.margins * 2
                color: Style.backgroundColor

                Button {
                    id: saveButton
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Style.margins
                    }
                    text: editorPage.createMode ? qsTr("Create RFID tag") : qsTr("Save")
                    enabled: editorPage.canSubmit()
                    onClicked: editorPage.saveIfValid()
                }
            }

            ListModel {
                id: phaseCountModel
                ListElement { text: qsTr("Not set"); value: 0 }
                ListElement { text: "1"; value: 1 }
                ListElement { text: "3"; value: 3 }
            }

            ListModel {
                id: vehicleSelectionModel
            }

            SettingsPageSectionHeader {
                text: qsTr("Basic information")
            }

            ComboBox {
                id: ownerComboBox
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                visible: editorPage.createMode
                model: userManager.users
                textRole: "username"
                displayText: {
                    var selectedUser = userManager.users.get(currentIndex)
                    return selectedUser ? root.userLabel(selectedUser) : ""
                }
                onCurrentIndexChanged: {
                    if (!editorPage.createMode)
                        return

                    var selectedUser = userManager.users.get(currentIndex)
                    editorPage.selectedOwnerUsername = selectedUser ? selectedUser.username : ""
                    if (!root.vehicleSelectionIsValid(editorPage.selectedOwnerUsername,
                                                      editorPage.selectedVehicleThingId))
                        editorPage.selectedVehicleThingId = ""
                    editorPage.rebuildVehicleModel()
                }
                Component.onCompleted: {
                    if (!editorPage.createMode)
                        return

                    var selectedUser = userManager.users.get(currentIndex)
                    editorPage.selectedOwnerUsername = selectedUser ? selectedUser.username : ""
                    editorPage.rebuildVehicleModel()
                }
            }

            NymeaItemDelegate {
                Layout.fillWidth: true
                visible: !editorPage.createMode && editorPage.tagInfo
                readonly property UserInfo ownerInfo: editorPage.currentUserInfo()
                text: ownerInfo ? root.userLabel(ownerInfo) : (editorPage.tagInfo ? editorPage.tagInfo.username : "")
                subText: ownerInfo ? ownerInfo.email : ""
                iconName: "qrc:/icons/account.svg"
                progressive: true
                onClicked: pageStack.push(Qt.resolvedUrl("UsersSettingsPage.qml"),
                                          {initialUsername: editorPage.tagInfo.username})
            }

            TextField {
                id: codeTextField
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                visible: editorPage.createMode
                placeholderText: qsTr("RFID code")
            }

            NymeaTextField {
                id: displayNameTextField
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                placeholderText: qsTr("Display name")
                text: editorPage.tagInfo ? editorPage.tagInfo.displayName : ""
            }

            SwitchDelegate {
                id: enabledSwitch
                Layout.fillWidth: true
                text: qsTr("Enabled")
                checked: editorPage.tagInfo ? editorPage.tagInfo.enabled : true
            }

            SwitchDelegate {
                id: allowStopChargingSwitch
                Layout.fillWidth: true
                text: qsTr("Allow stopping charging")
                checked: editorPage.tagInfo ? editorPage.tagInfo.allowStopCharging : true
            }

            SettingsPageSectionHeader {
                text: qsTr("Charging profile")
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                text: qsTr("The charger will apply the following profile when this tag is detected on an assigned charger.")
                color: Style.unobtrusiveForegroundColor
                font: Style.smallFont
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: modeComboBox
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                model: [
                    {"text": qsTr("Eco"), "value": "Eco"},
                    {"text": qsTr("Quick"), "value": "Quick"}
                ]
                textRole: "text"
                property string selectedMode: currentIndex >= 0 ? model[currentIndex].value : "Eco"
                Component.onCompleted: {
                    currentIndex = root.profileMode(editorPage.tagInfo ? editorPage.tagInfo.profile : {"mode": "Eco"}) === "Quick" ? 1 : 0
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                text: qsTr("Eco uses available surplus energy. Quick charges as fast as the configured limits allow.")
                color: Style.unobtrusiveForegroundColor
                font: Style.smallFont
                wrapMode: Text.WordWrap
            }

            TextField {
                id: maxChargingCurrentField
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                Layout.topMargin: Style.smallMargins
                visible: modeComboBox.selectedMode === "Quick"
                placeholderText: qsTr("Max charging current (A)")
                text: editorPage.tagInfo && editorPage.tagInfo.profile.maxChargingCurrent !== undefined ? editorPage.tagInfo.profile.maxChargingCurrent : ""
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator { bottom: 1; top: 128 }
            }

            ComboBox {
                id: phaseCountComboBox
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                visible: modeComboBox.selectedMode === "Quick"
                model: phaseCountModel
                textRole: "text"

                Component.onCompleted: {
                    var desiredPhaseCount = editorPage.tagInfo && editorPage.tagInfo.profile.desiredPhaseCount !== undefined
                            ? editorPage.tagInfo.profile.desiredPhaseCount : 0
                    for (var i = 0; i < phaseCountModel.count; ++i) {
                        if (phaseCountModel.get(i).value === desiredPhaseCount) {
                            currentIndex = i
                            return
                        }
                    }
                    currentIndex = 0
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                visible: modeComboBox.selectedMode === "Quick"
                text: qsTr("Select how many phases the charger should use. Leave this unset to let the charger decide.")
                color: Style.unobtrusiveForegroundColor
                font: Style.smallFont
                wrapMode: Text.WordWrap
            }

            SettingsPageSectionHeader {
                text: qsTr("Vehicle")
            }

            ComboBox {
                id: vehicleComboBox
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                model: vehicleSelectionModel
                textRole: "text"
                onActivated: (index) => {
                    editorPage.selectedVehicleThingId = vehicleSelectionModel.get(index).thingId
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                visible: root.usableVehicleCount(editorPage.ownerUsername()) === 0
                         && !_engine.thingManager.fetchingData
                text: qsTr("No electric vehicles are available for the selected user.")
                wrapMode: Text.WordWrap
            }

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                visible: _engine.thingManager.fetchingData
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                text: qsTr("Select the vehicle to assign when this RFID tag is used. Not set keeps the charger's current vehicle assignment.")
                color: Style.unobtrusiveForegroundColor
                font: Style.smallFont
                wrapMode: Text.WordWrap
            }

            SettingsPageSectionHeader {
                text: qsTr("RFID tag details")
                visible: !editorPage.createMode && editorPage.tagInfo
            }

            NymeaItemDelegate {
                Layout.fillWidth: true
                visible: !editorPage.createMode && editorPage.tagInfo
                progressive: true
                text: qsTr("Technical details")
                iconName: "qrc:/icons/info.svg"
                onClicked: pageStack.push(tagDetailsComponent, {tagInfo: editorPage.tagInfo})
            }

            SettingsPageSectionHeader {
                text: qsTr("EV chargers")
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                wrapMode: Text.WordWrap
                color: Style.unobtrusiveForegroundColor
                font: Style.smallFont
                visible: root.usableChargerCount(editorPage.tagInfo ? editorPage.tagInfo.username : editorPage.selectedOwnerUsername) > 0
                text: qsTr("This tag can authorize charging on the EV chargers listed below because they are accessible to its owner.")
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                wrapMode: Text.WordWrap
                visible: root.usableChargerCount(editorPage.tagInfo ? editorPage.tagInfo.username : editorPage.selectedOwnerUsername) === 0
                         && !_engine.thingManager.fetchingData
                text: qsTr("This RFID tag is not available on any EV charger for the selected user.")
            }

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                visible: _engine.thingManager.fetchingData
            }

            Repeater {
                model: rfidChargerThingsProxy

                delegate: NymeaSwipeDelegate {
                    readonly property string ownerUsername: editorPage.tagInfo ? editorPage.tagInfo.username : editorPage.selectedOwnerUsername
                    readonly property Thing chargerThing: rfidChargerThingsProxy.get(index)
                    readonly property bool shown: root.userCanUseCharger(ownerUsername, chargerThing)

                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.preferredHeight: shown ? implicitHeight : 0
                    Layout.maximumHeight: shown ? implicitHeight : 0
                    Layout.minimumHeight: 0
                    visible: shown
                    progressive: false
                    text: chargerThing ? chargerThing.name : model.name
                    subText: root.chargerAccessSubtitle(ownerUsername)
                    iconName: chargerThing ? app.interfacesToIcon(chargerThing.thingClass.interfaces) : "qrc:/icons/things.svg"
                }
            }

            Component {
                id: tagDetailsComponent

                SettingsPageBase {
                    title: qsTr("RFID tag details")
                    property RfidTagInfo tagInfo: null

                    SettingsPageSectionHeader {
                        text: qsTr("Technical details")
                    }

                    NymeaSwipeDelegate {
                        Layout.fillWidth: true
                        progressive: false
                        text: qsTr("RFID hash")
                        subText: tagInfo ? tagInfo.tagHash : ""
                        onClicked: {
                            PlatformHelper.toClipBoard(tagInfo.tagHash)
                            ToolTip.show(qsTr("RFID hash copied"), 500)
                        }
                    }
                }
            }

            Component {
                id: localConfirmDeleteDialogComponent

                NymeaDialog {
                    property RfidTagInfo tagInfo: null

                    headerIcon: "qrc:/icons/dialog-warning-symbolic.svg"
                    title: qsTr("Remove RFID tag")
                    text: qsTr("Are you sure you want to remove \"%1\" for %2?")
                        .arg(tagInfo && tagInfo.displayName !== "" ? tagInfo.displayName : (tagInfo ? tagInfo.tagHash : ""))
                        .arg(tagInfo ? tagInfo.username : "")
                    standardButtons: Dialog.Yes | Dialog.No

                    onAccepted: {
                        if (!tagInfo)
                            return

                        editorPage.busy = true
                        editorPage.pendingRemoveCommandId = rfidManager.removeTag(tagInfo.inventoryItemId)
                    }
                }
            }

            Component {
                id: discardTagChangesDialogComponent

                NymeaDialog {
                    id: discardTagChangesDialog

                    title: qsTr("Unsaved RFID tag")
                    text: qsTr("Do you want to save the changes before leaving this page?")
                    standardButtons: Dialog.NoButton

                    RowLayout {
                        Layout.fillWidth: true

                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Discard")
                            onClicked: {
                                discardTagChangesDialog.close()
                                pageStack.pop()
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Return")
                            onClicked: discardTagChangesDialog.close()
                        }

                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Save")
                            enabled: editorPage.canSubmit()
                            onClicked: {
                                discardTagChangesDialog.close()
                                editorPage.saveIfValid()
                            }
                        }
                    }
                }
            }

            Connections {
                target: rfidManager

                function onAddTagReply(commandId, error) {
                    if (!editorPage.createMode || commandId !== editorPage.pendingCommandId)
                        return

                    editorPage.busy = false
                    editorPage.pendingCommandId = -1
                    if (error === RfidManager.RfidErrorNoError) {
                        pageStack.pop()
                    } else {
                        root.showRfidError(error)
                    }
                }

                function onUpdateTagReply(commandId, error) {
                    if (editorPage.createMode || commandId !== editorPage.pendingCommandId)
                        return

                    editorPage.busy = false
                    editorPage.pendingCommandId = -1
                    if (error === RfidManager.RfidErrorNoError) {
                        pageStack.pop()
                    } else {
                        root.showRfidError(error)
                    }
                }

                function onRemoveTagReply(commandId, error) {
                    if (commandId !== editorPage.pendingRemoveCommandId)
                        return

                    editorPage.busy = false
                    editorPage.pendingRemoveCommandId = -1
                    if (error === RfidManager.RfidErrorNoError) {
                        pageStack.pop()
                    } else {
                        root.showRfidError(error)
                    }
                }
            }

            Connections {
                target: electricVehicleThingsProxy

                function onCountChanged() {
                    editorPage.rebuildVehicleModel()
                }
            }

            Connections {
                target: userManager.users

                function onCountChanged() {
                    editorPage.rebuildVehicleModel()
                }

                function onDataChanged() {
                    editorPage.rebuildVehicleModel()
                }
            }
        }
    }
}
