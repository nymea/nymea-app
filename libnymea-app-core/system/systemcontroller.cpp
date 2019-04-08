#include "systemcontroller.h"

SystemController::SystemController(JsonRpcClient *jsonRpcClient, QObject *parent):
    JsonHandler(parent),
    m_jsonRpcClient(jsonRpcClient)
{
    m_jsonRpcClient->registerNotificationHandler(this, "notificationReceived");
}

void SystemController::init()
{
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

bool SystemController::updateAvailable() const
{
    return m_updateAvailable;
}

QString SystemController::currentVersion() const
{
    return m_currentVersion;
}

QString SystemController::candidateVersion() const
{
    return m_candidateVersion;
}

QStringList SystemController::availableChannels() const
{
    return m_availableChannels;
}

QString SystemController::currentChannel() const
{
    return m_currentChannel;
}

bool SystemController::updateInProgress() const
{
    return m_updareInProgress;
}

void SystemController::startUpdate()
{
    m_jsonRpcClient->sendCommand("System.StartUpdate");
}

void SystemController::selectChannel(const QString &channel)
{
    QVariantMap params;
    params.insert("channel", channel);
    m_jsonRpcClient->sendCommand("System.SelectChannel", params, this, "selectChannelResponse");
}

void SystemController::reboot()
{
    m_jsonRpcClient->sendCommand("System.Reboot");
}

void SystemController::shutdown()
{
    m_jsonRpcClient->sendCommand("System.Shutdown");
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
    }
}

void SystemController::getUpdateStatusResponse(const QVariantMap &data)
{
    qDebug() << "Update status:" << data;
    m_currentVersion = data.value("params").toMap().value("currentVersion").toString();
    m_candidateVersion = data.value("params").toMap().value("candidateVersion").toString();
    m_availableChannels = data.value("params").toMap().value("availableChannels").toStringList();
    m_currentChannel = data.value("params").toMap().value("currentChannel").toString();
    m_updareInProgress = data.value("params").toMap().value("updateInProgress").toBool();
    m_updateAvailable = data.value("params").toMap().value("updateAvailable").toBool();
    emit updateStatusChanged();
}

void SystemController::selectChannelResponse(const QVariantMap &data)
{
    qDebug() << "Select channel response" << data;
}

void SystemController::notificationReceived(const QVariantMap &data)
{
    if (data.value("notification").toString() == "System.UpdateStatusChanged") {
        qDebug() << "Update status changed:" << data;
        m_currentVersion = data.value("params").toMap().value("currentVersion").toString();
        m_candidateVersion = data.value("params").toMap().value("candidateVersion").toString();
        m_availableChannels = data.value("params").toMap().value("availableChannels").toStringList();
        m_currentChannel = data.value("params").toMap().value("currentChannel").toString();
        m_updareInProgress = data.value("params").toMap().value("updateInProgress").toBool();
        m_updateAvailable = data.value("params").toMap().value("updateAvailable").toBool();
        emit updateStatusChanged();
    }
}
