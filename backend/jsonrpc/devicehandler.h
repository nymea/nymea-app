/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef DEVICEHANDLER_H
#define DEVICEHANDLER_H

#include <QObject>

#include "jsonhandler.h"

class DeviceHandler : public JsonHandler
{
    Q_OBJECT
public:
    explicit DeviceHandler(QObject *parent = 0);

    QString nameSpace() const;

    // Get methods internal
    Q_INVOKABLE void processGetSupportedVendors(const QVariantMap &params);
    Q_INVOKABLE void processGetPlugins(const QVariantMap &params);
    Q_INVOKABLE void processGetSupportedDevices(const QVariantMap &params);
    Q_INVOKABLE void processGetConfiguredDevices(const QVariantMap &params);

    // Methods ui
    Q_INVOKABLE void processRemoveConfiguredDevice(const QVariantMap &params);
    Q_INVOKABLE void processAddConfiguredDevice(const QVariantMap &params);
    Q_INVOKABLE void processGetDiscoveredDevices(const QVariantMap &params);
    Q_INVOKABLE void processPairDevice(const QVariantMap &params);
    Q_INVOKABLE void processConfirmPairing(const QVariantMap &params);

    // Notifications
    Q_INVOKABLE void processDeviceRemoved(const QVariantMap &params);
    Q_INVOKABLE void processDeviceAdded(const QVariantMap &params);
    Q_INVOKABLE void processStateChanged(const QVariantMap &params);

};

#endif // DEVICEHANDLER_H
