#include "systemcontroller.h"

#include "types/package.h"
#include "types/repository.h"
#include "types/packages.h"
#include "types/repositories.h"

SystemController::SystemController(JsonRpcClient *jsonRpcClient, QObject *parent):
    JsonHandler(parent),
    m_jsonRpcClient(jsonRpcClient)
{
    m_jsonRpcClient->registerNotificationHandler(this, "notificationReceived");
    m_packages = new Packages(this);
    m_repositories = new Repositories(this);
}

void SystemController::init()
{
    m_packages->clear();
    m_repositories->clear();
    if (m_jsonRpcClient->ensureServerVersion("2.0")) {
        m_jsonRpcClient->sendCommand("System.GetCapabilities", this, "getCapabilitiesResponse");
    } else {
        m_powerManagementAvailable = false;
    }
}

QString SystemController::nameSpace() const
{
    return "System";
}

bool SystemController::powerManagementAvailable() const
{
    return m_powerManagementAvailable;
}

bool SystemController::updateManagementAvailable() const
{
    return m_updateManagementAvailable;
}

void SystemController::reboot()
{
    m_jsonRpcClient->sendCommand("System.Reboot");
}

void SystemController::shutdown()
{
    m_jsonRpcClient->sendCommand("System.Shutdown");
}

bool SystemController::updateManagementBusy() const
{
    return m_updateManagementBusy;
}

bool SystemController::updateRunning() const
{
    return m_updateRunning;
}

void SystemController::checkForUpdates()
{
    m_jsonRpcClient->sendCommand("System.CheckForUpdates");
}

Packages *SystemController::packages() const
{
    return m_packages;
}

void SystemController::updatePackages(const QString packageId)
{
    QVariantMap params;
    if (!packageId.isEmpty()) {
        params.insert("packageIds", QStringList() << packageId);
    }
    m_jsonRpcClient->sendCommand("System.UpdatePackages", params);
}

void SystemController::removePackages(const QString packageId)
{
    QVariantMap params;
    if (!packageId.isEmpty()) {
        params.insert("packageIds", QStringList() << packageId);
    }
    m_jsonRpcClient->sendCommand("System.RemovePackages", params, this, "removePackageResponse");
}

Repositories *SystemController::repositories() const
{
    return m_repositories;
}

int SystemController::enableRepository(const QString &id, bool enabled)
{
    QVariantMap params;
    params.insert("repositoryId", id);
    params.insert("enabled", enabled);
    return m_jsonRpcClient->sendCommand("System.EnableRepository", params, this, "enableRepositoryResponse");
}

void SystemController::getCapabilitiesResponse(const QVariantMap &data)
{
    qDebug() << "capabilities received" << data;
    m_powerManagementAvailable = data.value("params").toMap().value("powerManagement").toBool();
    emit powerManagementAvailableChanged();

    m_updateManagementAvailable = data.value("params").toMap().value("updateManagement").toBool();
    emit updateManagementAvailableChanged();

    if (m_updateManagementAvailable) {
        m_jsonRpcClient->sendCommand("System.GetUpdateStatus", this, "getUpdateStatusResponse");
        m_jsonRpcClient->sendCommand("System.GetPackages", this, "getPackagesResponse");
        m_jsonRpcClient->sendCommand("System.GetRepositories", this, "getRepositoriesResponse");
    }
}

void SystemController::getUpdateStatusResponse(const QVariantMap &data)
{
    m_updateManagementBusy = data.value("params").toMap().value("busy").toBool();
    m_updateRunning = data.value("params").toMap().value("updateRunning").toBool();
    emit updateRunningChanged();
}

void SystemController::getPackagesResponse(const QVariantMap &data)
{
    foreach (const QVariant &packageVariant, data.value("params").toMap().value("packages").toList()) {
        QString id = packageVariant.toMap().value("id").toString();
        QString displayName = packageVariant.toMap().value("displayName").toString();
        Package *p = new Package(id, displayName);
        p->setSummary(packageVariant.toMap().value("summary").toString());
        p->setInstalledVersion(packageVariant.toMap().value("installedVersion").toString());
        p->setCandidateVersion(packageVariant.toMap().value("candidateVersion").toString());
        p->setChangelog(packageVariant.toMap().value("changelog").toString());
        p->setUpdateAvailable(packageVariant.toMap().value("updateAvailable").toBool());
        p->setRollbackAvailable(packageVariant.toMap().value("rollbackAvailable").toBool());
        p->setCanRemove(packageVariant.toMap().value("canRemove").toBool());
        m_packages->addPackage(p);
    }
}

