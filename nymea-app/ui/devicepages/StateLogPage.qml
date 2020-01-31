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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property var device: null
    property var stateType: null

    readonly property bool canShowGraph: {
        switch (root.stateType.type) {
        case "Int":
        case "Double":
            return true;
        case "Bool":
            return engine.jsonRpcClient.ensureServerVersion("1.10")
        }
        print("not showing graph for", root.stateType.type)
        return false;
    }

    header: NymeaHeader {
        text: qsTr("History for %1").arg(root.stateType.displayName)
        onBackPressed: pageStack.pop()
    }

    LogsModel {
        id: logsModel
        engine: _engine
        deviceId: root.device.id
        live: true
        Component.onCompleted: {
            update()
        }
        typeIds: [root.stateType.id]
    }

    LogsModelNg {
        id: logsModelNg
        engine: _engine
        deviceId: root.device.id
        typeIds: [root.stateType.id]
        live: true
    }

    ColumnLayout {
        anchors.fill: parent

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            visible: root.canShowGraph
            TabButton {
                text: qsTr("Log")
            }
            TabButton {
                text: qsTr("Graph")
            }
        }

        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            interactive: false

            GenericTypeLogView {
                id: logView
                width: swipeView.width
                height: swipeView.height

                logsModel: engine.jsonRpcClient.ensureServerVersion("1.10") ? logsModelNg : logsModel

                onAddRuleClicked: {
                    var value = logView.logsModel.get(index).value
                    var typeId = logView.logsModel.get(index).typeId
                    var rule = engine.ruleManager.createNewRule();
                    var stateEvaluator = rule.createStateEvaluator();
                    stateEvaluator.stateDescriptor.deviceId = device.id;
                    stateEvaluator.stateDescriptor.stateTypeId = typeId;
                    stateEvaluator.stateDescriptor.value = value;
                    stateEvaluator.stateDescriptor.valueOperator = StateDescriptor.ValueOperatorEquals;
                    rule.setStateEvaluator(stateEvaluator);
                    rule.name = root.device.name + " - " + stateType.displayName + " = " + value;

                    var rulePage = pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device});
                    rulePage.addRule(rule);
                }
            }

            Loader {
                id: graphLoader
                width: swipeView.width
                height: swipeView.height
                Component.onCompleted: {
                    var source;
                    if (engine.jsonRpcClient.ensureServerVersion("1.10")) {
                        source = Qt.resolvedUrl("../customviews/GenericTypeGraph.qml");
                    } else {
                        source = Qt.resolvedUrl("../customviews/GenericTypeGraphPre110.qml");
                    }
                    setSource(source, {device: root.device, stateType: root.stateType})
                }
            }
        }
    }
}

