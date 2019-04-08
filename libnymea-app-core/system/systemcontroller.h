#ifndef SYSTEMCONTROLLER_H
#define SYSTEMCONTROLLER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"

class SystemController : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(bool powerManagementAvailable READ powerManagementAvailable NOTIFY powerManagementAvailableChanged)
    // Whether the update mechanism is available in the connected core
    Q_PROPERTY(bool updateManagementAvailable READ updateManagementAvailable NOTIFY updateManagementAvailableChanged)

    // Whether there is an update available
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateStatusChanged)
    Q_PROPERTY(QString currentVersion READ currentVersion NOTIFY updateStatusChanged)
    Q_PROPERTY(QString candidateVersion READ candidateVersion NOTIFY updateStatusChanged)
    Q_PROPERTY(QStringList availableChannels READ availableChannels NOTIFY updateStatusChanged)
    Q_PROPERTY(QString currentChannel READ currentChannel NOTIFY updateStatusChanged)

    Q_PROPERTY(bool updateInProgress READ updateInProgress NOTIFY updateStatusChanged)

public:
    explicit SystemController(JsonRpcClient *jsonRpcClient, QObject *parent = nullptr);

    void init();
    QString nameSpace() const override;

    bool powerManagementAvailable() const;
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void shutdown();

    bool updateManagementAvailable() const;
    bool updateAvailable() const;
    QString currentVersion() const;
    QString candidateVersion() const;
    QStringList availableChannels() const;
    QString currentChannel() const;

    bool updateInProgress() const;

    Q_INVOKABLE void startUpdate();
    Q_INVOKABLE void selectChannel(const QString &channel);

signals:
    void powerManagementAvailableChanged();
    void updateManagementAvailableChanged();
    void updateStatusChanged();

private slots:
    void getCapabilitiesResponse(const QVariantMap &data);
    void getUpdateStatusResponse(const QVariantMap &data);
    void selectChannelResponse(const QVariantMap &data);

    void notificationReceived(const QVariantMap &data);
private:
    JsonRpcClient *m_jsonRpcClient = nullptr;

    bool m_powerManagementAvailable = false;
    bool m_updateManagementAvailable = false;

    bool m_updateAvailable = false;
    QString m_currentVersion;
    QString m_candidateVersion;
    QStringList m_availableChannels;
    QString m_currentChannel;

    bool m_updareInProgress = false;
};

#endif // SYSTEMCONTROLLER_H
