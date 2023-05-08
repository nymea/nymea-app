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

import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Configure Things")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/find.svg"
            color: filterInput.shown ? Style.accentColor : Style.iconColor
            onClicked: filterInput.shown = !filterInput.shown

        }

        HeaderButton {
            imageSource: "../images/add.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("NewThingPage.qml"))
        }
    }

    QtObject {
        id: d
        property int pendingCommandId: -1
    }

    Connections {
        target: engine.thingManager
        onRemoveThingReply: {
            if (commandId != d.pendingCommandId) {
                return;
            }

            d.pendingCommandId = -1

            switch (thingError) {
            case Thing.ThingErrorNoError:
                return;
            default:
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
                var popup = errorDialog.createObject(root, {error: thingError})
                popup.open();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListFilterInput {
            id: filterInput
            Layout.fillWidth: true
        }

        GroupedListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: ThingsProxy {
                id: thingsProxy
                engine: _engine
                groupByInterface: true
                nameFilter: filterInput.shown ? filterInput.text : ""
            }

            delegate: ThingDelegate {
                thing: thingsProxy.getThing(model.id)
                // FIXME: This isn't entirely correct... we should have a way to know if a particular thing is in fact autocreated
                // This check might be wrong for thingClasses with multiple create methods...                
                canDelete: !thing.isChild || thing.thingClass.createMethods.indexOf("CreateMethodAuto") < 0
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ConfigureThingPage.qml"), {thing: thing})
                }
                onDeleteClicked: {
                    var popup = removeDialogComponent.createObject(root, {thing: thing})
                    popup.open()
                }
            }
        }
    }

    Component {
        id: removeDialogComponent
        NymeaDialog {
            id: removeDialog
            title: qsTr("Remove thing?")
            text: qsTr("Are you sure you want to remove %1 and all associated settings?").arg(thing.name)
            standardButtons: Dialog.Yes | Dialog.No

            property Thing thing: null

            onAccepted: {
                d.pendingCommand = engine.thingManager.removeThing(thing.id)
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: engine.thingManager.things.count === 0 && !engine.thingManager.fetchingData
        title: qsTr("There are no things set up yet.")
        text: qsTr("In order for your %1 system to be useful, go ahead and add some things.").arg(Configuration.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        buttonText: qsTr("Add a thing")
        onButtonClicked: pageStack.push(Qt.resolvedUrl("NewThingPage.qml"))
    }
}
