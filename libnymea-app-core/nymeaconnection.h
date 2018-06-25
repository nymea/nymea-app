#ifndef NYMEACONNECTION_H
#define NYMEACONNECTION_H

#include <QObject>
#include <QHash>
#include <QSslError>
#include <QAbstractSocket>
#include <QUrl>

class NymeaInterface;

class NymeaConnection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString url READ url NOTIFY connectedChanged)
    Q_PROPERTY(QString hostAddress READ hostAddress NOTIFY connectedChanged)

public:
    explicit NymeaConnection(QObject *parent = nullptr);

    Q_INVOKABLE void connect(const QString &url);
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void acceptCertificate(const QString &url, const QByteArray &fingerprint);
    Q_INVOKABLE bool isTrusted(const QString &url);

    bool connected();

    QString url() const;
    QString hostAddress() const;

    void sendData(const QByteArray &data);

signals:
    void verifyConnectionCertificate(const QString &url, const QStringList &issuerInfo, const QByteArray &fingerprint);
    void connectedChanged(bool connected);
    void connectionError();
    void dataAvailable(const QByteArray &data);

private slots:
    void onSslErrors(const QList<QSslError> &errors);
    void onError(QAbstractSocket::SocketError error);
    void onConnected();
    void onDisconnected();

private:
    void registerInterface(NymeaInterface *iface);

private:
    QHash<QString, NymeaInterface*> m_interfaces;
    NymeaInterface *m_currentInterface = nullptr;
    QUrl m_currentUrl;
};

#endif // NYMEACONNECTION_H