void SystemController::getRepositoriesResponse(const QVariantMap &data)
{
    qDebug() << "******** Repos" << data;
    foreach (const QVariant &repoVariant, data.value("params").toMap().value("repositories").toList()) {
        QString id = repoVariant.toMap().value("id").toString();
        QString displayName = repoVariant.toMap().value("displayName").toString();
        Repository *repo = new Repository(id, displayName);
        repo->setEnabled(repoVariant.toMap().value("enabled").toBool());
        m_repositories->addRepository(repo);
    }
}

void SystemController::removePackageResponse(const QVariantMap &params)
{
    qDebug() << "Remove result" << params;
}

void SystemController::enableRepositoryResponse(const QVariantMap &params)
{
    qDebug() << "Enable repo response" << params;
    emit enableRepositoryFinished(params.value("id").toInt(), params.value("params").toMap().value("success").toBool());
}

void SystemController::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    if (notification == "System.UpdateStatusChanged") {
        qDebug() << "System.UpdateStatusChanged:" << data.value("params").toMap();
        if (m_updateManagementBusy != data.value("params").toMap().value("busy").toBool()) {
            m_updateManagementBusy = data.value("params").toMap().value("busy").toBool();
            emit updateManagementBusyChanged();
        }
        if (m_updateRunning != data.value("params").toMap().value("updateRunning").toBool()) {
            m_updateRunning = data.value("params").toMap().value("updateRunning").toBool();
            emit updateRunningChanged();
        }
    } else if (notification == "System.PackageAdded") {
        QVariantMap packageMap = data.value("params").toMap().value("package").toMap();
        QString id = packageMap.value("id").toString();
        QString displayName = packageMap.value("displayName").toString();
        Package *p = new Package(id, displayName);
        p->setSummary(packageMap.value("summary").toString());
        p->setInstalledVersion(packageMap.value("installedVersion").toString());
        p->setCandidateVersion(packageMap.value("candidateVersion").toString());
        p->setChangelog(packageMap.value("changelog").toString());
        p->setUpdateAvailable(packageMap.value("updateAvailable").toBool());
        p->setRollbackAvailable(packageMap.value("rollbackAvailable").toBool());
        p->setCanRemove(packageMap.value("canRemove").toBool());
        m_packages->addPackage(p);
    } else if (notification == "System.PackageChanged") {
        QVariantMap packageMap = data.value("params").toMap().value("package").toMap();
        QString id = packageMap.value("id").toString();
        Package *p = m_packages->getPackage(id);
        if (!p) {
            qWarning() << "Received a package update notification for a package we don't know";
            return;
        }
        p->setSummary(packageMap.value("summary").toString());
        p->setInstalledVersion(packageMap.value("installedVersion").toString());
        p->setCandidateVersion(packageMap.value("candidateVersion").toString());
        p->setChangelog(packageMap.value("changelog").toString());
        p->setUpdateAvailable(packageMap.value("updateAvailable").toBool());
        p->setRollbackAvailable(packageMap.value("rollbackAvailable").toBool());
        p->setCanRemove(packageMap.value("canRemove").toBool());
    } else if (notification == "System.PackageRemoved") {
        QString packageId = data.value("params").toMap().value("packageId").toString();
        m_packages->removePackage(packageId);
    } else if (notification == "System.RepositoryAdded") {
        QVariantMap repoMap = data.value("params").toMap().value("repository").toMap();
        QString id = repoMap.value("id").toString();
        QString displayName = repoMap.value("displayName").toString();
        Repository *repo = new Repository(id, displayName);
        repo->setEnabled(repoMap.value("enabled").toBool());
        m_repositories->addRepository(repo);
    } else if (notification == "System.RepositoryChanged") {
        QVariantMap repoMap = data.value("params").toMap().value("repository").toMap();
        QString id = repoMap.value("id").toString();
        Repository *repo = m_repositories->getRepository(id);
        if (!repo) {
            qWarning() << "Received a repository update notification for a repository we don't know";
            return;
        }
        repo->setEnabled(repoMap.value("enabled").toBool());
    } else if (notification == "System.RepositoryRemoved") {
        QString repositoryId = data.value("params").toMap().value("repositoryId").toString();
        m_repositories->removeRepository(repositoryId);
    } else if (notification == "System.CapabilitiesChanged") {
        m_powerManagementAvailable = data.value("params").toMap().value("powerManagement").toBool();
        m_updateManagementAvailable = data.value("params").toMap().value("updateManagement").toBool();
        qWarning() << "System capabilites changed: power management:" << m_powerManagementAvailable << "update management:" << m_updateManagementAvailable;
        emit powerManagementAvailableChanged();
        emit updateManagementAvailableChanged();
    } else {
        qWarning() << "Unhandled System Notification" << data.value("notification");
    }
}
