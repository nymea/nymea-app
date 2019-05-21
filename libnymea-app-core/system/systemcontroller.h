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

    Q_PROPERTY(bool updateManagementBusy READ updateManagementBusy NOTIFY updateManagementBusyChanged)
    Q_PROPERTY(bool updateRunning READ updateRunning NOTIFY updateRunningChanged)
    Q_PROPERTY(Packages* packages READ packages CONSTANT)
    Q_PROPERTY(Repositories* repositories READ repositories CONSTANT)

public:
    explicit SystemController(JsonRpcClient *jsonRpcClient, QObject *parent = nullptr);

    void init();
    QString nameSpace() const override;

    bool powerManagementAvailable() const;
    bool updateManagementAvailable() const;

    Q_INVOKABLE void reboot();
    Q_INVOKABLE void shutdown();

    bool updateManagementBusy() const;
    bool updateRunning() const;

    Q_INVOKABLE void checkForUpdates();
    Packages* packages() const;
    Q_INVOKABLE void updatePackages(const QString packageId = QString());
    Q_INVOKABLE void removePackages(const QString packageId = QString());

    Repositories* repositories() const;
    Q_INVOKABLE void enableRepository(const QString &id, bool enabled);


signals:
    void powerManagementAvailableChanged();
    void updateManagementAvailableChanged();
    void updateManagementBusyChanged();
    void updateRunningChanged();

private slots:
    void getCapabilitiesResponse(const QVariantMap &data);
    void getUpdateStatusResponse(const QVariantMap &data);
    void getPackagesResponse(const QVariantMap &data);
    void getRepositoriesResponse(const QVariantMap &data);
    void removePackageResponse(const QVariantMap &params);

    void notificationReceived(const QVariantMap &data);

private:
    JsonRpcClient *m_jsonRpcClient = nullptr;

    bool m_powerManagementAvailable = false;
    bool m_updateManagementAvailable = false;

    bool m_updateManagementBusy = false;
    bool m_updateRunning = false;
    Packages *m_packages = nullptr;
    Repositories *m_repositories = nullptr;
};

#endif // SYSTEMCONTROLLER_H
