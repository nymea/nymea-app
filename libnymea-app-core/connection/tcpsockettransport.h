#ifndef TCPSOCKETTRANSPORT_H
#define TCPSOCKETTRANSPORT_H

#include "nymeatransportinterface.h"

#include <QObject>
#include <QSslSocket>
#include <QUrl>

class TcpSocketTransport: public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit TcpSocketTransport(QObject *parent = nullptr);

    QStringList supportedSchemes() const override;

    bool connect(const QUrl &url) override;
    ConnectionState connectionState() const override;
    void disconnect() override;
    void sendData(const QByteArray &data) override;
    void ignoreSslErrors(const QList<QSslError> &errors) override;

private slots:
    void onConnected();
    void onEncrypted();
    void socketReadyRead();
    void onSocketStateChanged(const QAbstractSocket::SocketState &state);

private:
    QSslSocket m_socket;
    QUrl m_url;
};

#endif // TCPSOCKETTRANSPROT_H
