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

#ifndef SYSTEMCONTROLLER_H
#define SYSTEMCONTROLLER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"

class Repositories;
class Packages;

class SystemController : public JsonHandler
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

public:
    explicit SystemController(JsonRpcClient *jsonRpcClient, QObject *parent = nullptr);

    void init();
    QString nameSpace() const override;

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
    void setServerTime(const QDateTime &serverTime);
    QStringList timeZones() const;
    QString serverTimeZone() const;
    void setServerTimeZone(const QString &serverTimeZone);
    bool automaticTimeAvailable() const;
    bool automaticTime() const;
    void setAutomaticTime(bool automaticTime);

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

    void restartReply(int id, bool success);
    void rebootReply(int id, bool success);
    void shutdownReply(int id, bool success);

private slots:
    void getCapabilitiesResponse(const QVariantMap &data);
    void getUpdateStatusResponse(const QVariantMap &data);
    void getPackagesResponse(const QVariantMap &data);
    void getRepositoriesResponse(const QVariantMap &data);
    void removePackageResponse(const QVariantMap &params);
    void enableRepositoryResponse(const QVariantMap &params);
    void getServerTimeResponse(const QVariantMap &params);
    void setTimeResponse(const QVariantMap &params);
    void restartResponse(const QVariantMap &params);
    void rebootResponse(const QVariantMap &params);
    void shutdownResponse(const QVariantMap &params);

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
};

#endif // SYSTEMCONTROLLER_H
