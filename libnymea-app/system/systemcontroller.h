// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef SYSTEMCONTROLLER_H
#define SYSTEMCONTROLLER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"
#include "types/packages.h"
#include "types/repositories.h"

class SystemController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool powerManagementAvailable READ powerManagementAvailable NOTIFY powerManagementAvailableChanged)
    // Whether the update mechanism is available in the connected core
    Q_PROPERTY(bool updateManagementAvailable READ updateManagementAvailable NOTIFY updateManagementAvailableChanged)
    Q_PROPERTY(bool timeManagementAvailable READ timeManagementAvailable NOTIFY timeManagementAvailableChanged)

    Q_PROPERTY(bool updateManagementBusy READ updateManagementBusy NOTIFY updateManagementBusyChanged)
    Q_PROPERTY(bool updateRunning READ updateRunning NOTIFY updateRunningChanged)
    Q_PROPERTY(Packages* packages READ packages CONSTANT)
    Q_PROPERTY(Repositories* repositories READ repositories CONSTANT)

    Q_PROPERTY(QDateTime serverTime READ serverTime WRITE setServerTime NOTIFY serverTimeChanged)
    Q_PROPERTY(QString serverTimeZone READ serverTimeZone WRITE setServerTimeZone NOTIFY serverTimeZoneChanged)
    Q_PROPERTY(QStringList timeZones READ timeZones CONSTANT)
    Q_PROPERTY(bool automaticTimeAvailable READ automaticTimeAvailable NOTIFY automaticTimeAvailableChanged)
    Q_PROPERTY(bool automaticTime READ automaticTime WRITE setAutomaticTime NOTIFY automaticTimeChanged)

    Q_PROPERTY(QString deviceSerialNumber READ deviceSerialNumber NOTIFY deviceSerialNumberChanged)

public:
    explicit SystemController(JsonRpcClient *jsonRpcClient, QObject *parent = nullptr);

    void init();

    bool powerManagementAvailable() const;
    Q_INVOKABLE int restart();
    Q_INVOKABLE int reboot();
    Q_INVOKABLE int shutdown();

    bool updateManagementAvailable() const;
    bool updateManagementBusy() const;
    bool updateRunning() const;
    Q_INVOKABLE void checkForUpdates();
    Packages* packages() const;
    Q_INVOKABLE void updatePackages(const QString packageId = QString());
    Q_INVOKABLE void removePackages(const QString packageId = QString());
    Repositories* repositories() const;
    Q_INVOKABLE int enableRepository(const QString &id, bool enabled);

    bool timeManagementAvailable() const;
    QDateTime serverTime() const;
    int setServerTime(const QDateTime &serverTime);
    QStringList timeZones() const;
    QString serverTimeZone() const;
    int setServerTimeZone(const QString &serverTimeZone);
    bool automaticTimeAvailable() const;
    bool automaticTime() const;
    int setAutomaticTime(bool automaticTime);

    QString deviceSerialNumber() const;

signals:
    void powerManagementAvailableChanged();
    void updateManagementAvailableChanged();
    void timeManagementAvailableChanged();
    void updateManagementBusyChanged();
    void updateRunningChanged();
    void enableRepositoryFinished(int id, bool success);
    void serverTimeChanged();
    void serverTimeZoneChanged();
    void automaticTimeAvailableChanged();
    void automaticTimeChanged();
    void deviceSerialNumberChanged();

    void restartReply(int id, bool success);
    void rebootReply(int id, bool success);
    void shutdownReply(int id, bool success);

private slots:
    void getCapabilitiesResponse(int commandId, const QVariantMap &data);
    void getUpdateStatusResponse(int commandId, const QVariantMap &data);
    void getPackagesResponse(int commandId, const QVariantMap &data);
    void getRepositoriesResponse(int commandId, const QVariantMap &data);
    void removePackageResponse(int commandId, const QVariantMap &params);
    void enableRepositoryResponse(int commandId, const QVariantMap &params);
    void getServerTimeResponse(int commandId, const QVariantMap &params);
    void setTimeResponse(int commandId, const QVariantMap &params);
    void restartResponse(int commandId, const QVariantMap &params);
    void rebootResponse(int commandId, const QVariantMap &params);
    void shutdownResponse(int commandId, const QVariantMap &params);
    void getSystemInfoResponse(int commandId, const QVariantMap &params);

    void notificationReceived(const QVariantMap &data);


protected:
    void timerEvent(QTimerEvent *event) override;

private:
    JsonRpcClient *m_jsonRpcClient = nullptr;

    bool m_powerManagementAvailable = false;
    bool m_updateManagementAvailable = false;
    bool m_timeManagementAvailable = false;

    bool m_updateManagementBusy = false;
    bool m_updateRunning = false;
    Packages *m_packages = nullptr;
    Repositories *m_repositories = nullptr;

    QDateTime m_serverTime;
    QString m_serverTimeZone;
    QStringList m_timeZones;
    bool m_automaticTimeAvailable = false;
    bool m_automaticTime = false;

    QString m_deviceSerialNumber;
};

#endif // SYSTEMCONTROLLER_H
