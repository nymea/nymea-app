#ifndef TCPSOCKETINTERFACE_H
#define TCPSOCKETINTERFACE_H

#include "nymeainterface.h"

#include <QObject>
#include <QSslSocket>
#include <QUrl>

class TcpSocketInterface : public NymeaInterface
{
    Q_OBJECT
public:
    explicit TcpSocketInterface(QObject *parent = nullptr);

    QStringList supportedSchemes() const override;

    void connect(const QUrl &url) override;
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

#endif // TCPSOCKETINTERFACE_H
