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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

RowLayout {
    id: root
    width: 150
    signal changed(var value)

    property var value
    property var unit: Types.UnitNone
    property alias from: slider.from
    property alias to: slider.to

    property StateType stateType

    readonly property int decimals: root.stateType.type.toLowerCase() === "int" ? 0 : 1

    Slider {
        id: slider
        Layout.fillWidth: true
        value: root.value
        stepSize: {
            var ret = 1
            for (var i = 0; i < root.decimals; i++) {
                ret /= 10;
            }
            return ret;
        }
        property var lastVibration: new Date()
        property var lastChange: root.value
        onMoved: {
            // Emits moved more often than stepsize, we only want to act when we actually emitted value change
            if (value === lastChange) {
                return;
            }
            lastChange = value;

            if (value === from || value === to) {
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
            } else {
                if (lastVibration.getTime() + 35 < new Date()) {
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                }
                lastVibration = new Date()
            }


            root.changed(value)
        }
    }
    Label {
        text: Types.toUiValue(slider.value, root.unit).toFixed(root.decimals)
    }
}
