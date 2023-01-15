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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 0

    // The thing or things this control should act on
    // Use one of them, if setting both, the single thing will have precedence
    property Thing thing: null
    property ThingsProxy thingsProxy: null

    // The used interface of the above thing(s)
    property string iface: ""

    Item {
        Layout.fillWidth: true; Layout.fillHeight: true
        visible: label.visible || firstButton.visible
    }

    Label {
        id: label
        Layout.fillWidth: true
        visible: text != ""
        text: {
            switch (root.iface) {
            case "media":
                return root.thing ? root.thing.name : thingsProxy.get(0).name;
            case "light":
            case "irrigation":
            case "ventilation":
            case "powersocket":
            case "evcharger":
                if (root.thing) {
                    return root.thing.stateByName("power").value === true ? qsTr("On") : qsTr("Off")
                }

                var count = 0;
                for (var i = 0; i < root.thingsProxy.count; i++) {
                    var thing = root.thingsProxy.get(i);
                    if (thing.stateByName("power").value === true) {
                        count++;
                    }
                }
                return count === 0 ? qsTr("All off") : qsTr("%1 on").arg(count)
            case "garagedoor":
            case "blind":
            case "extendedblind":
            case "awning":
            case "extendedawning":
            case "shutter":
            case "extendedshutter":
                return ""
                //                        return qsTr("%1 installed").arg(thingsProxy.count)
            }
            console.warn("InterfaceTile, inlineButtonControl 1: Unhandled interface", model.name)
        }
        font.pixelSize: app.smallFont
        elide: Text.ElideRight
    }

    ProgressButton {
        id: firstButton
        longpressEnabled: false
        visible: imageSource.length > 0
        color: Style.tileOverlayIconColor
        imageSource: {
            switch (iface) {
            case "media":
            case "light":
            case "irrigation":
            case "ventilation":
            case "powersocket":
                return ""
            case "garagedoor":
                var thing = root.thing ? root.thing : root.thingsProxy.get(0)
                if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                        || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                        || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                        || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {
                    return "../images/up.svg"
                }
                return ""
            case "blind":
            case "extendedblind":
            case "awning":
            case "extendedawning":
            case "shutter":
            case "extendedshutter":
                return "../images/up.svg"
            case "cleaningrobot":
                var thing = root.thing ? root.thing : thingsProxy.get(0)
                var robotState = thing.stateByName("robotState")
                return robotState.value == "cleaning" ? "../images/media-playback-pause.svg" : "../images/media-playback-start.svg"
            default:
                console.warn("ButtonControls", "button 1 image: Unhandled interface", iface)
            }
            return ""
        }

        onClicked: {
            switch (iface) {
            case "light":
            case "media":
            case "irrigation":
            case "ventilation":
                break;
            case "garagedoor":
                if (root.thing) {
                    var actionType = thing.thingClass.actionTypes.findByName("open");
                    engine.thingManager.executeAction(thing.id, actionType.id)
                    return;
                }

                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {

                        var actionType = thing.thingClass.actionTypes.findByName("open");
                        engine.thingManager.executeAction(thing.id, actionType.id)
                    }
                }
                break;
            case "shutter":
            case "extendedshutter":
            case "blind":
            case "extendedblind":
            case "awning":
            case "extendedawning":
            case "simpleclosable":
                if (root.thing) {
                    var actionType = root.thing.thingClass.actionTypes.findByName("open");
                    engine.thingManager.executeAction(root.thing.id, actionType.id)
                }

                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    var actionType = thing.thingClass.actionTypes.findByName("open");
                    engine.thingManager.executeAction(thing.id, actionType.id)
                }
                break;
            case "cleaningrobot":
                var thing = root.thing ? root.thing : thingsProxy.get(0)
                var robotState = thing.stateByName("robotState")
                if (robotState.value === "cleaning" || robotState.value === "paused") {
                    engine.thingManager.executeAction(thing.id, thing.thingClass.actionTypes.findByName("pauseCleaning").id)
                } else {
                    engine.thingManager.executeAction(thing.id, thing.thingClass.actionTypes.findByName("startCleaning").id)
                }
                break;
            default:
                console.warn("InterfaceTile:", "inlineButtonControl 1 clicked: Unhandled interface", iface)
            }
        }
    }

    Item {
        Layout.fillWidth: true; Layout.fillHeight: true
        visible: secondButton.visible
    }

    ProgressButton {
        id: secondButton
        longpressEnabled: false
        visible: imageSource.length > 0
        color: Style.tileOverlayIconColor
        imageSource: {
            switch (iface) {
            case "media":
            case "light":
            case "irrigation":
            case "ventilation":
            case "powersocket":
                return ""
            case "garagedoor":
                var dev = root.thing ? root.thing : thingsProxy.get(0)
                if (dev.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                        || dev.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                        || dev.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                        || dev.thingClass.interfaces.indexOf("garagegate") >= 0) {
                    return "../images/media-playback-stop.svg"
                }
                return ""
            case "blind":
            case "awning":
            case "shutter":
            case "extendedblind":
            case "extendedawning":
            case "extendedshutter":
            case "cleaningrobot":
                return "../images/media-playback-stop.svg"
            default:
                console.warn("InterfaceTile, inlineButtonControl 2 image: Unhandled interface", iface)
            }
            return "";
        }

        onClicked: {
            switch (iface) {
            case "light":
            case "media":
            case "irrigation":
            case "ventilation":
            case "evcharger":
                break;
            case "garagedoor":
                if (root.thing) {
                    var actionType = root.thing.thingClass.actionTypes.findByName("stop");
                    engine.thingManager.executeAction(root.thing.id, actionType.id)
                    return
                }

                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {

                        var actionType = thing.thingClass.actionTypes.findByName("stop");
                        engine.thingManager.executeAction(thing.id, actionType.id)
                    }
                }
                break;
            case "shutter":
            case "extendedshutter":
            case "blind":
            case "extendedblind":
            case "awning":
            case "extendedawning":
            case "simpleclosable":
                if (root.thing) {
                    var actionType = root.thing.thingClass.actionTypes.findByName("stop");
                    engine.thingManager.executeAction(root.thing.id, actionType.id)
                }

                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    var actionType = thing.thingClass.actionTypes.findByName("stop");
                    engine.thingManager.executeAction(thing.id, actionType.id)
                }
                break;
            case "cleaningrobot":
                var thing = root.thing ? root.thing : thingsProxy.get(0)
                engine.thingManager.executeAction(thing.id, thing.thingClass.actionTypes.findByName("stopCleaning").id)
                break;
            default:
                console.warn("InterfaceTile, inlineButtonControl 2 clicked: Unhandled interface", iface)
            }
        }
    }
    Item {
        Layout.fillWidth: true; Layout.fillHeight: true
        visible: thirdButton.visible
    }

    ProgressButton {
        id: thirdButton
        longpressEnabled: false
        visible: imageSource.length > 0
        color: Style.tileOverlayIconColor
        imageSource: {
            switch (root.iface) {
            case "media":
                var thing = root.thing ? root.thing : thingsProxy.get(0)
                var stateType = thing.thingClass.stateTypes.findByName("playbackStatus");
                var state = device.states.getState(stateType.id)
                return state.value === "Playing" ? "../images/media-playback-pause.svg" :
                                                   state.value === "Paused" ? "../images/media-playback-start.svg" :
                                                                              ""
            case "light":
            case "powersocket":
            case "irrigation":
            case "ventilation":
            case "evcharger":
                return "../images/system-shutdown.svg"
            case "garagedoor":
                var dev = root.thing ? root.thing : thingsProxy.get(0)
                if (dev.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                        || dev.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                        || dev.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                        || dev.thingClass.interfaces.indexOf("garagegate") >= 0) {
                    return "../images/down.svg"
                }
                if (dev.thingClass.interfaces.indexOf("impulsegaragedoor") >= 0) {
                    return "../images/closable-move.svg"
                }
                return ""
            case "blind":
            case "extendedblind":
            case "awning":
            case "extendedawning":
            case "shutter":
            case "extendedshutter":
                return "../images/down.svg"
            default:
                console.warn("InterfaceTile, inlineButtonControl 3 image: Unhandled interface", iface)
            }
        }

        onClicked: {
            switch (iface) {
            case "light":
            case "powersocket":
            case "irrigation":
            case "ventilation":
            case "evcharger":
                if (root.thing) {
                    var actionType = root.thing.thingClass.actionTypes.findByName("power");
                    var params = [];
                    var param1 = {};
                    param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param1["value"] = root.thing.stateByName("power").value === true ? true : false;
                    params.push(param1)
                    engine.thingManager.executeAction(root.thing.id, actionType.id, params)
                    return;
                }

                var allOff = true;
                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    if (thing.stateByName("power").value === true) {
                        allOff = false;
                        break;
                    }
                }

                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    var actionType = thing.thingClass.actionTypes.findByName("power");

                    var params = [];
                    var param1 = {};
                    param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param1["value"] = allOff ? true : false;
                    params.push(param1)
                    engine.thingManager.executeAction(thing.id, actionType.id, params)
                }
                break;
            case "media":
                var thing = root.thing ? root.thing : thingsProxy.get(0)
                var state = thing.stateByName("playbackStatus")

                var actionName
                switch (state.value) {
                case "Playing":
                    actionName = "pause";
                    break;
                case "Paused":
                    actionName = "play";
                    break;
                }
                var actionTypeId = thing.thingClass.actionTypes.findByName(actionName).id;

                print("executing", thing, thing.id, actionTypeId, actionName, thing.thingClass.actionTypes)

                engine.thingManager.executeAction(thing.id, actionTypeId)
                break;
            case "garagedoor":
                if (root.thing) {
                    if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {
                        var actionType = root.thing.thingClass.actionTypes.findByName("close");
                        engine.thingManager.executeAction(root.thing.id, actionType.id)
                    } else {
                        var actionType = thing.thingClass.actionTypes.findByName("triggerImpulse");
                        engine.thingManager.executeAction(thing.id, actionType.id)
                    }
                    return;
                }

                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    if (thing.thingClass.interfaces.indexOf("simplegaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("statefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("extendedstatefulgaragedoor") >= 0
                            || thing.thingClass.interfaces.indexOf("garagegate") >= 0) {

                        var actionType = thing.thingClass.actionTypes.findByName("close");
                        engine.thingManager.executeAction(thing.id, actionType.id)
                    }
                    if (thing.thingClass.interfaces.indexOf("impulsegaragedoor") >= 0) {
                        var actionType = thing.thingClass.actionTypes.findByName("triggerImpulse");
                        engine.thingManager.executeAction(thing.id, actionType.id)
                    }
                }
                break;
            case "shutter":
            case "extendedshutter":
            case "blind":
            case "extendedblind":
            case "awning":
            case "extendedawning":
            case "simpleclosable":
                if (root.thing) {
                    var actionType = root.thing.thingClass.actionTypes.findByName("close");
                    engine.thingManager.executeAction(root.thing.id, actionType.id)
                    return
                }

                for (var i = 0; i < thingsProxy.count; i++) {
                    var thing = thingsProxy.get(i);
                    var actionType = thing.thingClass.actionTypes.findByName("close");
                    engine.thingManager.executeAction(thing.id, actionType.id)
                }
            case "cleaningrobot":


            default:
                console.warn("InterfaceTile, inlineButtonControl 3 clicked: Unhandled interface", iface)
            }
        }
    }
    Item { Layout.fillWidth: true; Layout.fillHeight: true }
}
