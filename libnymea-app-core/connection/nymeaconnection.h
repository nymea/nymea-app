#ifndef NYMEACONNECTION_H
#define NYMEACONNECTION_H

#include <QObject>
#include <QHash>
#include <QSslError>
#include <QAbstractSocket>
#include <QUrl>
#include <QNetworkConfigurationManager>


#include "nymeahost.h"

class NymeaTransportInterface;
class NymeaTransportInterfaceFactory;

class NymeaConnection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(NymeaHost* currentHost READ currentHost WRITE setCurrentHost NOTIFY currentHostChanged)
    Q_PROPERTY(Connection* currentConnection  READ currentConnection NOTIFY currentConnectionChanged)
    Q_PROPERTY(Connection::BearerTypes availableBearerTypes READ availableBearerTypes NOTIFY availableBearerTypesChanged)
    Q_PROPERTY(ConnectionStatus connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)

public:
    enum ConnectionStatus {
        ConnectionStatusUnconnected,
        ConnectionStatusConnecting,
        ConnectionStatusNoBearerAvailable,
        ConnectionStatusBearerFailed,
        ConnectionStatusHostNotFound,
        ConnectionStatusConnectionRefused,
        ConnectionStatusRemoteHostClosed,
        ConnectionStatusTimeout,
        ConnectionStatusSslError,
        ConnectionStatusSslUntrusted,
        ConnectionStatusUnknownError,
        ConnectionStatusConnected
    };
    Q_ENUM(ConnectionStatus)
    explicit NymeaConnection(QObject *parent = nullptr);

    void registerTransport(NymeaTransportInterfaceFactory *transportFactory);

    Q_INVOKABLE void connect(NymeaHost* nymeaHost);
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void acceptCertificate(const QString &url, const QByteArray &pem);
    Q_INVOKABLE bool isTrusted(const QString &url);

    Connection::BearerTypes availableBearerTypes() const;

    bool connected();
    ConnectionStatus connectionStatus() const;

    NymeaHost* currentHost() const;
    void setCurrentHost(NymeaHost *host);

    Connection* currentConnection() const;


    void sendData(const QByteArray &data);

signals:
    void availableBearerTypesChanged();
    void verifyConnectionCertificate(const QString &url, const QStringList &issuerInfo, const QByteArray &fingerprint, const QByteArray &pem);
    void currentHostChanged();
    void connectedChanged(bool connected);
    void connectionStatusChanged();
    void currentConnectionChanged();
    void dataAvailable(const QByteArray &data);

private slots:
    void onSslErrors(const QList<QSslError> &errors);
    void onError(QAbstractSocket::SocketError error);
    void onConnected();
    void onDisconnected();

    void updateActiveBearers();
private:
    bool storePem(const QUrl &host, const QByteArray &pem);
    bool loadPem(const QUrl &host, QByteArray &pem);

    void connectInternal(NymeaHost *host);
    bool connectInternal(Connection *connection);

    Connection::BearerType qBearerTypeToNymeaBearerType(QNetworkConfiguration::BearerType type) const;

private:
    ConnectionStatus m_connectionStatus = ConnectionStatusUnconnected;
    QNetworkConfigurationManager *m_networkConfigManager = nullptr;
    Connection::BearerTypes m_availableBearerTypes = Connection::BearerTypeNone;

    QHash<QString, NymeaTransportInterfaceFactory*> m_transportFactories;
    QHash<NymeaTransportInterface*, Connection*> m_transportCandidates;
    NymeaTransportInterface *m_currentTransport = nullptr;
    NymeaHost *m_currentHost = nullptr;
};

#endif // NYMEACONNECTION_H
