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

#ifndef THINGGROUP_H
#define THINGGROUP_H

#include <QObject>

#include "types/device.h"

class DevicesProxy;
class DeviceManager;

class ThingGroup : public Device
{
    Q_OBJECT
public:
    explicit ThingGroup(DeviceManager *deviceManager, DeviceClass *deviceClass, DevicesProxy *devices, QObject *parent = nullptr);

    Q_INVOKABLE int executeAction(const QString &actionName, const QVariantList &params) override;

private:
    void syncStates();

signals:
    void actionExecutionFinished(int id, const QString &status);

private:
    DeviceManager* m_deviceManager = nullptr;
    DevicesProxy* m_devices = nullptr;

    int m_idCounter = 0;
    QHash<int, QList<int>> m_pendingActions;
};

#endif // THINGGROUP_H
