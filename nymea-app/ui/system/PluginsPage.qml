/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: root
    header: NymeaHeader {
        text: qsTr("Plugins")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/configure.svg"
            color: pluginsProxy.showOnlyConfigurable ? Style.accentColor : Style.iconColor
            onClicked: {
                pluginsProxy.showOnlyConfigurable = !pluginsProxy.showOnlyConfigurable
            }
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: qsTr("Install more plugins")
        visible: packagesFilterModel.count > 0
        onClicked: {
            pageStack.push(Qt.resolvedUrl("PackageListPage.qml"), {filter: "nymea-plugin"})
        }
        PackagesFilterModel {
            id: packagesFilterModel
            packages: engine.systemController.packages
            nameFilter: "nymea-plugin"
        }

    }

    SettingsPageSectionHeader {
        text: qsTr("Installed integration plugins")
    }

    Repeater {
        model: PluginsProxy {
            id: pluginsProxy
            plugins: engine.thingManager.plugins
        }

        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
            property Plugin plugin: pluginsProxy.get(index)
            iconName: "../images/plugin.svg"
            text: model.name
            progressive: plugin.paramTypes.count > 0
            onClicked: if (progressive) { pageStack.push(Qt.resolvedUrl("PluginParamsPage.qml"), {plugin: plugin}) }
        }
    }
}
