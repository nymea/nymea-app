#ifndef GUHCONNECTION_H
#define GUHCONNECTION_H

#include <QObject>
#include <QHash>
#include <QSslError>
#include <QAbstractSocket>
#include <QUrl>

class GuhInterface;

class GuhConnection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString url READ url NOTIFY connectedChanged)

public:
    explicit GuhConnection(QObject *parent = nullptr);

    Q_INVOKABLE void connect(const QString &url);
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void acceptCertificate(const QByteArray &fingerprint);

    bool connected();
    QString url() const;

    void sendData(const QByteArray &data);

signals:
    void verifyConnectionCertificate(const QString &commonName, const QByteArray &fingerprint);
    void connectedChanged(bool connected);
    void connectionError();
    void dataAvailable(const QByteArray &data);

private slots:
    void onSslErrors(const QList<QSslError> &errors);
    void onError(QAbstractSocket::SocketError error);
    void onConnected();
    void onDisconnected();

private:
    void registerInterface(GuhInterface *iface);

private:
    QHash<QString, GuhInterface*> m_interfaces;
    GuhInterface *m_currentInterface = nullptr;
    QUrl m_currentUrl;
};

#endif // GUHCONNECTION_H
